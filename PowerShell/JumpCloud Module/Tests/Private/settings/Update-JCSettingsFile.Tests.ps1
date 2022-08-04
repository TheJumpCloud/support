Describe -Tag "JCSettingsFile" -Name "Update JCSettings Tests" {
    it "Settings File can be modified" {
        # Get previous file modified Time
        $ReferenceConfig = (Get-Content -Path "$PSScriptRoot\..\..\..\Config.json" | ConvertFrom-Json)
        foreach ($property in $ReferenceConfig.psobject.properties) {
            foreach ($subProperty in $property.value.psobject.properties) {
                $subProperty.value.name
                $type = $subProperty.value.value.getType().name
                if ($type -eq 'Boolean') {
                    $subProperty.value.value = Get-Random -InputObject @($true, $false)
                } elseif ($type -eq 'Int64') {
                    $subProperty.value.value = Get-Random -InputObject @(1..64)
                }
            }
        }
        Update-JCSettingsFile -settings $ReferenceConfig
        # Get new config file:
        $newConfig = Get-JCSettingsFile -raw

        foreach ($newProperty in $newConfig.psobject.properties) {
            foreach ($referenceProperty in $ReferenceConfig.psobject.properties) {
                if ($newProperty.name -eq $referenceProperty.name) {
                    # If the new property is in the copied settings property list:
                    foreach ($newSubProperty in $newProperty.value.psobject.properties) {
                        foreach ($referenceSubProperty in $referenceProperty.value.psobject.properties) {
                            # If the property names match & the new property is eligible to be copied, verify it was copied
                            if (($($newSubProperty.Name) -eq $($referenceSubProperty.Name)) -AND ($newSubProperty.Value.copy -eq $true)) {
                                Write-host "Comparing $($newSubProperty.Name) Property"
                                Write-host "Reference: $($newSubProperty.Value.value) Should Be: $($referenceSubProperty.Value.value) "
                                $newSubProperty.Value.value | Should -Be $referenceSubProperty.Value.value
                            }
                        }
                    }
                }
            }
        }
    }
}
