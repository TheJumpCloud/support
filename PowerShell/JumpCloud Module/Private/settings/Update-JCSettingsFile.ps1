function Update-JCSettingsFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]
        $settings
    )

    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'Config.json'

        # Base the merge on the CURRENT release's defaults, not the file on disk. This makes the
        # schema auto-update across upgrades: newly added settings keys and changed metadata
        # (e.g. validateSet) come from New-JCSettingsFile, while user values are layered back on
        # below for any property flagged copy = $true.
        New-JCSettingsFile -force
        $config = Get-JCSettingsFile -Raw
    }

    process {
        foreach ($newSetting in $config.psobject.properties) {
            foreach ($copiedSetting in $settings.psobject.properties) {
                if ($newSetting.name -eq $copiedSetting.name) {
                    # If the new property is in the copied settings property list:
                    foreach ($newProperty in $newSetting.value.psobject.properties) {
                        foreach ($copiedProperty in $copiedSetting.value.psobject.properties) {
                            # If the property names match & the new property is eligible to be copied, copy it
                            if ( ($newProperty.name -eq $copiedProperty.name) -and ($newProperty.Value.copy -eq $true)) {
                                # If the values are different, copy the values
                                if ( $newProperty.value.value -ne $copiedProperty.value.value) {
                                    $config.$($newsetting.name).$($newProperty.name).value = $settings.$($copiedSetting.name).$($copiedProperty.name).value
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    end {
        $config | ConvertTo-Json | Out-File -FilePath $configFilePath
    }
}