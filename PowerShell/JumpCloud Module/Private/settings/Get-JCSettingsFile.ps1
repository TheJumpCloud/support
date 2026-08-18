function Get-JCSettingsFile {
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
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        if (-Not (test-path -path $configFilePath)) {
            # Create new file with default settings
            New-JCSettingsFile
        }
    }

    process {
        $rawConfig = Get-Content -Path $configFilePath | ConvertFrom-Json

        if (-not ($rawConfig.PSObject.Properties.Name -contains 'vault')) {
            $rawConfig | Add-Member -NotePropertyName 'vault' -NotePropertyValue ([PSCustomObject]@{
                    Suffix = [PSCustomObject]@{ value = '.api.jc'; write = $true; copy = $true }
                })
            $rawConfig | ConvertTo-Json | Out-File -FilePath $configFilePath
        }

        if (-Not $raw) {
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
            $config = $rawConfig
        }
    }

    end {
        return $config
    }
}
