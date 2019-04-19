Function Get-JCObject
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param()
    DynamicParam
    {
        $JCTypes = Get-JCObjectType
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('Type') -Type:([System.String]) -Mandatory -Position:(0) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ValidateSet:($JCTypes.Types) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Id') -Type([System.String]) -Mandatory -Position(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets(@('ById')) -Alias:(($JCTypes.ById).Where( {$_ -ne 'Id'}) | Select-Object -Unique) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Name') -Type([System.String]) -Mandatory -Position(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:(@('ByName')) -Alias:(($JCTypes.ByName).Where( {$_ -ne 'Name'}) | Select-Object -Unique) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('SearchBy') -Type:([System.String]) -Mandatory -Position:(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByValue') -ValidateSet:(@('ById', 'ByName')) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('SearchByValue') -Type:([System.String]) -Mandatory -Position:(2) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByValue') -HelpMessage:('Specify the item which you want to search for. Supports wildcard searches using: *') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Fields') -Type:([System.Array]) -Position:(3) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -HelpMessage:('An array of the fields/properties/columns you want to return from the search.') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Limit') -Type:([System.Int32]) -Position:(4) -ValueFromPipelineByPropertyName -ValidateRange:(1, [int]::MaxValue) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Skip') -Type:([System.Int32]) -Position:(5) -ValueFromPipelineByPropertyName -ValidateRange:(1, [int]::MaxValue) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('ReturnHashTable') -Type:([switch]) -Position:(6) -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('ReturnCount') -Type:([switch]) -Position:(7) -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False') }) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') { Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName) }
        $CurrentErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
    }
    Process
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object { Set-Variable -Name:($_.Key) -Value:($_.Value) -Force }
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
            # Hacky logic to get g_suite and office_365 directories
            If ($Type -notin ('gsuites', 'g_suite', 'office365s', 'office_365'))
            {
                If ($PSCmdlet.ParameterSetName -eq 'ById')
                {
                    $SearchBy = 'ById'
                    $SearchByValue = $Id
                }
                ElseIf ($PSCmdlet.ParameterSetName -eq 'ByName')
                {
                    $SearchBy = 'ByName'
                    $SearchByValue = $Name
                }
                # If searching ByValue add filters to query string and body.
                If ($PSCmdlet.ParameterSetName -ne 'Default')
                {
                    # Determine search method
                    $PropertyIdentifier = Switch ($SearchBy)
                    {
                        'ById' { $JCTypeItem.ById };
                        'ByName' { $JCTypeItem.ByName };
                    }
                    $QueryStrings = @()
                    $BodyParts = @()
                    # Populate Url placeholders. Assumption is that if an endpoint requires an Id to be passed in the Url that it does not require a filter because its looking for an exact match already.
                    If ($Url -match '({)(.*?)(})')
                    {
                        Write-Verbose ('Populating ' + $Matches[0] + ' with ' + $SearchByValue)
                        $Url = $Url.Replace($Matches[0], $SearchByValue)
                    }
                    Else
                    {
                        Switch ($SearchBy)
                        {
                            'ById'
                            {
                                $Url = $Url + '/' + $SearchByValue
                            }
                            'ByName'
                            {
                                # Add filters for exact match and wildcards
                                If ($SearchByValue -match '\*')
                                {
                                    If ($SupportRegexFilter)
                                    {
                                        $BodyParts += ('"filter":[{"' + $PropertyIdentifier + '":{"$regex": "(?i)(' + $SearchByValue.Replace('*', ')(.*?)(') + ')"}}]').Replace('()', '')
                                    }
                                    Else
                                    {
                                        Write-Error ('The endpoint ' + $Url + ' does not support wildcards in the $SearchByValue. Please remove "*" from "' + $SearchByValue + '".')
                                    }
                                }
                                Else
                                {
                                    $QueryStrings += 'filter=' + $PropertyIdentifier + ':eq:' + $SearchByValue
                                    $BodyParts += '"filter":[{"' + $PropertyIdentifier + '":"' + $SearchByValue + '"}]'
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
                        $Url = $Url + '?' + $JoinedQueryStrings
                    }
                }
            }
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
                If ($ReturnCount) { $FunctionParameters.Add('ReturnCount', $ReturnCount) }
            }
            # Hacky logic for organization
            If ($Type -in ('organization', 'organizations'))
            {
                $Organization = Invoke-JCApi @FunctionParameters
                $FunctionParameters['Url'] = $Url + '/' + $Organization.$ById
            }
            # Run command
            $Results = Switch ($ReturnHashTable)
            {
                $true { Get-JCHash @FunctionParameters }
                Default { Invoke-JCApi @FunctionParameters }
            }
            # Hacky logic to get g_suite and office_365directories
            If ($Type -in ('gsuites', 'g_suite', 'office365s', 'office_365'))
            {
                If ($ReturnCount)
                {
                    $Directory = $Results.results | Where-Object { $_.Type -eq $TypeNameSingular }
                    $Results.totalCount = $Directory.Count
                    $Results.results = $Directory
                }
                Else
                {
                    $Results = $Results | Where-Object { $_.Type -eq $TypeNameSingular }
                }
            }
            If ($Results)
            {
                # Set some properties to be hidden in the results
                $HiddenProperties = @('ById', 'ByName', 'TypeName', 'TypeNameSingular', 'TypeNamePlural', 'Targets', 'TargetSingular', 'TargetPlural')
                $Results | ForEach-Object {
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
                Return $Results
            }
            Else
            {
                Write-Warning ('No ' + $TypeNamePlural + ' called ' + $SearchByValue + ' exist or no ' + $TypeNamePlural + ' have been setup in your org. Note the search is case sensitive.')
            }
        }
        Else
        {
            Write-Error ('$Type of "' + $Type + '" not found. $Type must be:' + ($JCTypes.Types -join ','))
        }
    }
    End
    {
        $ErrorActionPreference = $CurrentErrorActionPreference
    }
}