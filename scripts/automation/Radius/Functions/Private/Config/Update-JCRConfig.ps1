function Update-JCRConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]
        $settings
    )

    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $moduleRoot = $JCRScriptRoot
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        if (test-path -path $configFilePath) {
            # Get Contents
            $config = Get-JCRConfig -asObject
        } else {
            # Create new file with default settings
            New-JCRConfig
            $config = Get-JCRConfig -asObject
        }

        Write-Host "---------Update settings--------------"
        Write-Host "[status] Module Path : $($moduleCheck.Path)"
        Write-Host "[Status] JCRConfig Settings:"
        foreach ($setting in $settings.PSObject.Properties) {
            Write-Host ("$($setting.Name): $($setting.Value.value)")
        }
        Write-Host "-----------------------"
    }

    process {
        foreach ($newSetting in $config.PSObject.properties) {
            foreach ($copiedSetting in $settings.PSObject.properties) {
                if ($newSetting.name -eq $copiedSetting.name) {
                    Write-Host "Updating setting: $($newSetting.name)"
                    $newSettingValue = $newSetting.Value
                    $copiedSettingValue = $copiedSetting.Value

                    if ($newSettingValue.value -ne $copiedSettingValue.value) {
                        Write-Host "Old Value: $($newSettingValue.value) New Value: $($copiedSettingValue.value)"
                        $config.$($newSetting.name).value = $settings.$($copiedSetting.name).value
                    }


                    # # If the new property is in the copied settings property list:
                    # foreach ($newProperty in $newSetting.value.PSObject.properties) {
                    #     foreach ($copiedProperty in $copiedSetting.value.PSObject.properties) {
                    #         # If the property names match & the new property is eligible to be copied, copy it
                    #         if ( ($newProperty.name -eq $copiedProperty.name) -And ($newProperty.Value.copy -eq $true)) {
                    #             # If the values are different, copy the values
                    #             if ( $newProperty.value.value -ne $copiedProperty.value.value) {
                    #                 write-host "Copying property: $($newProperty.name) from $($copiedSetting.name) to $($newSetting.name)"
                    #                 Write-Host "Old Value: $($newProperty.value.value) New Value: $($copiedProperty.value.value)"
                    #                 $config.$($newsetting.name).$($newProperty.name).value = $settings.$($copiedSetting.name).$($copiedProperty.name).value
                    #             }
                    #         }
                    #     }
                    # }
                }
            }
        }
    }

    end {
        $config | ConvertTo-Json | Out-File -FilePath $configFilePath
    }
}
