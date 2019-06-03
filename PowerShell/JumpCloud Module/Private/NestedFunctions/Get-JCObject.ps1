Function Get-JCObject
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param()
    DynamicParam
    {
        $JCTypes = Get-JCType
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('Type') -Type:([System.String]) -Mandatory -Position:(0) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ValidateSet:($JCTypes.TypeName.TypeNameSingular) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Id') -Type([System.String[]]) -Mandatory -Position(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets(@('ById')) -Alias:(($JCTypes.ById) | Where-Object {$_ -ne 'Id'} | Select-Object -Unique) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Name') -Type([System.String[]]) -Mandatory -Position(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:(@('ByName')) -Alias:(($JCTypes.ByName) | Where-Object {$_ -ne 'Name'} | Select-Object -Unique) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('SearchBy') -Type:([System.String]) -Mandatory -Position:(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByValue') -ValidateSet:(@('ById', 'ByName')) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('SearchByValue') -Type:([System.String[]]) -Mandatory -Position:(2) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByValue') -HelpMessage:('Specify the item which you want to search for. Supports wildcard searches using: *') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Fields') -Type:([System.Array]) -Position:(3) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -HelpMessage:('An array of the fields/properties/columns you want to return from the search.') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Limit') -Type:([System.Int32]) -Position:(4) -ValueFromPipelineByPropertyName -ValidateRange:(1, [int]::MaxValue) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Skip') -Type:([System.Int32]) -Position:(5) -ValueFromPipelineByPropertyName -ValidateRange:(1, [int]::MaxValue) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('ReturnHashTable') -Type:([switch]) -Position:(6) -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) -DefaultValue:($false) | Out-Null
        New-DynamicParameter -Name:('ReturnCount') -Type:([switch]) -Position:(7) -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) -DefaultValue:($false) | Out-Null
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
            # Identify the command type to run to get the object for the specified item
            $JCTypeItem = $JCTypes | Where-Object { $Type -in $_.TypeName.TypeNameSingular }
            If ($JCTypeItem)
            {
                $TypeName = $JCTypeItem.TypeName
                $TypeNameSingular = $TypeName.TypeNameSingular
                $TypeNamePlural = $TypeName.TypeNamePlural
                $Targets = $JCTypeItem.Targets
                $TargetSingular = $Targets.TargetSingular
                $TargetPlural = $Targets.TargetPlural
                $Url = $JCTypeItem.Url
                $Method = $JCTypeItem.Method
                $ById = $JCTypeItem.ById
                $ByName = $JCTypeItem.ByName
                $Paginate = $JCTypeItem.Paginate
                $SupportRegexFilter = $JCTypeItem.SupportRegexFilter
                $Limit = $JCTypeItem.Limit
                $UrlObject = @()
                # If searching ByValue add filters to query string and body. # Hacky logic to get g_suite and office_365 directories
                If ($PSCmdlet.ParameterSetName -eq 'Default' -or $TypeNameSingular -in ('g_suite', 'office_365'))
                {
                    $UrlObject += [PSCustomObject]@{
                        'Url'           = $Url;
                        'Body'          = $null;
                        'SearchByValue' = $null;
                    }
                }
                Else
                {
                    If ($PSCmdlet.ParameterSetName -eq 'ById')
                    {
                        $SearchBy = 'ById'
                        $SearchByValue = $Id
                        $PropertyIdentifier = $JCTypeItem.ById
                    }
                    ElseIf ($PSCmdlet.ParameterSetName -eq 'ByName')
                    {
                        $SearchBy = 'ByName'
                        $SearchByValue = $Name
                        $PropertyIdentifier = $JCTypeItem.ByName
                    }
                    ElseIf ($PSCmdlet.ParameterSetName -eq 'ByValue')
                    {
                        $SearchBy = $SearchBy
                        $SearchByValue = $SearchByValue
                        $PropertyIdentifier = Switch ($SearchBy)
                        {
                            'ById' { $JCTypeItem.ById };
                            'ByName' { $JCTypeItem.ByName };
                        }
                    }
                    ForEach ($SearchByValueItem In $SearchByValue)
                    {
                        $QueryStrings = @()
                        $BodyParts = @()
                        # Populate Url placeholders. Assumption is that if an endpoint requires an Id to be passed in the Url that it does not require a filter because its looking for an exact match already.
                        If ($Url -match '({)(.*?)(})')
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
                                    $UrlOut = $Url + '/' + $SearchByValueItem
                                }
                                'ByName'
                                {
                                    $UrlOut = $Url
                                    # Add filters for exact match and wildcards
                                    If ($SearchByValueItem -match '\*')
                                    {
                                        If ($SupportRegexFilter)
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
                                        $QueryStrings += 'filter=' + $PropertyIdentifier + ':eq:' + $SearchByValueItem
                                        $BodyParts += '"filter":[{"' + $PropertyIdentifier + '":"' + $SearchByValueItem + '"}]'
                                    }
                                }
                                Default {Write-Error ('Unknown $SearchBy value: ' + $SearchBy)}
                            }
                        }
                        # Build query string and body
                        $JoinedQueryStrings = $QueryStrings -join '&'
                        $JoinedBodyParts = $BodyParts -join ','
                        # Build final body and url
                        If ($JoinedBodyParts)
                        {
                            $Body = '{' + $JoinedBodyParts + '}'
                        }
                        If ($JoinedQueryStrings)
                        {
                            $UrlOut = $UrlOut + '?' + $JoinedQueryStrings
                        }
                        $UrlObject += [PSCustomObject]@{
                            'Url'               = $UrlOut;
                            'Body'              = $Body;
                            'SearchByValueItem' = $SearchByValueItem;
                        }
                    }
                }
                ForEach ($UrlItem In $UrlObject)
                {
                    $Url = $UrlItem.Url
                    $Body = $UrlItem.Body
                    $SearchByValueItem = $UrlItem.SearchByValueItem
                    ## Escape Url????
                    # $Url = ([uri]::EscapeDataString($Url)
                    # Build function parameters
                    $FunctionParameters = [ordered]@{ }
                    If ($Url) { $FunctionParameters.Add('Url', $Url) }
                    If ($Method) { $FunctionParameters.Add('Method', $Method) }
                    If ($Body) { $FunctionParameters.Add('Body', $Body) }
                    If ($Limit) { $FunctionParameters.Add('Limit', $Limit) }
                    If ($Skip) { $FunctionParameters.Add('Skip', $Skip) }
                    If ($ReturnHashTable)
                    {
                        $Values = $Fields
                        $Key = If ($PropertyIdentifier) { $PropertyIdentifier } Else { $ById }
                        If ($Key) { $FunctionParameters.Add('Key', $Key) }
                        If ($Values) { $FunctionParameters.Add('Values', $Values) }
                    }
                    Else
                    {
                        If ($Fields) { $FunctionParameters.Add('Fields', $Fields) }
                        $FunctionParameters.Add('Paginate', $Paginate)
                        If ($ReturnCount -eq $true) { $FunctionParameters.Add('ReturnCount', $ReturnCount) }
                    }
                    # Hacky logic for organization
                    If ($TypeNameSingular -eq 'organization')
                    {
                        $Organization = Invoke-JCApi @FunctionParameters
                        $FunctionParameters['Url'] = $Url + '/' + $Organization.$ById
                    }
                    # Run command
                    $Result = Switch ($ReturnHashTable)
                    {
                        $true { Get-JCHash @FunctionParameters }
                        Default { Invoke-JCApi @FunctionParameters }
                    }
                    # Hacky logic to get g_suite and office_365directories
                    If ($TypeNameSingular -in ('g_suite', 'office_365'))
                    {
                        If ($ReturnCount -eq $true)
                        {
                            $Directory = $Result.results | Where-Object { $_.Type -eq $TypeNameSingular }
                            $Result.totalCount = ($Directory | Measure-Object).Count
                            $Result.results = $Directory
                        }
                        Else
                        {
                            $Result = $Result | Where-Object { $_.Type -eq $TypeNameSingular }
                        }
                    }
                    If ($Result -and $Result.PSObject.Properties.name -notcontains 'NoContent')
                    {
                        If ($SearchBy -and ($Result | Measure-Object).Count -gt 1)
                        {
                            Write-Warning -Message:('Found "' + [string]($Result | Measure-Object).Count + '" "' + $TypeNamePlural + '" with the "' + $SearchBy.Replace('By', '').ToLower() + '" of "' + $SearchByValueItem + '"')
                        }
                        # If ($PSCmdlet.ParameterSetName -eq 'Default' -and $TypeNameSingular -notin ('g_suite', 'office_365') -and $Url -notlike '*/api/v2/directories*' -and $Url -notlike '*/groups*' -and $Url -notlike '*/api/organizations*' -and $Url -notlike '*/api/search*')
                        # {
                        #     $Results = $Result | ForEach-Object { Get-JCObject -Type:($TypeNameSingular) -Id:($_.($ById))}
                        # }
                        # Else
                        # {

                        # List values to add to results
                        $HiddenProperties = @('ById', 'ByName', 'TypeName', 'TypeNameSingular', 'TypeNamePlural', 'Targets', 'TargetSingular', 'TargetPlural')
                        # Append meta info to each result record
                        Get-Variable -Name:($HiddenProperties) |
                            ForEach-Object {
                            $Variable = $_
                            $Result |
                                ForEach-Object {
                                Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:($Variable.Name) -Value:($Variable.Value)
                            }
                        }
                        # Set the meta info to be hidden by default
                        $Results += Hide-ObjectProperty -Object:($Result) -HiddenProperties:($HiddenProperties)
                    }
                    Else
                    {
                        If ($SearchByValueItem)
                        {
                            Write-Warning ('A "' + $TypeNameSingular + '" called "' + $SearchByValueItem + '" does not exist. Note the search is case sensitive.')
                        }
                        Else
                        {
                            Write-Warning ('The search value is blank or no "' + $TypeNamePlural + '" have been setup in your org. SearchValue:"' + $SearchByValueItem + '"')
                        }
                    }
                    # }
                }
            }
            Else
            {
                Write-Error ('$Type of "' + $Type + '" not found. $Type must be:' + ($JCTypes.TypeName.TypeNameSingular -join ','))
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