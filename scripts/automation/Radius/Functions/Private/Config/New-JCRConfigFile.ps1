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
                'userGroup'                         = @{value = $null; write = $true; copy = $true }
                'certSecretPass'                    = @{value = $null; write = $true; copy = $true }
                'userCertValidityDays'              = @{value = 365; write = $true; copy = $true }
                'caCertValidityDays'                = @{value = 1095; write = $true; copy = $true }
                'certExpirationWarningDays'         = @{value = 15; write = $true; copy = $true }
                'networkSSID'                       = @{value = $null; write = $true; copy = $true }
                'certSubjectHeaderCountryCode'      = @{value = $null; write = $true; copy = $true }
                'certSubjectHeaderStateCode'        = @{value = $null; write = $true; copy = $true }
                'certSubjectHeaderLocality'         = @{value = $null; write = $true; copy = $true }
                'certSubjectHeaderOrganization'     = @{value = $null; write = $true; copy = $true }
                'certSubjectHeaderOrganizationUnit' = @{value = $null; write = $true; copy = $true }
                'certSubjectHeaderCommonName'       = @{value = $null; write = $true; copy = $true }
                'certType'                          = @{value = $null; write = $true; copy = $true }
                'radiusDirectory'                   = @{value = $null; write = $true; copy = $true }
                'lastUpdate'                        = @{value = $date; write = $false; copy = $true ;}
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
