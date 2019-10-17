Function Get-JCCommonParameters
{
    Param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The RuntimeDefinedParameterDictionary to store variables.')][ValidateNotNullOrEmpty()][System.Management.Automation.RuntimeDefinedParameterDictionary]$RuntimeParameterDictionary = (New-Object -TypeName:([System.Management.Automation.RuntimeDefinedParameterDictionary]))
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365', 'organization')][Alias('TypeNameSingular')][System.String]$Type
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The verb of the command calling it. Different verbs will make different parameters required.')][ValidateSet('add', 'copy', 'get', 'new', 'remove', 'set')][System.String]$Action
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Bypass user prompts and dynamic ValidateSet.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    Begin
    {
    }
    Process
    {
        # Get type list
        $script:JCType = If ($Type)
        {
            Get-JCType -Type:($Type) | Where-Object { $_.Category -eq 'JumpCloud' };
        }
        Else
        {
            Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' };
        }
        # Define the new parameters
        $Param_Id = @{
            'Name'                            = 'Id';
            'Type'                            = [System.String[]];
            'Mandatory'                       = $true;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = @('ById');
            'HelpMessage'                     = 'The unique id of the object.';
            'Alias'                           = $JCType.ById | Where-Object { $_ -ne 'Id' } | Select-Object -Unique;
            'Position'                        = 1;
        }
        $Param_Name = @{
            'Name'                            = 'Name';
            'Type'                            = [System.String[]];
            'Mandatory'                       = $true;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = @('ByName');
            'HelpMessage'                     = 'The name of the object.';
            'Alias'                           = $JCType.ByName | Where-Object { $_ -ne 'Name' } | Select-Object -Unique;
            'Position'                        = 1;
        }
        $Param_SearchBy = @{
            'Name'                            = 'SearchBy';
            'Type'                            = [System.String];
            'Mandatory'                       = $true;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = @('ByValue');
            'ValidateSet'                     = @('ById', 'ByName');
            'HelpMessage'                     = 'Specify how you want to search.';
            'DontShow'                        = $true;
            'Position'                        = 1;
        }
        $Param_SearchByValue = @{
            'Name'                            = 'SearchByValue';
            'Type'                            = [System.String[]];
            'Mandatory'                       = $true;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = @('ByValue');
            'HelpMessage'                     = 'Specify the item which you want to search for. Supports wildcard searches using: *';
            'DontShow'                        = $true;
            'Position'                        = 2;
        }
        $Param_Fields = @{
            'Name'                            = 'Fields';
            'Type'                            = [System.Array];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = @('ById', 'ByName', '__AllParameterSets');
            'HelpMessage'                     = 'An array of the fields/properties/columns you want to return from the search.';
            'Position'                        = 95;
        }
        $Param_Filter = @{
            'Name'                            = 'Filter';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ParameterSets'                   = @('ById', 'ByName', '__AllParameterSets');
            'HelpMessage'                     = 'Filters to narrow down search.';
            'ValidateScript'                  = {
                $FilterPattern = [regex]'.*?:.*?:.*?'
                If ($_ -notmatch $FilterPattern)
                {
                    Throw ('Invalid filter "' + $_ + '". Filter must match pattern: {PropertyName}:{Operator}:{Value} (' + $FilterPattern + ')')
                }
                Else
                {
                    $FilterParts = $_ -split ':'
                    $FilterProperties = ((($JCType.ByName, $JCType.ById) + $JCType.SystemInsights.ByName + $JCType.SystemInsights.ById) | Select-Object -Unique)
                    $FilterOperators = $JCType.FilterOperators + $JCType.SystemInsights.FilterOperators | Select-Object -Unique
                    If ($FilterParts[0] -notin $FilterProperties)
                    {
                        Throw ('Invalid filter property provided "' + $FilterParts[0] + '". Accepted filter properties: "' + ($FilterProperties -join ', ') + '"')
                    }
                    If ($FilterParts[1] -notin $FilterOperators)
                    {
                        Throw ('Invalid filter operator provided "' + $FilterParts[1] + '". Accepted filter operators: "' + ($FilterOperators -join ', ') + '"')
                    }
                    $true
                }
            };
            'Position'                        = 96;
        }
        $Param_Limit = @{
            'Name'                            = 'Limit';
            'Type'                            = [System.Int32];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateRange'                   = (1, [int]::MaxValue);
            'DefaultValue'                    = $JCType.Limit | Select-Object -Unique;
            'HelpMessage'                     = 'The number of items you want to return per API call.';
            'ParameterSets'                   = @('ById', 'ByName', '__AllParameterSets');
            'Position'                        = 97;
        }
        $Param_Skip = @{
            'Name'                            = 'Skip';
            'Type'                            = [System.Int32];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateRange'                   = (0, [int]::MaxValue);
            'DefaultValue'                    = $JCType.Skip | Select-Object -Unique;
            'HelpMessage'                     = 'The number of items you want to skip over per API call.';
            'ParameterSets'                   = @('ById', 'ByName', '__AllParameterSets');
            'Position'                        = 98;
        }
        $Param_Paginate = @{
            'Name'                            = 'Paginate';
            'Type'                            = [System.Boolean];
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $JCType.Paginate | Select-Object -Unique;
            'ValidateSet'                     = @($true, $false);
            'HelpMessage'                     = 'Whether or not you want to paginate through the results.';
            'ParameterSets'                   = @('ById', 'ByName', '__AllParameterSets');
            'Position'                        = 99;
        }
        # # Add conditional parameter settings
        # If ($Type -and -not $Force)
        # {
        #     # Determine if help files are being built
        #     If ((Get-PSCallStack).Command -like '*MarkdownHelp')
        #     {
        #         $JCObjectCount = 999999
        #     }
        #     Else
        #     {
        #         # Get count of JCObject to determine if script should load dynamic parameters
        #         $JCObjectCount = (Get-JCObject -Type:($Type) -ReturnCount).totalCount
        #     }
        # }
        # If ($Type -and -not $Force -and $JCObjectCount -le 300)
        # {
        #     # Populate DefaultValue and ValidateSets
        #     $JCObject = Get-JCObject -Type:($Type);
        #     $Param_Id.Add('DefaultValue', $JCObject.($JCObject.ById | Select-Object -Unique));
        #     $Param_Name.Add('DefaultValue', $JCObject.($JCObject.ByName | Select-Object -Unique));
        #     $Param_Id.Add('ValidateSet', @($JCObject.($JCObject.ById | Select-Object -Unique)));
        #     $Param_Name.Add('ValidateSet', @($JCObject.($JCObject.ByName | Select-Object -Unique)));
        #     If ($JCObjectCount -eq 1)
        #     {
        #         # Allow Id and Name to use the default value
        #         $Param_Id.Add('Mandatory', $false);
        #         $Param_Name.Add('Mandatory', $false);
        #     }
        #     ElseIf ($JCObjectCount -ge 1)
        #     {
        #         # Don't allow Id and Name to use the default value
        #         $Param_Id.Add('Mandatory', $true);
        #         $Param_Name.Add('Mandatory', $true);
        #     }
        # }
        # Else
        # {
        #     $Param_Id.Add('Mandatory', $true);
        #     $Param_Name.Add('Mandatory', $true);
        # }
        # Create another parameter set if an id or name is not required
        If ($Action -eq 'get')
        {
            $Param_Fields.ParameterSets += 'Default'
            $Param_Filter.ParameterSets += 'Default'
            $Param_Limit.ParameterSets += 'Default'
            $Param_Skip.ParameterSets += 'Default'
            $Param_Paginate.ParameterSets += 'Default'
        }
        # Build output
        $ParamVarPrefix = 'Param_'
        Get-Variable -Scope:('Local') | Where-Object { $_.Name -like '*' + $ParamVarPrefix + '*' } | Sort-Object { [int]$_.Value.Position } | ForEach-Object {
            # Add RuntimeDictionary to each parameter
            $_.Value.Add('RuntimeParameterDictionary', $RuntimeParameterDictionary)
            # Creating each parameter
            $VarName = $_.Name
            $VarValue = $_.Value
            Try
            {
                If ($Action -in ('add', 'new') -and $_.Name -in ('Param_Name')) # Can only add new objects by name
                {
                    New-DynamicParameter @VarValue | Out-Null
                }
                ElseIf ($Action -in ('remove') -and $_.Name -in ('Param_Id')) # Can only remove objects by id
                {
                    New-DynamicParameter @VarValue | Out-Null
                }
                ElseIf ($Action -in ('set') -and $_.Name -in ('Param_Id', 'Param_Name', 'Param_SearchBy', 'Param_SearchByValue' )) # Can set or update objects by id or name
                {
                    New-DynamicParameter @VarValue | Out-Null
                }
                ElseIf ($Action -eq 'get' -and $_.Name -in ('Param_Id', 'Param_Name', 'Param_SearchBy', 'Param_SearchByValue', 'Param_Fields', 'Param_Filter', 'Param_Limit', 'Param_Skip', 'Param_Paginate'))
                {
                    New-DynamicParameter @VarValue | Out-Null
                }
                ElseIf ($Action -in ('copy') -and $_.Name -in ('Param_Id', 'Param_Name'))
                {
                    New-DynamicParameter @VarValue | Out-Null
                }
            }
            Catch
            {
                Write-Error -Message:('Unable to create dynamic parameter:"' + $VarName.Replace($ParamVarPrefix, '') + '"; Error:' + $Error)
            }
        }
    }
    End
    {
        Return $RuntimeParameterDictionary
    }
}