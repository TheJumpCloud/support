function Get-JCRConfigFile {
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
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.Parent.FullName
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'config.json'

        if (-Not (Test-Path -Path $configFilePath)) {
            Write-Host "write new settings file $configFilePath"
            # Create new file with default settings
            New-JCRConfigFile
        }

        # # confirm the config file is set with the required settings
        # Confirm-JCRConfigFile
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
            $config = $config.globalVars
        }
    }
    end {
        return $config
    }
}
