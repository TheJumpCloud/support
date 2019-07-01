Function Get-JCObject
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][System.String]$Type
    )
    DynamicParam
    {
        $JCType = Get-JCType | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
        $RuntimeParameterDictionary = If ($Type)
        {
            Get-JCCommonParameters -Force:($true) -Type:($Type);
        }
        Else
        {
            Get-JCCommonParameters -Force:($true);
        }
        If ('SystemInsights' -in $JCType.PSObject.Properties.Name -or (Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            New-DynamicParameter -Name:('Table') -Type:([System.String]) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ValidateSet:($JCType.SystemInsights.Table) -HelpMessage:('The SystemInsights table to query against.') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        }
        New-DynamicParameter -Name:('ReturnHashTable') -Type:([switch]) -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) -DefaultValue:($false) | Out-Null
        New-DynamicParameter -Name:('ReturnCount') -Type:([switch]) -ValueFromPipelineByPropertyName -DefaultValue:($false) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Debug message for parameter call
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet) -NoNewScope
        $Results = @()
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        Try
        {
            If ($JCType)
            {
                # Set the location base location in the json config and elect the specific system insights table
                $JCType = If ($Table -and $PSCmdlet.ParameterSetName -ne 'ByName')
                {
                    $JCType.SystemInsights | Where-Object {$_.Table -eq $Table}
                }
                Else
                {
                    $JCType
                }
                $UrlObject = @()
                # If searching ByValue add filters to query string and body.
                If ($PSCmdlet.ParameterSetName -eq 'ById')
                {
                    $SearchBy = 'ById'
                    $SearchByValue = $Id
                    $PropertyIdentifier = $JCType.ById
                }
                ElseIf ($PSCmdlet.ParameterSetName -eq 'ByName')
                {
                    $SearchBy = 'ByName'
                    $SearchByValue = $Name
                    $PropertyIdentifier = $JCType.ByName
                }
                ElseIf ($PSCmdlet.ParameterSetName -eq 'ByValue')
                {
                    $SearchBy = $SearchBy
                    $SearchByValue = $SearchByValue
                    $PropertyIdentifier = Switch ($SearchBy)
                    {
                        'ById' { $JCType.ById };
                        'ByName' { $JCType.ByName };
                    }
                }
                ElseIf ($PSCmdlet.ParameterSetName -eq 'Default' -or $JCType.TypeName.TypeNameSingular -in ('g_suite', 'office_365')) # Hacky logic to get g_suite and office_365 directories
                {
                    # Populate url variables
                    $UrlOut = If ($SearchBy -eq 'ById')
                    {
                        ($JCType.Url.Item).Replace($JCType.Url.variables, $SearchByValue)
                    }
                    Else
                    {
                        $JCType.Url.List
                    }
                    # Populate query string filter
                    If ($Filter)
                    {
                        $QueryString = '?filter=' + $Filter
                    }
                    # Build final body and url
                    $UrlObject += [PSCustomObject]@{
                        'Type'              = $Type;
                        'SearchBy'          = $null;
                        'SearchByValueItem' = $null;
                        'UrlPath'           = $UrlOut;
                        'QueryString'       = $QueryString;
                        'Body'              = $null;
                        'UrlFull'           = $JCUrlBasePath + $UrlOut + $QueryString;
                    }
                }
                Else
                {
                    Write-Error ('Unknown $PSCmdlet.ParameterSetName: ' + $PSCmdlet.ParameterSetName)
                }
                # Loop through each item passed in and build UrlObject
                ForEach ($SearchByValueItem In $SearchByValue)
                {
                    If (!($PSCmdlet.ParameterSetName -eq 'Default' -or $JCType.TypeName.TypeNameSingular -in ('g_suite', 'office_365'))) # Hacky logic to get g_suite and office_365 directories
                    {
                        $QueryStrings = @()
                        $BodyParts = @()
                        # Populate url variables
                        $UrlOut = Switch ($SearchBy)
                        {
                            'ById'
                            {
                                ($JCType.Url.Item).Replace($JCType.Url.variables, $SearchByValueItem)
                            }
                            'ByName'
                            {
                                $JCType.Url.List
                            }
                        }
                        If ($SearchBy -eq 'ByName')
                        {
                            # Add filters for exact match and wildcards
                            If ($SearchByValueItem -match '\*')
                            {
                                If ($JCType.SupportRegexFilter)
                                {
                                    $BodyParts += ('"filter":[{"' + $PropertyIdentifier + '":{"$regex": "(?i)(' + $SearchByValueItem.Replace('*', ')(.*?)(') + ')"}}]').Replace('()', '')
                                }
                                Else
                                {
                                    Write-Error ('The endpoint ' + $UrlOut + ' does not support wildcards in the $SearchByValueItem. Please remove "*" from "' + $SearchByValueItem + '".')
                                }
                            }
                            Else
                            {
                                $QueryStrings += 'filter=' + $PropertyIdentifier + ':eq:' + $SearchByValueItem + '&fields=' + $JCType.ById
                                $BodyParts += '"filter":[{"' + $PropertyIdentifier + '":"' + $SearchByValueItem + '"}]'
                            }
                        }
                    }
                    # Build url info
                    $QueryString = If ($QueryStrings) {'?' + ($QueryStrings -join '&')} Else {$null};
                    $Body = If ($BodyParts) {'{' + ($BodyParts -join ',') + '}'} Else {$null};
                    $UrlObject += [PSCustomObject]@{
                        'Type'              = $Type;
                        'SearchBy'          = $SearchBy;
                        'SearchByValueItem' = $SearchByValueItem;
                        'UrlPath'           = $UrlOut;
                        'QueryString'       = $QueryString;
                        'Body'              = $Body;
                        'UrlFull'           = $JCUrlBasePath + $UrlOut + $QueryString;
                    }
                }
                #########################################################
                # $UrlObject
                #########################################################
                # Make each API call
                ForEach ($UrlItem In $UrlObject)
                {
                    $UrlFull = $UrlItem.UrlFull
                    $Body = $UrlItem.Body
                    $SearchByValueItem = $UrlItem.SearchByValueItem
                    $SearchBy = $UrlItem.SearchBy
                    If ($SearchBy -eq 'ByName')
                    {
                        $FieldsReturned = $JCType.ById
                    }
                    Else
                    {
                        $FieldsReturned = $Fields
                    }
                    ## Escape Url????
                    # $UrlFull= ([uri]::EscapeDataString($UrlFull)
                    # Build function parameters
                    $FunctionParameters = [ordered]@{ }
                    If ($UrlFull) { $FunctionParameters.Add('Url', $UrlFull) }
                    If ($JCType.Method) { $FunctionParameters.Add('Method', $JCType.Method) }
                    If ($Body) { $FunctionParameters.Add('Body', $Body) }
                    If ($Limit) { $FunctionParameters.Add('Limit', $Limit) }
                    If ($Skip) { $FunctionParameters.Add('Skip', $Skip) }
                    If ($ReturnHashTable)
                    {
                        $Values = $FieldsReturned
                        $Key = If ($PropertyIdentifier) { $PropertyIdentifier } Else { $JCType.ById }
                        If ($Key) { $FunctionParameters.Add('Key', $Key) }
                        If ($Values) { $FunctionParameters.Add('Values', $Values) }
                    }
                    Else
                    {
                        If ($FieldsReturned) { $FunctionParameters.Add('Fields', $FieldsReturned) }
                        $FunctionParameters.Add('Paginate', $JCType.Paginate)
                        If ($ReturnCount -eq $true) { $FunctionParameters.Add('ReturnCount', $ReturnCount) }
                    }
                    # Hacky logic for organization
                    If ($JCType.TypeName.TypeNameSingular -eq 'organization')
                    {
                        $Organization = Invoke-JCApi @FunctionParameters
                        $FunctionParameters['Url'] = $UrlFull + '/' + $Organization.($JCType.ById)
                    }
                    # Run command
                    $Result = Switch ($ReturnHashTable)
                    {
                        $true { Get-JCHash @FunctionParameters }
                        Default { Invoke-JCApi @FunctionParameters }
                    }
                    # Hacky logic to get g_suite and office_365directories
                    If ($JCType.TypeName.TypeNameSingular -in ('g_suite', 'office_365'))
                    {
                        If ($ReturnCount -eq $true)
                        {
                            $Directory = $Result.results | Where-Object { $_.Type -eq $JCType.TypeName.TypeNameSingular }
                            $Result.totalCount = ($Directory | Measure-Object).Count
                            $Result.results = $Directory
                        }
                        Else
                        {
                            $Result = $Result | Where-Object { $_.Type -eq $JCType.TypeName.TypeNameSingular }
                        }
                    }
                    # Validate results
                    If ($Result -and $Result.PSObject.Properties.name -notcontains 'NoContent')
                    {
                        If ($SearchBy -and ($Result | Measure-Object).Count -gt 1 -and $UrlFull -notlike '*SystemInsights*')
                        {
                            Write-Warning -Message:('Found "' + [string]($Result | Measure-Object).Count + '" "' + $JCType.TypeName.TypeNamePlural + '" with the "' + $SearchBy.Replace('By', '').ToLower() + '" of "' + $SearchByValueItem + '"')
                        }
                        $Results += $Result
                    }
                    ElseIf ($SearchByValueItem)
                    {
                        If ($Table)
                        {
                            Write-Warning ('SystemInsights data not found in "' + $Table + '" where "' + $JCType.TypeName.TypeNameSingular + '" "' + $SearchBy.Replace('By', '').ToLower() + '" is "' + $SearchByValueItem + '".')
                        }
                        Else
                        {
                            Write-Warning ('A "' + $JCType.TypeName.TypeNameSingular + '" called "' + $SearchByValueItem + '" does not exist. Note the search is case sensitive.')
                        }
                    }
                    Else
                    {
                        Write-Warning ('The search value is blank or no "' + $JCType.TypeName.TypeNamePlural + '" have been setup in your org. SearchValue:"' + $SearchByValueItem + '"')
                    }
                }
                # Re-lookup object by id
                If ($Results -and $SearchBy -eq 'ByName')
                {
                    $PsBoundParameters.Remove('Name') | Out-Null
                    $PsBoundParameters.Remove('SearchBy') | Out-Null
                    $PsBoundParameters.Remove('SearchByValue') | Out-Null
                    $PsBoundParameters.Add('Id', $Results.($JCType.ById)) | Out-Null
                    $Results = Get-JCObject @PsBoundParameters
                }
                Else
                {
                    $ById = $JCType.ById
                    $ByName = $JCType.ByName
                    $TypeName = $JCType.TypeName
                    $TypeNameSingular = $TypeName.TypeNameSingular
                    $TypeNamePlural = $TypeName.TypeNamePlural
                    $Targets = $JCType.Targets
                    $TargetSingular = $Targets.TargetSingular
                    $TargetPlural = $Targets.TargetPlural
                    # List values to add to results
                    $HiddenProperties = @('ById', 'ByName', 'TypeName', 'TypeNameSingular', 'TypeNamePlural', 'Targets', 'TargetSingular', 'TargetPlural')
                    # Set the meta info to be hidden by default
                    If ($Results)
                    {
                        $Results = Hide-ObjectProperty -Object:($Results) -HiddenProperties:($HiddenProperties)
                    }
                }
            }
            Else
            {
                Write-Error ('$Type of "' + $Type + '" not found. $Type must be:' + ($JCType.TypeName.TypeNameSingular -join ','))
            }
        }
        Catch
        {
            Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($_, $true) -NoNewScope
        }
    }
    End
    {
        Return $Results
    }
}