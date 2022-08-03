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
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $configFilePath) {
            # Get Contents
            $config = Get-Content -Path $configFilePath | ConvertFrom-Json
        } else {
            # Create new file with default settings
            New-JCSettingsFile
        }
    }

    process {
        foreach ($newSetting in $config.psobject.properties) {
            foreach ($copiedSetting in $settings.psobject.properties) {
                if ($newSetting.name -eq $copiedSetting.name) {
                    # If the new property is in the copied settings property list:
                    foreach ($newProperty in $newSetting.value.psobject.properties) {
                        foreach ($copiedProperty in $copiedSetting.value.psobject.properties) {
                            # If the property names match & the new property is eligible to be copied, copy it
                            if ( ($newProperty.name -eq $copiedProperty.name) -And ($newProperty.Value.copy -eq $true)) {
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
        $config | ConvertTo-Json | Out-FIle -path $configFilePath
    }
}