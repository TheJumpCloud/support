Describe -Tag:('JCPolicy') 'Set-JCPolicy' {
    BeforeAll {
        # Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        . "$($PSSCRIPTROOT)/../../..//Private/Policies/Get-JCPolicyTemplateConfigField.ps1"
        # Clean Up Pester Policy Tests:
        $policies = Get-JCPolicy
        $policies | Where-Object { $_.Name -like "Pester -*" } | % { Remove-JcSdkPolicy -id $_.id }
    }
    Context 'Sets policies using the dynamic parameter set' {
        BeforeAll {
            # Test Setup:
            # Define a policy with a string parameter
            # Policy 5ade0cfd1f24754c6c5dc9f2 Mac - Login Window Text Policy
            $PesterMacStringText = New-JCPolicy -templateID 5ade0cfd1f24754c6c5dc9f2 -Name "Pester - Mac - Login Window Text Policy" -LoginwindowText "Pester Test"

            $PesterMacNotifySettings = New-JCPolicy -templateID 62a76bdbdbe570000196253b -Name "Pester - Mac - App Notification Settings Policy" -AlertType None
            $PesterMacNotifySettingsTemplate, $defaultPesterMacNotifySettingsTempalteName = Get-JCPolicyTemplateConfigField -templateID 62a76bdbdbe570000196253b
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
        It 'Sets a policy with a table, dynamic parameter' {
            # Add a new policy with table type:
            # Define a list
            $policyValueList = New-Object System.Collections.ArrayList
            # Define list Values:
            $policyValue = [pscustomobject]@{
                'customData'      = 'data'
                'customRegType'   = 'DWORD'
                'customLocation'  = 'location'
                'customValueName' = 'CustomValue'
            }
            # add values to list
            $policyValueList.add($policyValue)
            # create the policy
            $TablePolicy = New-JCPolicy -templateID 5f07273cb544065386e1ce6f -customRegTable $policyValueList -Name "Pester - Registry"
            # add another value to the policy
            $policyValue2 = [pscustomobject]@{
                'customData'      = 'data2'
                'customRegType'   = 'DWORD'
                'customLocation'  = 'location2'
                'customValueName' = 'CustomValue2'
            }
            # add new values to list
            $policyValueList.add($policyValue2)
            $UpdatedTablePolicy = Set-JCPolicy -PolicyID $TablePolicy.id -customRegTable $policyValueList
            # Assert statements
            # there should be two values in the registry table list
            $UpdatedTablePolicy.values.value.count | Should -Be 2

        }
        It 'Sets a policy with a file, dynamic parameter' {
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
            $valuesAllowUseBiometrics = New-JCPolicy -templateID !CHANGE -Name "Pester - Boolean" -ALLOWUSEOFBIOMETRICS $false
            # Update the first text boolean value to true
            # Change the value
            $valuesAllowUseBiometrics.values.value = $true
            $updateAllowUserBiometrics = Set-JCPolicy -templateId $valuesAllowUseBiometrics.id -values $valuesAllowUseBiometrics.values
            # the policy should be updated from the policy values object
            $updateAllowUserBiometrics.values.value | Should -Be $true
        }
        It 'Sets a policy using the values object where a policy has a file type' {
            # first add a policy with a file payload
        }
        It 'Sets a policy using the values object where a policy has a singlelistbox type' {
            # TODO: implement test
        }

        #TODO: NEED TO TEST
        It 'Sets a policy using the values object where a policy has a multi selection type' {
            $valuesSystemPreferenceControl = new-jcpolicy -templateID !CHANGe -name "Pester - Mac System Preference Control" -pipelineVariable 0 -appstore $false -icloud $true
            #Update the values to true
            $valuesSystemPreferenceControl.values | Where-Object { $_.configFieldName -eq "appstore" } | ForEach-Object { $_.value = $true }
            $valuesSystemPreferenceControl.values | Where-Object { $_.configFieldName -eq "icloud" } | ForEach-Object { $_.value = $false }
            $updatedValuesSystemPreferenceControl = Set-JCPolicy -policyID $valuesSystemPreferenceControl.id -values $valuesSystemPreferenceControl.values

            # the policy should be updated from the policy values object
            ($updatedValuesSystemPreferenceControl.values | Where-Object { $_.configFieldName -eq "appstore" }).value | Should -Be $true
            ($updatedValuesSystemPreferenceControl.values | Where-Object { $_.configFieldName -eq "icloud" }).value | Should -Be $true

        }
        It 'Sets a policy using the values object where a policy has a table type' {
            # TODO: implement test
        }
        It 'Sets a policy using the values object where a policy has a customRegTable type' {
            # TODO: implement test
        }

    }
    Context 'Sets policies using the pipeline parameters' {
        It 'sets a policy using the pipeline input from New-JCPolicy where the policy has no payload' {
            # you should be able to set a policy with no payload
            # TODO: this errors, should we include a $templateID in the New/Set-JCpolicy output so we can always pipe to another function?
            { $noPayloadPolicy = New-JCpolicy -Name "Pester - Pipeline Policy No Payload" -templateID 60636bce232e115560b632e9 } | Should -Not -Throw
            $updatedNoPayloadPolicy = $noPayloadPolicy | Set-JCPolicy -Name "Pester - Pipeline Policy No Payload Updated"
            # the name should be updated:
            $updatedNoPayloadPolicy.Name | Should -Be "Pester - Pipeline Policy No Payload Updated"
        }
        It 'Sets a policy using the pipeline inpput from Get-JCPolicy where the policy has a string payload' {
            # create a policy
            { $stringPayloadPolicy = New-JCPolicy -Name "Pester - Pipeline Policy String Bool Payload" -templateID 6308ccfc21c21b0001853799 -setIPAddress "1.1.1.1" -setPort "4333" -setResourcePath "/here/" -setForceTLS $true } | Should -Not -Throw
            # Get the policy object
            $policy = Get-JCPolicy -Name "Pester - Pipeline Policy String Bool Payload"
            # Update the policy name
            $updatedPolicy = $policy | Set-JCPolicy -Name "Pester - Pipeline Policy String Bool Payload Updated"
            # policy name shoud be updated
            $updatedPolicy.name | Should -Be "Pester - Pipeline Policy String Bool Payload Updated"
        }
    }
}
