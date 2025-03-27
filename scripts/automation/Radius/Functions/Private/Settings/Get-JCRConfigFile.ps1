function Get-JCRSettingsFile {
    [CmdletBinding()]
    param (
        [Parameter(
            DontShow,
            HelpMessage = 'Returns Config.json with value, copy, write properties'
        )]
        [switch]
        $raw
    )

    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($global:JCScriptRoot))
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'settings.json'

        if (-Not (Test-Path -Path $configFilePath)) {
            Write-Host "write new settings file $configFilePath"
            # Create new file with default settings
            New-JCRSettingsFile
        }
    }

    process {
        if (-Not $raw) {
            $rawConfig = Get-Content -Path $configFilePath | ConvertFrom-Json
            $config = @{}
            foreach ($item in $rawConfig.psobject.Properties) {
                # $config.$item
                $config.Add($item.Name, @{})
                foreach ($setting in $item.value.psobject.Properties) {
                    # $setting
                    $config.$($Item.Name).Add($setting.Name, $setting.value.value)
                }
            }
        } else {
            # Get Contents
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json
        }
    }

    end {
        return $config
    }
}
