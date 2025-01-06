function New-JCRSettingsFile {
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
        $configFilePath = join-path -path $ModuleRoot -childpath 'settings.json'

    }
    process {
        # Define Default Settings for the Config file
        $date = Get-Date
        $config = @{
            'globalVars' = @{
                'lastUpdate' = @{value = $date; write = $true; copy = $true ;
                }
            }
        }
    }
    end {
        if ((test-path -Path $configFilePath) -And ($force)) {
            $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        } else {
            $config | ConvertTo-Json | Out-File -FilePath $configFilePath
        }
    }
}
