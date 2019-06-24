Function Get-JCObject
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][System.String]$Type
    )
    DynamicParam
    {
        $JCType = Get-JCType | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('Id') -Type([System.String[]]) -Mandatory -Position(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets(@('ById')) -Alias:(($JCType.ById) | Where-Object {$_ -ne 'Id'} | Select-Object -Unique) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Name') -Type([System.String[]]) -Mandatory -Position(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:(@('ByName')) -Alias:(($JCType.ByName) | Where-Object {$_ -ne 'Name'} | Select-Object -Unique) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('SearchBy') -Type:([System.String]) -Mandatory -Position:(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByValue') -ValidateSet:(@('ById', 'ByName')) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('SearchByValue') -Type:([System.String[]]) -Mandatory -Position:(2) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByValue') -HelpMessage:('Specify the item which you want to search for. Supports wildcard searches using: *') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Fields') -Type:([System.Array]) -Position:(3) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -HelpMessage:('An array of the fields/properties/columns you want to return from the search.') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Limit') -Type:([System.Int32]) -Position:(4) -ValueFromPipelineByPropertyName -ValidateRange:(1, [int]::MaxValue) -DefaultValue:($JCType.Limit) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Skip') -Type:([System.Int32]) -Position:(5) -ValueFromPipelineByPropertyName -ValidateRange:(1, [int]::MaxValue) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        If ('SystemInsights' -in $JCType.PSObject.Properties.Name -or (Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            New-DynamicParameter -Name:('SystemInsights') -Type:([System.String]) -Position:(6) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ValidateSet:($JCType.SystemInsights.tables) -HelpMessage:('The SystemInsights table to query against.') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        }
        New-DynamicParameter -Name:('ReturnHashTable') -Type:([switch]) -Position:(7) -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) -DefaultValue:($false) | Out-Null
        New-DynamicParameter -Name:('ReturnCount') -Type:([switch]) -Position:(8) -ValueFromPipelineByPropertyName -DefaultValue:($false) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
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
                    If ($SystemInsights)
                    {
                        $UrlOut = $JCType.SystemInsights.Url + '/' + $SystemInsights
                    }
                    Else
                    {
                        $UrlOut = $JCType.Url
                    }
                    # Build final body and url
                    $UrlObject += [PSCustomObject]@{
                        'Type'              = $Type;
                        'SearchBy'          = $null;
                        'Url'               = $UrlOut;
                        'QueryString'       = $null;
                        'Body'              = $null;
                        'SearchByValueItem' = $null;
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
                        # Populate Url placeholders. Assumption is that if an endpoint requires an Id to be passed in the Url that it does not require a filter because its looking for an exact match already.
                        If ($JCType.Url -match '({)(.*?)(})')
                        {
                            Write-Verbose ('Populating ' + $Matches[0] + ' with ' + $SearchByValueItem)
                            $UrlOut = $Url.Replace($Matches[0], $SearchByValueItem)
                        }
                        Else
                        {
                            Switch ($SearchBy)
                            {
                                'ById'
                                {
                                    If ($SystemInsights)
                                    {
                                        $UrlOut = $JCType.SystemInsights.Url + '/' + $SearchByValueItem + '/' + $SystemInsights
                                    }
                                    Else
                                    {
                                        $UrlOut = $JCType.Url + '/' + $SearchByValueItem
                                    }
                                }
                                'ByName'
                                {
                                    $UrlOut = $JCType.Url
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
                                Default {Write-Error ('Unknown $SearchBy value: ' + $SearchBy)}
                            }
                        }
                    }
                    # Build url info
                    $UrlObject += [PSCustomObject]@{
                        'Type'              = $Type;
                        'SearchBy'          = $SearchBy;
                        'Url'               = $UrlOut;
                        'QueryString'       = If ($QueryStrings) {'?' + ($QueryStrings -join '&')} Else {$null};
                        'Body'              = If ($BodyParts) {'{' + ($BodyParts -join ',') + '}'} Else {$null};
                        'SearchByValueItem' = If ($SearchByValueItem) {$SearchByValueItem} Else {$null};
                    }
                }
                # Make each API call
                ForEach ($UrlItem In $UrlObject)
                {
                    $Url = If ($UrlItem.QueryString)
                    {
                        $UrlItem.Url + $UrlItem.QueryString
                    }
                    Else
                    {
                        $UrlItem.Url
                    }
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
                    # $Url = ([uri]::EscapeDataString($Url)
                    # Build function parameters
                    $FunctionParameters = [ordered]@{ }
                    If ($Url) { $FunctionParameters.Add('Url', $Url) }
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
                        $FunctionParameters['Url'] = $Url + '/' + $Organization.($JCType.ById)
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
                        If ($SearchBy -and ($Result | Measure-Object).Count -gt 1 -and $Url -notlike '*SystemInsights*')
                        {
                            Write-Warning -Message:('Found "' + [string]($Result | Measure-Object).Count + '" "' + $JCType.TypeName.TypeNamePlural + '" with the "' + $SearchBy.Replace('By', '').ToLower() + '" of "' + $SearchByValueItem + '"')
                        }
                        $Results += $Result
                    }
                    ElseIf ($SearchByValueItem)
                    {
                        If ($SystemInsights)
                        {
                            # Write-Warning ('Unable to find "' + $JCType.TypeName.TypeNameSingular + '" "' + $SystemInsights + '" data for "' + $SearchByValueItem + '".')
                            # Write-Warning ('SystemInsights has not been enabled on the "' + $JCType.TypeName.TypeNameSingular + '" "' + $SearchByValueItem + '".')
                            Write-Warning ('SystemInsights data not found in "' + $SystemInsights + '" where "' + $JCType.TypeName.TypeNameSingular + '" "' + $SearchBy.Replace('By', '').ToLower() + '" is "' + $SearchByValueItem + '".')
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
                    $PsBoundParameters.Add('Id', $Results.($JCType.ById)) | Out-Null
                    $Results = Get-JCObject @PsBoundParameters
                }
                Else
                {
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