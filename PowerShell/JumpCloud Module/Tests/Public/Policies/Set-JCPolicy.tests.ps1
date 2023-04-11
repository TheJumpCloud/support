Describe -Tag:('JCPolicy') 'Set-JCPolicy' {
    BeforeAll {
        . "$($PSSCRIPTROOT)/../../..//Private/Policies/Get-JCPolicyTemplateConfigField.ps1"
        # Clean Up Pester Policy Tests:
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        $policies = Get-JCPolicy
        $policies | Where-Object { $_.Name -like "Pester -*" } | % { Remove-JcSdkPolicy -id $_.id }
        $policyTemplates = Get-JcSdkPolicyTemplate
    }
    Context 'Sets policies using the dynamic parameter set' {
        BeforeAll {
            $policyTemplates = Get-JcSdkPolicyTemplate
        }
        It 'Sets a policy with a string/text type dynamic parameter' {
            # Define a policy with a string parameter
            # Policy 5ade0cfd1f24754c6c5dc9f2 Mac - Login Window Text Policy
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "login_window_text_darwin" }
            $templateId = $policyTemplate.id
            $PesterMacStringText = New-JCPolicy -Name "Pester - Mac - Login Window Text Policy" -templateID $templateId  -LoginwindowText "Pester Test"
            # define a text value to change the current value:
            $updateText = "Updated"
            # update the value with dynamic param
            $updatedPesterMacStringText = Set-JCPolicy -policyID $PesterMacStringText.id -LoginwindowText $updateText
            # orig policy def and new policy def should be different
            $updatedPesterMacStringText.values.value | Should -not -Be $PesterMacStringText.values.value
            # updated policy value should be equal to $updateText
            $updatedPesterMacStringText.values.value | Should -Be $updateText
        }
        #TODO: Uncomment
        # It 'Sets a  policy that tests integer' {
        #     $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "lock_screen_darwin" }
        #     $templateId = $policyTemplate.id
        #     $intValue = 45
        #     $stringPolicy = New-JCPolicy -name "Pester - textbox" -templateID $templateId -inteValue $intValue
        #     $updatedIntValue = 55
        #     $updatedStringPolicy = Set-JCPolicy -policyID $stringPolicy.id -inteValue $updatedIntValue
        #     # Should not be null
        #     $updatedStringPolicy.values.value | Should -Be $stringPolicy.values.value
        # }
        It 'Sets a policy with a boolean, multi select and string type dynamic parameter' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "app_notifications_darwin" }
            $templateId = $policyTemplate.id
            $PesterMacNotifySettings = New-JCPolicy -templateID $templateId -Name "Pester - Mac - App Notification Settings Policy" -AlertType None
            $PesterMacNotifySettingsTemplate = Get-JCPolicyTemplateConfigField -templateID $templateId
            # define a text value to change the current value:
            $updateText = "Updated"
            # update the value with dynamic param
            $UpdatedPesterMacNotifySettings = Set-JCPolicy -policyID $PesterMacNotifySettings.id -AlertType "Persistent Banner" -PreviewType "Never" -BadgesEnabled $true -ShowInNotificationCenter $true -BundleIdentifier $updateText -SoundsEnabled $true -CriticalAlertEnabled $true -ShowInLockScreen $true -NotificationsEnabled $true
            # the orig policy should have only set the AlertType, all other settings were set to the default value
            ($PesterMacNotifySettings.values | Where-Object { $_.configFieldName -eq "AlertType" }).value | Should -Be "0"
            $objsToTest = $PesterMacNotifySettingsTemplate.objectMap | Where-Object { $_.configFieldName -ne "AlertType" }
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

            $objsToTest = $PesterMacNotifySettingsTemplate.objectMap | Where-Object { $_.type -eq "boolean" }
            foreach ($obj in $objsToTest) {
                # write-host "$($PesterMacNotifySettings.values[$($obj.position) - 1].configFieldName) with value: $($PesterMacNotifySettings.values[$($obj.position) - 1].value) | Should be $($obj.defaultValue)"
                # test that the other values were set to the default value
                # test that each boolean type object in this policy is set to false
                $UpdatedBooleanPesterMacNotifySettings.values[$obj.position - 1].value | Should -Be $false
            }
        }
        It 'Sets a policy with a listbox, dynamic parameter' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "encrypted_dns_https_darwin" }
            $templateId = $policyTemplate.id
            $listboxPolicy = New-JCPolicy -Name "Pester - Mac - Encrypted DNS Policy" -templateID $templateId -ServerAddresses "Test Pester Address" -ServerURL "Test URL" -SupplementalMatchDomains "Test Domain"
            $listboxSet = Set-JCpolicy -policyid $listboxPolicy.Id -ServerAddresses "Test Pester Address1" -ServerURL "Test URL2" -SupplementalMatchDomains "Test Domain3"

            $listboxSet.values.value | Should -Be @('Test Pester Address1', 'Test URL2', 'Test Domain3')
        }
        It 'Sets a policy with a file, dynamic parameter' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_font_policy_darwin" }
            $templateId = $policyTemplate.id

            # Upload ps1 files for this test
            $firstFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select -First 1
            $secondFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select -Last 1


            # Add a new policy with file type:
            $newFilePolicy = New-JCPolicy -templateID 631f44bc2630c900017ed834 -setFont $firstFile.FullName -Name "Pester - File Test" -setName "Roboto Light"

            # Set the policy with a new file
            $convertFontFiletoB64 = [convert]::ToBase64String((Get-Content -Path $secondFile.FullName -AsByteStream))

            $setFontName = "Roboto Black"
            $updatedFilePolicy = Set-JCPolicy -policyID $newFilePolicy.id -setFont $secondFile.FullName -setName $setFontName
            $setFileBase64 = ($updatedFilePolicy.values | Where-Object { $_.configFieldName -eq "setFont" }).value
            $setName = ($updatedFilePolicy.values | Where-Object { $_.configFieldName -eq "setName" }).value

            # test that the file was updated
            $setFileBase64 | Should -Be $convertFontFiletoB64
            $setName | Should -Be $setFontName
        }
        # TODO: Check
        It 'Sets a policy with a table, dynamic parameter' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            $templateId = $policyTemplate.id
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
            $TablePolicy = New-JCPolicy -templateID $templateId -customRegTable $policyValueList -Name "Pester - Registry Table Set Test"
            # add another value to the policy
            $policyValue2 = [pscustomobject]@{
                'customData'      = 'data2'
                'customRegType'   = 'DWORD'
                'customLocation'  = 'location2'
                'customValueName' = 'CustomValue2'
            }
            $policyValue3 = [pscustomobject]@{
                'customData'      = 'data3'
                'customRegType'   = 'DWORD'
                'customLocation'  = 'location3'
                'customValueName' = 'CustomValue3'
            }
            # add new values to list
            $policyValueListSet = New-Object System.Collections.ArrayList
            $policyValueListSet.add($policyValue2)
            $policyValueListSet.add($policyValue3)
            $UpdatedTablePolicy = Set-JCPolicy -PolicyID $TablePolicy.id -customRegTable $policyValueListSet
            # Assert statements
            # value count for registry items should be correct
            $TablePolicy.values.value.count | Should -Be 1
            $TablePolicy.values.value[0].customLocation | Should -Be $policyValue.customLocation
            $TablePolicy.values.value[0].customValueName | Should -Be $policyValue.customValueName
            $TablePolicy.values.value[0].customData | Should -Be $policyValue.customData
            $TablePolicy.values.value[0].customRegType | Should -Be $policyValue.customRegType
            # value count for registry items should be correct
            $UpdatedTablePolicy.values.value.count | Should -Be 2
            # updated table should contain the orig value + new value
            $UpdatedTablePolicy.values.value[0].customLocation | Should -Be $policyValue2.customLocation
            $UpdatedTablePolicy.values.value[0].customValueName | Should -Be $policyValue2.customValueName
            $UpdatedTablePolicy.values.value[0].customData | Should -Be $policyValue2.customData
            $UpdatedTablePolicy.values.value[0].customRegType | Should -Be $policyValue2.customRegType
            $UpdatedTablePolicy.values.value[1].customLocation | Should -Be $policyValue3.customLocation
            $UpdatedTablePolicy.values.value[1].customValueName | Should -Be $policyValue3.customValueName
            $UpdatedTablePolicy.values.value[1].customData | Should -Be $policyValue3.customData
            $UpdatedTablePolicy.values.value[1].customRegType | Should -Be $policyValue3.customRegType
        }
    }
    Context 'Sets policies using the object values parameter set' {
        BeforeAll {
            $policyTemplates = Get-JcSdkPolicyTemplate
        }
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
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "allow_the_use_of_biometrics_windows" }
            $templateId = $policyTemplate.id
            $valuesAllowUseBiometrics = New-JCPolicy -templateID $templateId -Name "Pester - Boolean" -ALLOWUSEOFBIOMETRICS $false
            # Update the first text boolean value to true
            # Change the value
            $valuesAllowUseBiometrics.values[0].value = $true

            $updateAllowUserBiometrics = Set-JCPolicy -policyId $valuesAllowUseBiometrics.id -values $valuesAllowUseBiometrics.values
            # the policy should be updated from the policy values object
            $updateAllowUserBiometrics.values.value | Should -Be $true
        }
        It 'Sets a policy with a single value and does not overwrite unspecified values' {
            $resetPolicyByValue = New-JCPolicy -Name "Pester - Values Policy Set Values" -templateID 6308ccfc21c21b0001853799 -setIPAddress "1.2.3.4" -setPort "222" -setResourcePath "/this/path/" -setForceTLS $true
            $s = [PSCustomObject]@{
                configFieldID = "6308ccfc21c21b000185379a"
                value         = "128.138.220.205"
            }
            # Update the policy with only one value
            $updatedPolicy = Set-JCPolicy -policyID $resetPolicyByValue.id -Values $s
            # Only the first value should be changed
            $resetPolicyByValue.values[0].value | Should -Not -Be $updatedPolicy.values[0].value
            $updatedPolicy.values[0].value | Should -Be "128.138.220.205"
            # the remaining values should be the same and unchanged after this update
            $resetPolicyByValue.values[1].value | Should -Be $updatedPolicy.values[1].value
            $resetPolicyByValue.values[2].value | Should -Be $updatedPolicy.values[2].value
            $resetPolicyByValue.values[3].value | Should -Be $updatedPolicy.values[3].value
        }

        It 'Sets a policy using the values object where a policy has a multi selection type' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "system_preferences_panes_darwin" }
            $templateId = $policyTemplate.id
            $valuesSystemPreferenceControl = new-jcpolicy -templateID $templateId -name "Pester - Mac System Preference Control" -pipelineVariable 0 -appstore $false -icloud $true
            #Update the values to true
            $valuesSystemPreferenceControl.values | Where-Object { $_.configFieldName -eq "appstore" } | ForEach-Object { $_.value = $true }
            $valuesSystemPreferenceControl.values | Where-Object { $_.configFieldName -eq "icloud" } | ForEach-Object { $_.value = $false }
            $updatedValuesSystemPreferenceControl = Set-JCPolicy -policyID $valuesSystemPreferenceControl.id -values $valuesSystemPreferenceControl.values

            # the policy should be updated from the policy values object
            ($updatedValuesSystemPreferenceControl.values | Where-Object { $_.configFieldName -eq "appstore" }).value | Should -Be $true
            ($updatedValuesSystemPreferenceControl.values | Where-Object { $_.configFieldName -eq "icloud" }).value | Should -Be $false

        }

        It 'Sets a policy using the values object where a policy has a customRegTable type' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            $templateId = $policyTemplate.id
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
            $TablePolicy = New-JCPolicy -templateID $templateId -customRegTable $policyValueList -Name "Pester - Registry Values Set"
            # Update the first value from the orig policy
            $updateCustomDataString = "Updated Custom Data"
            #Replace the first value loop through
            $tablePolicy.values.value[0].customData = $updateCustomDataString

            $updatedTablePolicy = Set-JCPolicy -policyID $TablePolicy.id -values $TablePolicy.values
            # the policy should be updated from the policy values object
            $updatedTablePolicy.values.value.customData | Should -Be $updateCustomDataString
        }

    }
    Context 'Sets policies using the pipeline parameters' {
        BeforeAll {
            $policyTemplates = Get-JcSdkPolicyTemplate
        }
        It 'sets a policy using the pipeline input from New-JCPolicy where the policy has no payload' {
            # you should be able to set a policy with no payload
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "activation_lock_darwin" }
            $templateId = $policyTemplate.id
            $noPayloadPolicy = New-JCpolicy -Name "Pester - Pipeline Policy No Payload" -templateID $templateId
            $updatedNoPayloadPolicy = $noPayloadPolicy | Set-JCPolicy -NewName "Pester - Pipeline Policy No Payload Updated"
            # the name should be updated:
            $updatedNoPayloadPolicy.Name | Should -Be "Pester - Pipeline Policy No Payload Updated"
        }
        It 'Sets a policy using the pipeline input from Get-JCPolicy where the policy has a string payload' {
            # create a policy
            { $stringPayloadPolicy = New-JCPolicy -Name "Pester - Pipeline Policy String Bool Payload" -templateID 6308ccfc21c21b0001853799 -setIPAddress "1.1.1.1" -setPort "4333" -setResourcePath "/here/" -setForceTLS $true } | Should -Not -Throw
            # Get the policy object
            $policy = Get-JCPolicy -Name "Pester - Pipeline Policy String Bool Payload"
            # Update the policy name
            $updatedPolicy = $policy | Set-JCPolicy -NewName "Pester - Pipeline Policy String Bool Payload Updated"
            # policy name shoud be updated
            $updatedPolicy.name | Should -Be "Pester - Pipeline Policy String Bool Payload Updated"
        }
    }
}
