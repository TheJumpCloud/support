Function Get-JCObject
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365', 'systeminsight')][Alias('TypeNameSingular')][System.String]$Type
    )
    DynamicParam
    {
        $JCTypes = Get-JCType | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        # New-DynamicParameter -Name:('Type') -Type:([System.String]) -Mandatory -Position:(0) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ValidateSet:($JCTypes.TypeName.TypeNameSingular) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Id') -Type([System.String[]]) -Mandatory -Position(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets(@('ById')) -Alias:(($JCTypes.ById) | Where-Object {$_ -ne 'Id'} | Select-Object -Unique) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Name') -Type([System.String[]]) -Mandatory -Position(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:(@('ByName')) -Alias:(($JCTypes.ByName) | Where-Object {$_ -ne 'Name'} | Select-Object -Unique) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('SearchBy') -Type:([System.String]) -Mandatory -Position:(1) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByValue') -ValidateSet:(@('ById', 'ByName')) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('SearchByValue') -Type:([System.String[]]) -Mandatory -Position:(2) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ParameterSets:('ByValue') -HelpMessage:('Specify the item which you want to search for. Supports wildcard searches using: *') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Fields') -Type:([System.Array]) -Position:(3) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -HelpMessage:('An array of the fields/properties/columns you want to return from the search.') -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Limit') -Type:([System.Int32]) -Position:(4) -ValueFromPipelineByPropertyName -ValidateRange:(1, [int]::MaxValue) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('Skip') -Type:([System.Int32]) -Position:(5) -ValueFromPipelineByPropertyName -ValidateRange:(1, [int]::MaxValue) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        New-DynamicParameter -Name:('ReturnHashTable') -Type:([switch]) -Position:(6) -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) -DefaultValue:($false) | Out-Null
        New-DynamicParameter -Name:('ReturnCount') -Type:([switch]) -Position:(7) -ValueFromPipelineByPropertyName -DefaultValue:($false) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        If ($Type -eq 'systeminsight')
        {
            New-DynamicParameter -Name:('Table') -Type:([System.String]) -Mandatory -Position:(8) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ValidateSet:($JCTypes.tables) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        }
        Return $RuntimeParameterDictionary
        # # Define the new parameters
        # $Param_Id = @{
        #     'Name'                            = 'Id';
        #     'Type'                            = [System.String[]];
        #     'Mandatory'                       = $true;
        #     'Position'                        = 1;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'ValidateNotNullOrEmpty'          = $true;
        #     'ParameterSets'                   = 'ById';
        #     'Alias'                           = ($JCTypes.ById) | Where-Object {$_ -ne 'Id'} | Select-Object -Unique;
        # }
        # $Param_Name = @{
        #     'Name'                            = 'Name';
        #     'Type'                            = [System.String[]];
        #     'Mandatory'                       = $true;
        #     'Position'                        = 1;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'ValidateNotNullOrEmpty'          = $true;
        #     'ParameterSets'                   = 'ByName';
        #     'Alias'                           = ($JCTypes.ByName) | Where-Object {$_ -ne 'Name'} | Select-Object -Unique;
        # }
        # $Param_SearchBy = @{
        #     'Name'                            = 'SearchBy';
        #     'Type'                            = [System.String[]];
        #     'Mandatory'                       = $true;
        #     'Position'                        = 1;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'ValidateNotNullOrEmpty'          = $true;
        #     'ParameterSets'                   = 'ByValue';
        #     'ValidateSet'                     = @('ById', 'ByName');
        # }
        # $Param_SearchByValue = @{
        #     'Name'                            = 'SearchByValue';
        #     'Type'                            = [System.String[]];
        #     'Mandatory'                       = $true;
        #     'Position'                        = 2;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'ValidateNotNullOrEmpty'          = $true;
        #     'ParameterSets'                   = 'ByValue';
        #     'HelpMessage'                     = 'Specify the item which you want to search for. Supports wildcard searches using: *';
        # }
        # $Param_Fields = @{
        #     'Name'                            = 'Fields';
        #     'Type'                            = [System.Array];
        #     'Position'                        = 3;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'ValidateNotNullOrEmpty'          = $true;
        #     'HelpMessage'                     = 'An array of the fields/properties/columns you want to return from the search.';
        # }
        # $Param_Limit = @{
        #     'Name'                            = 'Limit';
        #     'Type'                            = [System.Int32];
        #     'Position'                        = 4;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'ValidateRange'                   = (1, [int]::MaxValue);
        # }
        # $Param_Skip = @{
        #     'Name'                            = 'Skip';
        #     'Type'                            = [System.Int32];
        #     'Position'                        = 5;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'ValidateRange'                   = (1, [int]::MaxValue);
        # }
        # $Param_ReturnHashTable = @{
        #     'Name'                            = 'ReturnHashTable';
        #     'Type'                            = [switch];
        #     'Position'                        = 6;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'DefaultValue'                    = $false;
        # }
        # $Param_ReturnCount = @{
        #     'Name'                            = 'ReturnCount';
        #     'Type'                            = [switch];
        #     'Position'                        = 7;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'DefaultValue'                    = $false;
        # }
        # $Param_Table = @{
        #     'Name'                            = 'Table';
        #     'Type'                            = [System.String[]];
        #     'Mandatory'                       = $false;
        #     'Position'                        = 8;
        #     'ValueFromPipelineByPropertyName' = $true;
        #     'ValidateNotNullOrEmpty'          = $true;
        #     'ValidateSet'                     = $JCTypes.Tables;
        # }
        # # Create the parameter array
        # $Params = @()
        # # Add parameters to array
        # $Params += $Param_Id
        # $Params += $Param_Name
        # $Params += $Param_SearchBy
        # $Params += $Param_SearchByValue
        # $Params += $Param_Fields
        # $Params += $Param_Limit
        # $Params += $Param_Skip
        # $Params += $Param_ReturnHashTable
        # $Params += $Param_ReturnCount
        # $Params += $Param_Table
        # # Create new parameters
        # $RuntimeParameterDictionary = $Params |
        #     ForEach-Object { New-Object -TypeName:('PSObject') -Property:($_) } |
        #     New-DynamicParameter
        # # Return parameters
        # Return $RuntimeParameterDictionary
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
                If (!($Limit)) { $Limit = $JCTypeItem.Limit }
                $UrlObject = @()
                # If searching ByValue add filters to query string and body.
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
                ElseIf ($PSCmdlet.ParameterSetName -eq 'Default' -or $TypeNameSingular -in ('g_suite', 'office_365')) # Hacky logic to get g_suite and office_365 directories
                {
                    If ($Type -eq 'SystemInsight')
                    {
                        $UrlOut = $Url + '/' + $Table
                    }
                    Else
                    {
                        $UrlOut = $Url
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
                    If (!($PSCmdlet.ParameterSetName -eq 'Default' -or $TypeNameSingular -in ('g_suite', 'office_365'))) # Hacky logic to get g_suite and office_365 directories
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
                                    If ($Type -eq 'SystemInsight')
                                    {
                                        $UrlOut = $Url + '/' + $SearchByValueItem + '/' + $Table
                                    }
                                    Else
                                    {
                                        $UrlOut = $Url + '/' + $SearchByValueItem
                                    }
                                }
                                'ByName'
                                {
                                    If ($Type -eq 'SystemInsight')
                                    {
                                        $UrlOut = $Url + '/' + $Table
                                    }
                                    Else
                                    {
                                        $UrlOut = $Url
                                    }
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
                                        $QueryStrings += 'filter=' + $PropertyIdentifier + ':eq:' + $SearchByValueItem + '&fields=' + $ById
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
                ############################## $Results += $UrlObject
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
                        $FieldsReturned = $ById
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
                    If ($Method) { $FunctionParameters.Add('Method', $Method) }
                    If ($Body) { $FunctionParameters.Add('Body', $Body) }
                    If ($Limit) { $FunctionParameters.Add('Limit', $Limit) }
                    If ($Skip) { $FunctionParameters.Add('Skip', $Skip) }
                    If ($ReturnHashTable)
                    {
                        $Values = $FieldsReturned
                        $Key = If ($PropertyIdentifier) { $PropertyIdentifier } Else { $ById }
                        If ($Key) { $FunctionParameters.Add('Key', $Key) }
                        If ($Values) { $FunctionParameters.Add('Values', $Values) }
                    }
                    Else
                    {
                        If ($FieldsReturned) { $FunctionParameters.Add('Fields', $FieldsReturned) }
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
                    # Validate results
                    If ($Result -and $Result.PSObject.Properties.name -notcontains 'NoContent')
                    {
                        If ($SearchBy -and ($Result | Measure-Object).Count -gt 1 -and $Type -ne 'SystemInsight')
                        {
                            Write-Warning -Message:('Found "' + [string]($Result | Measure-Object).Count + '" "' + $TypeNamePlural + '" with the "' + $SearchBy.Replace('By', '').ToLower() + '" of "' + $SearchByValueItem + '"')
                        }
                        $Results += $Result
                    }
                    ElseIf ($SearchByValueItem)
                    {
                        Switch ($Type)
                        {
                            'SystemInsight' { Write-Warning ('Unable to find "' + $TypeNameSingular + '" "' + $Table + '" data for "' + $SearchByValueItem + '".') }
                            Default { Write-Warning ('A "' + $TypeNameSingular + '" called "' + $SearchByValueItem + '" does not exist. Note the search is case sensitive.') }
                        }
                    }
                    Else
                    {
                        Write-Warning ('The search value is blank or no "' + $TypeNamePlural + '" have been setup in your org. SearchValue:"' + $SearchByValueItem + '"')
                    }
                }
                # Re-lookup object by id
                If ($SearchBy -eq 'ByName')
                {
                    $PsBoundParameters.Remove('Name') | Out-Null
                    $PsBoundParameters.Add('Id', $Results.$ById) | Out-Null
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