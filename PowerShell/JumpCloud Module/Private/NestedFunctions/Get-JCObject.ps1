Function Get-JCObject
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param()
    DynamicParam
    {
        $JCTypes = Get-JCType
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('Type') -Type:([System.String]) -Mandatory -Position:(0) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ValidateSet:($JCTypes.Types) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
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
        $CurrentErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        Try
        {
            # Identify the command type to run to get the object for the specified item
            $JCTypeItem = $JCTypes | Where-Object { $Type -in $_.Types }
            If ($JCTypeItem)
            {
                $JCTypeItem.Types = $Type
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
                If ($PSCmdlet.ParameterSetName -eq 'Default' -or $Type -in ('gsuites', 'g_suite', 'office365s', 'office_365'))
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
                            'Url'           = $UrlOut;
                            'Body'          = $Body;
                            'SearchByValue' = $SearchByValue;
                        }
                    }
                }
                ForEach ($UrlItem In $UrlObject)
                {
                    $Url = $UrlItem.Url
                    $Body = $UrlItem.Body
                    $SearchByValue = $UrlItem.SearchByValue
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
                    If ($Type -in ('organization', 'organizations'))
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
                    If ($Type -in ('gsuites', 'g_suite', 'office365s', 'office_365'))
                    {
                        If ($ReturnCount -eq $true)
                        {
                            $Directory = $Result.results | Where-Object { $_.Type -eq $TypeNameSingular }
                            $Result.totalCount = $Directory.Count
                            $Result.results = $Directory
                        }
                        Else
                        {
                            $Result = $Result | Where-Object { $_.Type -eq $TypeNameSingular }
                        }
                    }
                    If ($Result)
                    {
                        # Set some properties to be hidden in the results
                        $HiddenProperties = @('ById', 'ByName', 'TypeName', 'TypeNameSingular', 'TypeNamePlural', 'Targets', 'TargetSingular', 'TargetPlural')
                        $Result | ForEach-Object {
                            # Create the default property display set
                            $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$_.PSObject.Properties.Name)
                            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                            # Add the list of standard members
                            Add-Member -InputObject:($_) -MemberType:('MemberSet') -Name:('PSStandardMembers') -Value:($PSStandardMembers)
                            # Add ById and ByName as hidden properties to results
                            ForEach ($HiddenProperty In $HiddenProperties)
                            {
                                Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:($HiddenProperty) -Value:(Get-Variable -Name:($HiddenProperty) -ValueOnly)
                            }
                        }
                        $Results += $Result
                    }
                    Else
                    {
                        If ($SearchByValue)
                        {
                            Write-Warning ('A "' + $TypeNameSingular + '" called "' + $SearchByValue + '" does not exist. Note the search is case sensitive.')
                        }
                        Else
                        {
                            Write-Warning ('The search value is blank or no "' + $TypeNamePlural + '" have been setup in your org. SearchValue:"' + $SearchByValue + '"')
                        }
                    }
                }
            }
            Else
            {
                Write-Error ('$Type of "' + $Type + '" not found. $Type must be:' + ($JCTypes.Types -join ','))
            }
        }
        Catch
        {
            Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($_) -NoNewScope
        }
    }
    End
    {
        Return $Results
        $ErrorActionPreference = $CurrentErrorActionPreference
    }
}