Function Get-DynamicParamRadiusServer {
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The verb of the command calling it. Different verbs will make different parameters required.')][ValidateSet('add', 'get', 'new', 'remove', 'set')][System.String]$Action
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][System.String]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Bypass user prompts and dynamic ValidateSet.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    Begin {
        $RuntimeParameterDictionary = If ($Type) {
            Get-JCCommonParameters -Force:($Force) -Action:($Action) -Type:($Type);
        } Else {
            Get-JCCommonParameters -Force:($Force) -Action:($Action);
        }
    }
    Process {
        # Define the new parameters
        $Param_newName = @{
            'Name'                            = 'newName';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'HelpMessage'                     = 'The new name of the Radius Server.';
            'Position'                        = 3;
        }
        $Param_networkSourceIp = @{
            'Name'                            = 'networkSourceIp';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'HelpMessage'                     = 'The ip of the new Radius Server.';
            'Position'                        = 4;
        }
        $Param_sharedSecret = @{
            'Name'                            = 'sharedSecret';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ValidateLength'                  = @(1, 31);
            'HelpMessage'                     = 'The shared secret for the new Radius Server.';
            'Position'                        = 5;
            'ValidatePattern'                 = '^[a-zA-Z0-9!@#$%^&*]*$';
        }
        $Param_mfa = @{
            'Name'                            = 'mfa';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ValidateSet'                     = @("DISABLED", "ENABLED");
            'HelpMessage'                     = 'If MFA should be requried to authenticate to the RADIUS Server';
            'Position'                        = 6;
        }
        $Param_userLockoutAction = @{
            'Name'                            = 'userLockoutAction';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ValidateSet'                     = @("MAINTAIN", "REMOVE");
            'HelpMessage'                     = 'The behavior when user accounts get locked out';
            'Position'                        = 7;
        }
        $Param_userPasswordExpirationAction = @{
            'Name'                            = 'userPasswordExpirationAction';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ValidateSet'                     = @("MAINTAIN", "REMOVE");
            'HelpMessage'                     = 'The behavior when user accounts expire';
            'Position'                        = 8;
        }
        $Param_userAuthIdp = @{
            'Name'                            = 'authIdp';
            'Type'                            = [System.String];
            'ValueFromPipelineByPropertyName' = $true;
            'ValidateNotNullOrEmpty'          = $true;
            'ValidateSet'                     = @("AZURE", "JUMPCLOUD");
            'HelpMessage'                     = 'How your users will authenticate into this RADIUS server.';
            'Position'                        = 9;
        }
        If ($Action -in ('add', 'new')) {
            $Param_networkSourceIp.Add('Mandatory', $true);
            $Param_sharedSecret.Add('Default', ( -join ((0x21, 0x40, 0x5e, 0x2a) + (0x23..0x26) + (0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count:(31) | ForEach-Object { [char]$_ }) ));
        }
        # Build output
        $ParamVarPrefix = 'Param_'
        Get-Variable -Scope:('Local') | Where-Object { $_.Name -like '*' + $ParamVarPrefix + '*' } | Sort-Object { [int]$_.Value.Position } | ForEach-Object {
            # Add RuntimeDictionary to each parameter
            $_.Value.Add('RuntimeParameterDictionary', $RuntimeParameterDictionary)
            # Creating each parameter
            $VarName = $_.Name
            $VarValue = $_.Value
            Try {
                If ($Action -in ('add', 'new') -and $_.Name -in ('Param_networkSourceIp', 'Param_sharedSecret', 'Param_userAuthIdp')) {
                    New-DynamicParameter @VarValue | Out-Null
                } ElseIf ($Action -in ('remove') -and $_.Name -notin ('Param_newName', 'Param_networkSourceIp', 'Param_sharedSecret', 'Param_mfa', 'Param_userLockoutAction', 'Param_userPasswordExpirationAction', 'Param_userAuthIdp')) {
                    New-DynamicParameter @VarValue | Out-Null
                } ElseIf ($Action -in ('set') -and $_.Name -in ('Param_newName', 'Param_networkSourceIp', 'Param_sharedSecret', 'Param_mfa', 'Param_userLockoutAction', 'Param_userPasswordExpirationAction')) {
                    New-DynamicParameter @VarValue | Out-Null
                } ElseIf ($Action -eq 'get' -and $_.Name -notin ('Param_newName', 'Param_networkSourceIp', 'Param_sharedSecret', 'Param_mfa', 'Param_userLockoutAction', 'Param_userPasswordExpirationAction', 'Param_userAuthIdp')) {
                    New-DynamicParameter @VarValue | Out-Null
                }
            } Catch {
                Write-Error -Message:('Unable to create dynamic parameter:"' + $VarName.Replace($ParamVarPrefix, '') + '"; Error:' + $Error)
            }
        }
    }
    End {
        Return $RuntimeParameterDictionary
    }
}