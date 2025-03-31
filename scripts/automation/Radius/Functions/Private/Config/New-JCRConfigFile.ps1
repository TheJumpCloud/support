function New-JCRConfigFile {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'To Force Re-Creation of the Config file, set the $force parameter to $true'
        )]
        [switch]
        $force
    )

    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'config.json'
        $date = (Get-Date).ToUniversalTime()
    }
    process {
        # Define Default Settings for the Config file
        $config = @{
            "globalVars" = @{
                'userGroup'                         = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<UserGroupID>' }
                'certSecretPass'                    = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<CertPassword>' }
                'userCertValidityDays'              = @{value = 365; write = $true; copy = $true; required = $true; placeholder = '<365>' }
                'caCertValidityDays'                = @{value = 1095; write = $true; copy = $true; required = $true; placeholder = '<1095>' }
                'certExpirationWarningDays'         = @{value = 15; write = $true; copy = $true; required = $true; placeholder = '<15>' }
                'networkSSID'                       = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<networkSSID>' }
                'certSubjectHeaderCountryCode'      = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<US>' }
                'certSubjectHeaderStateCode'        = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<CO>' }
                'certSubjectHeaderLocality'         = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<Boulder>' }
                'certSubjectHeaderOrganization'     = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<JumpCloud>' }
                'certSubjectHeaderOrganizationUnit' = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<Customer_Tools>' }
                'certSubjectHeaderCommonName'       = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<JumpCloud.com>' }
                'certType'                          = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<EmailSAN/EmailDN/UsernameCn>' }
                'radiusDirectory'                   = @{value = $null; write = $true; copy = $true; required = $true; placeholder = '<Path/To/radiusDirectory>' }
                'lastUpdate'                        = @{value = $date; write = $false; copy = $true; required = $false; placeholder = $null }
            }
        }
    }
    end {
        if ((Test-Path -Path $configFilePath) -And ($force)) {
            $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        } else {
            $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        }
    }
}
