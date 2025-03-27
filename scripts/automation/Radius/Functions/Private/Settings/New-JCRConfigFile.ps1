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
        $ModuleRoot = (Get-Item -Path:($global:JCScriptRoot))
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'config.json'
        $date = (Get-Date).ToUniversalTime()
    }
    process {
        # Define Default Settings for the Config file
        $config = @{
            'userGroup'                 = @{value = $null; write = $true; copy = $true }
            'certSecretPass'            = @{value = $null; write = $true; copy = $true }
            'userCertValidityDays'      = @{value = 365; write = $true; copy = $true }
            'caCertValidityDays'        = @{value = 1095; write = $true; copy = $true }
            'certExpirationWarningDays' = @{value = 15; write = $true; copy = $true }
            'networkSSID'               = @{value = $null; write = $true; copy = $true }
            'certSubjectHeaders'        = @{
                'countryCode'      = @{value = $null; write = $true; copy = $true }
                'stateCode'        = @{value = $null; write = $true; copy = $true }
                'Locality'         = @{value = $null; write = $true; copy = $true }
                'Organization'     = @{value = $null; write = $true; copy = $true }
                'OrganizationUnit' = @{value = $null; write = $true; copy = $true }
                'CommonName'       = @{value = $null; write = $true; copy = $true }
            }
            'certType'                  = @{value = $null; write = $true; copy = $true }
            'radiusDirectory'           = @{value = $null; write = $true; copy = $true }
            'lastUpdate'                = @{value = $date; write = $true; copy = $true ;}
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
