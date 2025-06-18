function Get-JCRConfigFile {
    [CmdletBinding()]
    param (
        [Parameter(
            DontShow,
            HelpMessage = 'Returns Config.json with value, copy, write properties'
        )]
        [switch]
        $asObject
    )

    begin {
        $moduleRoot = $JCRScriptRoot
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'Config.json'

        if (-Not (Test-Path -Path $configFilePath)) {
            Write-Host "write new settings file $configFilePath"
            # Create new file with default settings
            New-JCRConfigFile
        }
    }

    process {
        if (-Not $asObject) {
            $rawConfig = Get-Content -Path $configFilePath | ConvertFrom-Json
            $config = @{}
            foreach ($item in $rawConfig.PSObject.Properties) {
                # $config.$item
                $config.Add($item.Name, @{})
                foreach ($setting in $item.value.PSObject.Properties) {
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