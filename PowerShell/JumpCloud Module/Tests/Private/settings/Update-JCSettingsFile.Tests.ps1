Describe -Tag "JCSettingsFile" -Name "Update JCSettings Tests" {
    It "Settings File can be modified" {
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
                            if (($($newSubProperty.Name) -eq $($referenceSubProperty.Name)) -and ($newSubProperty.Value.copy -eq $true)) {
                                Write-Host "Comparing $($newSubProperty.Name) Property"
                                Write-Host "Reference: $($newSubProperty.Value.value) Should Be: $($referenceSubProperty.Value.value) "
                                $newSubProperty.Value.value | Should -Be $referenceSubProperty.Value.value
                            }
                        }
                    }
                }
            }
        }
    }
    It "Adds new schema keys and current validateSet when upgrading from an older config" {
        # Simulate an older-release saved config that predates the authPreference setting and
        # carries a user-customized copy = true value.
        $oldConfig = (Get-Content -Path "$PSScriptRoot\..\..\..\Config.json" | ConvertFrom-Json)
        $oldConfig.psobject.properties.Remove('authPreference')
        $oldConfig.parallel.Override.value = $true

        Update-JCSettingsFile -settings $oldConfig
        $newConfig = Get-JCSettingsFile -raw

        # The newly introduced key is present even though the saved config lacked it, and its
        # validateSet reflects the current release defaults (New-JCSettingsFile is the source of truth).
        $newConfig.psobject.properties.Name | Should -Contain 'authPreference'
        $newConfig.authPreference.Method.validateSet | Should -Be 'apiKey clientSecret'
        # User-customized copy = true values still carry forward across the upgrade.
        $newConfig.parallel.Override.value | Should -Be $true
    }
}
