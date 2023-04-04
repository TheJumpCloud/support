Describe -Tag:('JCPolicy') 'Set-JCPolicy' {
    BeforeAll {
        # Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        . "$($PSSCRIPTROOT)/../../..//Private/Policies/Get-JCPolicyTemplateConfigField.ps1"
    }
    Context 'Sets policies using the dynamic parameter set' {
        BeforeAll {
            # Test Setup:
            # Define a policy with a string parameter
            # Policy 5ade0cfd1f24754c6c5dc9f2 Mac - Login Window Text Policy
            $PesterMacStringText = New-JCPolicy -templateID 5ade0cfd1f24754c6c5dc9f2 -Name "Pester - Mac - Login Window Text Policy" -LoginwindowText "Pester Test"

            $PesterMacNotifySettings = New-JCPolicy -templateID 62a76bdbdbe570000196253b -Name "Pester - Mac - App Notification Settings Policy" -AlertType None
            $PesterMacNotifySettingsTemplate = Get-JCPolicyTemplateConfigField -templateID 62a76bdbdbe570000196253b
        }
        It 'Sets a policy with a string type dynamic parameter' {
            # define a text value to change the current value:
            $updateText = "Updated"
            # update the value with dynamic param
            $updatedPesterMacStringText = Set-JCPolicy -policyID $PesterMacStringText.id -LoginwindowText $updateText
            # orig policy def and new policy def should be different
            $updatedPesterMacStringText.values.value | Should -not -Be $PesterMacStringText.values.value
            # updated policy value should be equal to $updateText
            $updatedPesterMacStringText.values.value | Should -Be $updateText
        }
        It 'Sets a policy with a boolean, multi select and string type dynamic parameter' {
            # define a text value to change the current value:
            $updateText = "Updated"
            # update the value with dynamic param
            $UpdatedPesterMacNotifySettings = Set-JCPolicy -policyID $PesterMacNotifySettings.id -AlertType "Persistent Banner" -PreviewType "Never" -BadgesEnabled $true -ShowInNotificationCenter $true -BundleIdentifier $updateText -SoundsEnabled $true -CriticalAlertEnabled $true -ShowInLockScreen $true -NotificationsEnabled $true
            # the orig policy should have only set the AlertType, all other settings were set to the default value
            ($PesterMacNotifySettings.values | Where-Object { $_.configFieldName -eq "AlertType" }).value | Should -Be "0"
            $objsToTest = $PesterMacNotifySettingsTemplate | Where-Object { $_.configFieldName -ne "AlertType" }
            foreach ($obj in $objsToTest) {
                # write-host "$($PesterMacNotifySettings.values[$($obj.position) - 1].configFieldName) with value: $($PesterMacNotifySettings.values[$($obj.position) - 1].value) | Should be $($obj.defaultValue)"
                # test that the other values were set to the default value
                $PesterMacNotifySettings.values[$obj.position - 1].value | Should -Be $obj.defaultValue
            }
            # updated policy alertValue should be equal to 2
            ($UpdatedPesterMacNotifySettings.values | Where-Object { $_.configFieldName -eq "AlertType" }).value | Should -Be "2"
            # updated policy PreviewType should be equal to 2
            ($UpdatedPesterMacNotifySettings.values | Where-Object { $_.configFieldName -eq "PreviewType" }).value | Should -Be "2"
            # finally test that the policy boolean settings can be flipped to false
            $UpdatedBooleanPesterMacNotifySettings = Set-JCPolicy -policyID $PesterMacNotifySettings.id -BadgesEnabled $false -ShowInNotificationCenter $false -BundleIdentifier $updateText -SoundsEnabled $false -CriticalAlertEnabled $false -ShowInLockScreen $false -NotificationsEnabled $false

            $objsToTest = $PesterMacNotifySettingsTemplate | Where-Object { $_.type -eq "boolean" }
            foreach ($obj in $objsToTest) {
                # write-host "$($PesterMacNotifySettings.values[$($obj.position) - 1].configFieldName) with value: $($PesterMacNotifySettings.values[$($obj.position) - 1].value) | Should be $($obj.defaultValue)"
                # test that the other values were set to the default value
                # test that each boolean type object in this policy is set to false
                $UpdatedBooleanPesterMacNotifySettings.values[$obj.position - 1].value | Should -Be $false
            }
        }
        It 'Sets a policy with a listbox, dynamic parameter' {
            #TODO: implement test
        }
    }
    Context 'Sets policies using the values parameter set' {
        It 'sets a policy using the values object where a policy only has a string type' {
            $origText = "Pester Test"
            $updatedText = "Updated Pester Test"
            $valuesMacLoginPolicy = New-JCPolicy -templateID 5ade0cfd1f24754c6c5dc9f2 -Name "Pester - Mac - Login Window Text Policy - values" -LoginwindowText $origText
            # Update the first text value from the orig policy
            $valuesMacLoginPolicy.values[$valuesMacLoginPolicy.values.count - 1].value = $updatedText
            $updatedValuesMacLoginPolicy = Set-JCPolicy -policyID $valuesMacLoginPolicy.id -values $valuesMacLoginPolicy.values
            # the policy should be updated from the policy values object
            $updatedValuesMacLoginPolicy.values.value | Should -Be $updatedText
        }
        It 'Sets a policy using the values object where a policy has a boolean type' {
            # TODO: implement test
        }
        It 'Sets a policy using the values object where a policy has a singlelistbox type' {
            # TODO: implement test
        }
        It 'Sets a policy using the values object where a policy has a multi selection type' {
            # TODO: implement test
        }
        It 'Sets a policy using the values object where a policy has a multi table type' {
            # TODO: implement test
        }
        It 'Sets a policy using the values object where a policy has a multi customRegTable type' {
            # TODO: implement test
        }

    }
    Context 'Sets policies using the pipeline parameters' {
        It 'sets a policy using the pipeline input from Get-JCPolicy' {
            # TODO: implement test
        }
    }
}