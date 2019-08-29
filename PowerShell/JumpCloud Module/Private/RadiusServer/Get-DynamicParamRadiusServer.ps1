Function Get-DynamicParamRadiusServer
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
    }
    Process
    {
        # Define the new parameters
        $Param_NetworkSourceIp = @{
            'Name'                            = 'NetworkSourceIp';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'HelpMessage'                     = 'The ip of the new Radius Server.';
        }
        $Param_SharedSecret = @{
            'Name'                            = 'SharedSecret';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'HelpMessage'                     = 'The shared secret for the new Radius Server.';
        }
        If ($Action -eq 'set')
        {
            $Param_NetworkSourceIp.Add('Mandatory', $true);
            $Param_NetworkSourceIp.Add('ValidateNotNullOrEmpty', $true)
        }
        If ($Action -eq 'new')
        {
            $Param_NetworkSourceIp.Add('Mandatory', $true);
            $Param_NetworkSourceIp.Add('ValidateNotNullOrEmpty', $true)
            $Param_SharedSecret.Add('Mandatory', $true);
            $Param_SharedSecret.Add('ValidateNotNullOrEmpty', $true)
            $Param_SharedSecret.Add('ValidateLength', @(1, 31))
        }
        # Build output
        $ParamVarPrefix = 'Param_'
        Get-Variable -Scope:('Local') | Where-Object { $_.Name -like '*' + $ParamVarPrefix + '*' } | ForEach-Object {
            # Add RuntimeDictionary to each parameter
            $_.Value.Add('RuntimeParameterDictionary', $RuntimeParameterDictionary)
            # Creating each parameter
            $VarName = $_.Name
            $VarValue = $_.Value
            Try
            {
                If ($Action -eq 'get' -and $_.Name -notin ('Param_NetworkSourceIp', 'Param_SharedSecret'))
                {
                    New-DynamicParameter @VarValue | Out-Null
                }
                ElseIf ($Action -ne 'get')
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