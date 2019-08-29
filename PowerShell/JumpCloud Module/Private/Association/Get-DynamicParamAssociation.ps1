Function Get-DynamicParamAssociation
{
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The verb of the command calling it. Different verbs will make different parameters required.')][ValidateSet('add', 'get', 'new', 'remove', 'set')][System.String]$Action
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][System.String]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Bypass user prompts and dynamic ValidateSet.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    Begin
    {
        $RuntimeParameterDictionary = If ($Type)
        {
            Get-JCCommonParameters -Force:($Force) -Action:($Action) -Type:($Type);
        }
        Else
        {
            Get-JCCommonParameters -Force:($Force) -Action:($Action);
        }
        # Get type list
        $JCType = If ($Type)
        {
            Get-JCType -Type:($Type) | Where-Object { $_.Category -eq 'JumpCloud' };
        }
        Else
        {
            Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' };
        }
    }
    Process
    {
        # Define the new parameters
        $Param_TargetType = @{
            'Name'                            = 'TargetType';
            'Type'                            = [System.String[]];
            'Mandatory'                       = $false;
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'Alias'                           = ('TargetSingular');
            'HelpMessage'                     = 'The type of the target object.';
            'ValidateSet'                     = $JCType.Targets.TargetSingular | Select-Object -Unique;
            'DefaultValue'                    = $JCType.Targets.TargetSingular | Select-Object -Unique;
        }
        $Param_associationType = @{
            'Name'                            = 'associationType';
            'Type'                            = [System.String[]];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateSet'                     = @("direct", "direct`/indirect", "indirect");
            'DontShow'                        = $true;
            'HelpMessage'                     = 'Used for piping only to determine type of association when coming from Add-JCAssociation or Remove-JCAssociation.';
            'Mandatory'                       = $false;
        }
        $Param_Raw = @{
            'Name'                            = 'Raw';
            'Type'                            = [Switch];
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'DontShow'                        = $true;
            'HelpMessage'                     = 'Returns the raw and unedited output from the api endpoint.';
        }
        $Param_Direct = @{
            'Name'                            = 'Direct';
            'Type'                            = [Switch];
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Returns only "Direct" associations.';
        }
        $Param_Indirect = @{
            'Name'                            = 'Indirect';
            'Type'                            = [Switch];
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Returns only "Indirect" associations.';
        }
        $Param_IncludeInfo = @{
            'Name'                            = 'IncludeInfo';
            'Type'                            = [Switch];
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Appends "Info" and "TargetInfo" properties to output.';
        }
        $Param_IncludeNames = @{
            'Name'                            = 'IncludeNames';
            'Type'                            = [Switch];
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Appends "Name" and "TargetName" properties to output.';
        }
        $Param_IncludeVisualPath = @{
            'Name'                            = 'IncludeVisualPath';
            'Type'                            = [Switch];
            'ValueFromPipelineByPropertyName' = $true;
            'DefaultValue'                    = $false;
            'HelpMessage'                     = 'Appends "visualPathById", "visualPathByName", and "visualPathByType" properties to output.';
        }
        $Param_TargetId = @{
            'Name'                            = 'TargetId';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'HelpMessage'                     = 'The unique id of the target object.';
        }
        $Param_TargetName = @{
            'Name'                            = 'TargetName';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'HelpMessage'                     = 'The name of the target object.';
        }
        $Param_Attributes = @{
            'Name'                            = 'Attributes';
            'Type'                            = [System.Management.Automation.PSObject];
            'ValueFromPipelineByPropertyName' = $true;
            'Alias'                           = 'compiledAttributes';
            'HelpMessage'                     = 'Add attributes that define the association such as if they are an admin.';
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
                If ($_.Name -eq 'Param_TargetType')
                {
                    New-DynamicParameter @VarValue | Out-Null
                }
                If ($Action -eq 'get' -and $_.Name -in ('Param_Raw', 'Param_Direct', 'Param_Indirect', 'Param_IncludeInfo', 'Param_IncludeNames', 'Param_IncludeVisualPath'))
                {
                    New-DynamicParameter @VarValue | Out-Null
                }
                ElseIf ($Action -in ('add', 'remove') -and $_.Name -in ('Param_TargetId', 'Param_TargetName', 'Param_associationType'))
                {
                    New-DynamicParameter @VarValue | Out-Null
                }
                ElseIf ($Action -eq 'add' -and $_.Name -in ('Param_Attributes'))
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