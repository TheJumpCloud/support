Describe -Tag:('JCPolicy') 'Set-JCPolicy' {
    BeforeAll {
        . "$($PSSCRIPTROOT)/../../..//Private/Policies/Get-JCPolicyTemplateConfigField.ps1"

        $policies = Get-JCPolicy
        $policies | Where-Object { $_.Name -like "Pester -*" } | ForEach-Object { Remove-JcSdkPolicy -Id $_.id }
        $policyTemplates = Get-JcSdkPolicyTemplate
    }

    Context 'Set policy with a select/multi config with string or int' {
        BeforeAll {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "system_updates_windows" }
            $templateId = $policyTemplate.id
            $PesterWindowsWindowsUpdateConfig = New-JCPolicy -Name "Pester - Windows - Configure Windows" -templateID $templateId -AUTO_INSTALL_SCHEDULE ScheduledInstallFirstWeek
        }
        It 'Sets a policy with a string multi field' {
            # Update the policy with a new AUTO_INSTALL_SCHEDULE (this is a mult field)
            $stringMultiValue = "ScheduledInstallSecondWeek"
            $updateSchedule = Set-JCPolicy -id $PesterWindowsWindowsUpdateConfig.Id -AUTO_INSTALL_SCHEDULE $stringMultiValue

            # Get the value of the Field
            $fieldName = "AUTO_INSTALL_SCHEDULE"
            $index = 0
            for ($i = 0; $i -lt $updateSchedule.values.configFieldName.Count; $i++) {
                if ($updateSchedule.values.configFieldName[$i] -eq $fieldName) {
                    $index = $i
                    break
                }
            }
            $updateSchedule.values.value[$index] | Should -Be $stringMultiValue
        }
        It 'Sets a policy with a int multi field' {
            # Set the policy with an int multi field
            $intMultiValue = 2
            { Set-JCPolicy -id $PesterWindowsWindowsUpdateConfig.Id -AUTO_INSTALL_SCHEDULE $intMultiValue } | Should -Throw
        }
    }
    Context 'Sets policies using the dynamic parameter set using the ByID parameter set' {
        # Urilist
        It 'Sets a policy with multilist - custom windows mdm oma policy' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_oma_uri_mdm_windows" }
            $templateId = $policyTemplate.id
            # Add a new policy with multilist type:
            $uriList = @(
                @{ uri = "a"; format = "int"; value = 2 },
                @{ uri = "b"; format = "string"; value = "test" },
                @{ uri = "c"; format = "boolean"; value = "true" }, # Corrected: $true is the boolean literal
                @{ uri = "d"; format = "float"; value = 2.5 } # Corrected: 2.5 is the float literal
                @{ uri = "e"; format = "xml"; value = "<xml>test</xml>" },
                @{ uri = "f"; format = "base64"; value = "dGVzdA==" }
            )
            $testUriList = @(
                @{ uri = "testA"; format = "int"; value = 100 },
                @{ uri = "testB"; format = "string"; value = "example string" },
                @{ uri = "testC"; format = "boolean"; value = "false" },
                @{ uri = "testD"; format = "float"; value = 3.14159 },
                @{ uri = "testE"; format = "xml"; value = "<data><item>test data</item></data>" },
                @{ uri = "testF"; format = "base64"; value = "SGVsbG8gV29ybGQh" } # Base64 for "Hello World!"
            )
            $newPolicy = New-JCPolicy -templateID $templateId -Name "Pester - Windows - Custom MDM Policy" -uriList $uriList
            # Set the policy with a new multilist
            $setPolicy = Set-JCPolicy -PolicyID $newPolicy.id -uriList $testUriList
            # Assert statements
            # value count for registry items should be correct
            $newPolicy.values.value[0].value | Should -Be 100
            $newPolicy.values.value[1].value | Should -Be "example string"
            $newPolicy.values.value[2].value | Should -Be $false
            $newPolicy.values.value[3].value | Should -Be 3.14159
            $newPolicy.values.value[4].value | Should -Be "<data><item>test data</item></data>"
            $newPolicy.values.value[5].value | Should -Be "SGVsbG8gV29ybGQh"


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
            $updatedPesterMacStringText.values.value | Should -Not -Be $PesterMacStringText.values.value
            # updated policy value should be equal to $updateText
            $updatedPesterMacStringText.values.value | Should -Be $updateText
        }
        It 'Sets a  policy that tests integer' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "lock_screen_darwin" }
            $templateId = $policyTemplate.id
            $intValue = 45
            $intPolicy = New-JCPolicy -Name "Pester - Integer" -templateID $templateId -timeout $intValue
            $updatedIntValue = 55
            $updatedStringPolicy = Set-JCPolicy -policyID $intPolicy.id -timeout $updatedIntValue
            # Should not be null
            $updatedStringPolicy.values.value | Should -Be $updatedIntValue
        }
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
            # set should set the policies to the correct type
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.getType() | Should -BeOfType object
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.getType() | Should -BeOfType object
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'ServerURL' }).value.getType().Name | Should -BeOfType string
            # since we set only one value the count for each of these objects should be 1
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.count | Should -Be 1
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.count | Should -Be 1
            # add multiple values here and test
            $multipleServerAddresses = @("Test Pester Address1", "Test Pester Address2")
            $multipleSupplementalMatchDomains = @("Test Domain3", "Test Domain4")
            $listboxSetMultipleValues = Set-JCpolicy -policyid $listboxPolicy.Id -ServerAddresses $multipleServerAddresses -ServerURL "Test URL2" -SupplementalMatchDomains $multipleSupplementalMatchDomains
            # set should set the policies to the correct type
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.getType() | Should -BeOfType object
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.getType() | Should -BeOfType object
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'ServerURL' }).value.getType().Name | Should -BeOfType string
            # Count for listbox policy should be 2
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.count | Should -Be 2
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.count | Should -Be 2
            # validate that the items are correct:
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value | Should -Be $multipleServerAddresses
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value | Should -Be $multipleSupplementalMatchDomains

        }
        It 'Sets a policy with a file, dynamic parameter' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_font_policy_darwin" }
            $templateId = $policyTemplate.id

            # Upload ps1 files for this test
            $firstFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select-Object -First 1
            $secondFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select-Object -Last 1


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
    Context 'Sets policies using the dynamic parameter set using the ByName parameter set' {
        It 'Sets a policy with a string/text type dynamic parameter' {
            # Define a policy with a string parameter
            # Policy 5ade0cfd1f24754c6c5dc9f2 Mac - Login Window Text Policy
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "login_window_text_darwin" }
            $templateId = $policyTemplate.id
            $PesterMacStringText = New-JCPolicy -Name "Pester - Mac - Login Window Text Policy byName" -templateID $templateId  -LoginwindowText "Pester Test"
            # define a text value to change the current value:
            $updateText = "Updated"
            # update the value with dynamic param
            $updatedPesterMacStringText = Set-JCPolicy -PolicyName $PesterMacStringText.Name -LoginwindowText $updateText
            # orig policy def and new policy def should be different
            $updatedPesterMacStringText.values.value | Should -Not -Be $PesterMacStringText.values.value
            # updated policy value should be equal to $updateText
            $updatedPesterMacStringText.values.value | Should -Be $updateText
        }
        It 'Sets a policy that tests integer' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "lock_screen_darwin" }
            $templateId = $policyTemplate.id
            $intValue = 45
            $stringPolicy = New-JCPolicy -Name "Pester - Integer byName" -templateID $templateId -timeout $intValue
            $updatedIntValue = 55
            $updatedStringPolicy = Set-JCPolicy -PolicyName $stringPolicy.Name -timeout $updatedIntValue
            # Should not be null
            $updatedStringPolicy.values.value | Should -Be $updatedIntValue
        }
        It 'Sets a policy with a boolean, multi select and string type dynamic parameter' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "app_notifications_darwin" }
            $templateId = $policyTemplate.id
            $PesterMacNotifySettings = New-JCPolicy -templateID $templateId -Name "Pester - Mac - App Notification Settings Policy byName" -AlertType None
            $PesterMacNotifySettingsTemplate = Get-JCPolicyTemplateConfigField -templateID $templateId
            # define a text value to change the current value:
            $updateText = "Updated"
            # update the value with dynamic param
            $UpdatedPesterMacNotifySettings = Set-JCPolicy -PolicyName $PesterMacNotifySettings.Name -AlertType "Persistent Banner" -PreviewType "Never" -BadgesEnabled $true -ShowInNotificationCenter $true -BundleIdentifier $updateText -SoundsEnabled $true -CriticalAlertEnabled $true -ShowInLockScreen $true -NotificationsEnabled $true
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
            $listboxPolicy = New-JCPolicy -Name "Pester - Mac - Encrypted DNS Policy byName" -templateID $templateId -ServerAddresses "Test Pester Address" -ServerURL "Test URL" -SupplementalMatchDomains "Test Domain"
            $listboxSet = Set-JCpolicy -PolicyName $listboxPolicy.Name -ServerAddresses "Test Pester Address1" -ServerURL "Test URL2" -SupplementalMatchDomains "Test Domain3"
            # set should set the policies to the correct type
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.getType() | Should -BeOfType object
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.getType() | Should -BeOfType object
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'ServerURL' }).value.getType().Name | Should -BeOfType string
            # since we set only one value the count for each of these objects should be 1
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.count | Should -Be 1
            ($listboxSet.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.count | Should -Be 1
            # add multiple values here and test
            $multipleServerAddresses = @("Test Pester Address1", "Test Pester Address2")
            $multipleSupplementalMatchDomains = @("Test Domain3", "Test Domain4")
            $listboxSetMultipleValues = Set-JCpolicy -PolicyName $listboxPolicy.Name -ServerAddresses $multipleServerAddresses -ServerURL "Test URL2" -SupplementalMatchDomains $multipleSupplementalMatchDomains
            # set should set the policies to the correct type
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.getType() | Should -BeOfType object
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.getType() | Should -BeOfType object
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'ServerURL' }).value.getType().Name | Should -BeOfType string
            # Count for listbox policy should be 2
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.count | Should -Be 2
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.count | Should -Be 2
            # validate that the items are correct:
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value | Should -Be $multipleServerAddresses
            ($listboxSetMultipleValues.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value | Should -Be $multipleSupplementalMatchDomains
        }
        It 'Sets a policy with a file, dynamic parameter' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_font_policy_darwin" }
            $templateId = $policyTemplate.id

            # Upload ps1 files for this test
            $firstFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select-Object -First 1
            $secondFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select-Object -Last 1

            # Add a new policy with file type:
            $newFilePolicy = New-JCPolicy -templateID 631f44bc2630c900017ed834 -setFont $firstFile.FullName -Name "Pester - File Test byName" -setName "Roboto Light"

            # Set the policy with a new file
            $convertFontFiletoB64 = [convert]::ToBase64String((Get-Content -Path $secondFile.FullName -AsByteStream))

            $setFontName = "Roboto Black"
            $updatedFilePolicy = Set-JCPolicy -PolicyName $newFilePolicy.Name -setFont $secondFile.FullName -setName $setFontName
            $setFileBase64 = ($updatedFilePolicy.values | Where-Object { $_.configFieldName -eq "setFont" }).value
            $setName = ($updatedFilePolicy.values | Where-Object { $_.configFieldName -eq "setName" }).value

            # test that the file was updated
            $setFileBase64 | Should -Be $convertFontFiletoB64
            $setName | Should -Be $setFontName
        }
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
            $TablePolicy = New-JCPolicy -templateID $templateId -customRegTable $policyValueList -Name "Pester - Registry Table Set Test byName"
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
            $UpdatedTablePolicy = Set-JCPolicy -PolicyName $TablePolicy.Name -customRegTable $policyValueListSet
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
        It 'sets a policy using the values object where a policy only has a string type' {
            $origText = "Pester Test"
            $updatedText = "Updated Pester Test"
            $valuesMacLoginPolicy = New-JCPolicy -templateID 5ade0cfd1f24754c6c5dc9f2 -Name "Pester - Mac - Login Window Text Policy - values" -LoginwindowText $origText
            # Update the first text value from the original policy
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

            $resetPolicyByValue
            $resetPolicyByValue.values[0].value | Should -Not -Be $updatedPolicy.values[0].value
            # the policy IP address should be updated:
            ($updatedPolicy.values | where { $_.configFieldID -eq "6308ccfc21c21b000185379a" }).value | Should -Be "128.138.220.205"


            # the remaining values should be the same and unchanged after this update
            ($resetPolicyByValue.values | where { $_.configFieldID -eq "6308ccfc21c21b000185379b" }).value | Should -Be ($updatedPolicy.values | where { $_.configFieldID -eq "6308ccfc21c21b000185379b" }).value
            ($resetPolicyByValue.values | where { $_.configFieldID -eq "6308ccfc21c21b000185379c" }).value | Should -Be ($updatedPolicy.values | where { $_.configFieldID -eq "6308ccfc21c21b000185379c" }).value
            ($resetPolicyByValue.values | where { $_.configFieldID -eq "6308ccfc21c21b000185379d" }).value | Should -Be ($updatedPolicy.values | where { $_.configFieldID -eq "6308ccfc21c21b000185379d" }).value
        }

        It 'Sets a policy using the values object where a policy has a multi selection type' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "system_preferences_panes_darwin" }
            $templateId = $policyTemplate.id
            $valuesSystemPreferenceControl = new-jcpolicy -templateID $templateId -Name "Pester - Mac System Preference Control" -PipelineVariable 0 -appstore $false -icloud $true
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
            # Update the first value from the original policy
            $updateCustomDataString = "Updated Custom Data"
            #Replace the first value loop through
            $tablePolicy.values.value[0].customData = $updateCustomDataString

            $updatedTablePolicy = Set-JCPolicy -policyID $TablePolicy.id -values $TablePolicy.values
            # the policy should be updated from the policy values object
            $updatedTablePolicy.values.value.customData | Should -Be $updateCustomDataString
        }

    }
    Context 'Sets policies using the pipeline parameters' {
        It 'sets a policy using the pipeline input from New-JCPolicy where the policy has no payload' {
            # you should be able to set a policy with no payload
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "activation_lock_darwin" }
            $templateId = $policyTemplate.id
            $nameString = "Pester - Pipeline Policy No Payload $(new-randomString -NumberOfChars 8)"
            $noPayloadPolicy = New-JCpolicy -Name $nameString -templateID $templateId
            $updatedNoPayloadPolicy = $noPayloadPolicy | Set-JCPolicy -NewName "$($noPayloadPolicy.Name) Updated"
            # the name should be updated:
            $updatedNoPayloadPolicy.Name | Should -Be "$($noPayloadPolicy.Name) Updated"
        }
        It 'Sets a policy using the pipeline input from Get-JCPolicy where the policy has a string payload' {
            # create a policy
            $nameString = "Pester - Pipeline Policy String Bool Payload $(new-randomString -NumberOfChars 8)"
            $stringPayloadPolicy = New-JCPolicy -Name $nameString -templateID 6308ccfc21c21b0001853799 -setIPAddress "1.1.1.1" -setPort "4333" -setResourcePath "/here/" -setForceTLS $true
            # Get the policy object
            $policy = Get-JCPolicy -Name $stringPayloadPolicy.Name
            # Update the policy name
            $updatedPolicy = $policy | Set-JCPolicy -NewName "$($policy.Name) Updated"
            # policy name should be updated
            $updatedPolicy.name | Should -Be "$($policy.Name) Updated"
        }
    }
    Context 'Set-JCPolicy should reutrn policies with the correct data types' {
        It 'Set-JCPolicy returns expected parameters' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "disable_usb_storage_linux" }
            $usbLinuxPolicy = New-JCPolicy -TemplateID $registryTemplate.Id -Name "Pester - USB Linux $(new-randomString -NumberOfChars 8)" -disable_mtp $true -disable_afc $false -disable_mmc $false
            $usbLinuxPolicyUpdated = Set-JCPolicy -PolicyId $usbLinuxPolicy.Id -NewName "Pester - USB Linux $(new-randomString -NumberOfChars 8)" -Notes "usb"
            $usbLinuxPolicyUpdated.name | Should -Not -BeNullOrEmpty
            $usbLinuxPolicyUpdated.id | Should -Not -BeNullOrEmpty
            $usbLinuxPolicyUpdated.template | Should -Not -BeNullOrEmpty
            $usbLinuxPolicyUpdated.templateID | Should -Not -BeNullOrEmpty
            $usbLinuxPolicy.Notes | Should -BeNullOrEmpty
            $usbLinuxPolicyUpdated.Notes | Should -Be "usb"
        }
    }
    Context 'Validates Throw Conditions' {
        It 'Should throw an error when multiple policies with the same name exist and the policyName param is specified' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "disable_usb_storage_linux" }
            $randomValue = $(new-randomString -NumberOfChars 8)
            $usbLinuxPolicy = New-JCPolicy -TemplateID $registryTemplate.Id -Name "Pester - USB Linux $($randomValue)" -disable_mtp $true -disable_afc $false -disable_mmc $false
            $usbLinuxPolicy = New-JCPolicy -TemplateID $registryTemplate.Id -Name "Pester - USB Linux $($randomValue)" -disable_mtp $true -disable_afc $false -disable_mmc $false
            { Set-JCPolicy -PolicyName -Name "Pester - USB Linux $($randomValue)" -NewName "Pester - USB Linux $(new-randomString -NumberOfChars 8)" } | Should -Throw

        }
    }
    Context 'Update registry policy using Registry file' {
        It 'Set-JCPolicy using regFilePath parameter' {
            $registryPolicy = New-JCPolicy -Name "Pester - RegFileUpload $(new-randomString -NumberOfChars 8)" -templateId '5f07273cb544065386e1ce6f' -registryFile $PesterParams_RegistryFilePath

            $NewName = "Pester - RegFileUpload $(new-randomString -NumberOfChars 8)"

            $registryPolicyUpdated = Set-JCPolicy -PolicyID $registryPolicy.Id -NewName $NewName -registryFile $PesterParams_RegistryFilePath
            $registryPolicyUpdated.name | Should -Be $NewName
            $registryPolicyUpdated.templateID | Should -Be '5f07273cb544065386e1ce6f'
            $registryPolicyUpdated.values | Should -Not -BeNullOrEmpty
            $registryPolicyUpdated.values.value.count | Should -Be 10
            $registryPolicyUpdated.id | Should -Not -BeNullOrEmpty
            $registryPolicyUpdated.template | Should -Not -BeNullOrEmpty
        }
        It 'Set-JCPolicy using regFilePath parameter and RegisryOverwrite Parameter' {
            $registryPolicy = New-JCPolicy -Name "Pester - RegFileUpload $(new-randomString -NumberOfChars 8)" -templateId '5f07273cb544065386e1ce6f' -registryFile $PesterParams_RegistryFilePath

            $NewName = "Pester - RegFileUpload $(new-randomString -NumberOfChars 8)"

            $registryPolicyUpdated = Set-JCPolicy -PolicyID $registryPolicy.Id -NewName $NewName -registryFile $PesterParams_RegistryFilePath -RegistryOverwrite
            $registryPolicyUpdated.name | Should -Be $NewName
            $registryPolicyUpdated.templateID | Should -Be '5f07273cb544065386e1ce6f'
            $registryPolicyUpdated.values | Should -Not -BeNullOrEmpty
            $registryPolicyUpdated.values.value.count | Should -Be 5
            $registryPolicyUpdated.id | Should -Not -BeNullOrEmpty
            $registryPolicyUpdated.template | Should -Not -BeNullOrEmpty
        }
    }
    # Test for URIList - Custom Windows MDM OMA Policy
    # Context ''

    Context 'Manual Test Cases' -Skip {
        # These test cases should be executed locally; Each manual task should be executed when prompted to edit the policy
        It 'Policy with a string payload can be set interactivly' {
            # Create a policy
            $policyName = "Pester - Interactive $(new-randomString -NumberOfChars 8)"
            $newPolicy = New-JCPolicy -TemplateName darwin_Login_Window_Text -Name $policyName -LoginWindowText "New"
            # manual tasks
            # Update Login Window Text to a new value (not "New")
            $updatedPolicy = Set-JCPolicy -PolicyID $newPolicy.id
            # Value should be updated
            $updatedPolicy.values[0].value | Should -Not -Be $newPolicy.values[0].value
        }
        It 'Policy with a integer payload can be set interactivly' {
            # Create a policy
            $policyName = "Pester - Interactive $(new-randomString -NumberOfChars 8)"
            $newPolicy = New-JCPolicy -TemplateName darwin_Lock_Screen -Name $policyName -timeout "120"
            # manual tasks
            # Update Login timeout to a new value ("140")
            $updatedPolicy = Set-JCPolicy -PolicyID $newPolicy.id
            # Value should be updated
            $updatedPolicy.values[0].value | Should -Not -Be $newPolicy.values[0].value
        }
        It 'Policy with a integer payload can be set interactivly' {
            # Create a policy
            $policyName = "Pester - Interactive $(new-randomString -NumberOfChars 8)"
            $newPolicy = New-JCPolicy -TemplateName darwin_Login_Window_Controls -Name $policyName -SHOWFULLNAME $false
            # manual tasks
            # Update boolean to a new value ("$true")
            $updatedPolicy = Set-JCPolicy -PolicyID $newPolicy.id
            # Value should be updated from false to true
            $updatedPolicy.values[0].value | Should -Not -Be $newPolicy.values[0].value
            # Value should be boolean
            $updatedPolicy.values[0].value | Should -BeOfType boolean
        }
        It 'Policy with a listbox payload can be set interactivly' {
            # Create a policy
            $policyName = "Pester - Interactive $(new-randomString -NumberOfChars 8)"
            $newPolicy = New-JCPolicy -TemplateName darwin_Encrypted_DNS_over_HTTPS -Name $policyName -ServerAddresses "Test Pester Address" -ServerURL "Test URL" -SupplementalMatchDomains "Test Domain"
            # manual tasks:
            # Update server address to contain two values
            # update supplemental Match Domains to contain two values
            $updatedPolicy = Set-JCPolicy -PolicyID $newPolicy.id
            # Server addresses should have two values
            $updatedPolicy.values[0].value.count | Should -Be 2
            # supplemental Match Domains should have two values
            $updatedPolicy.values[2].value.count | Should -Be 2
        }
        It 'Policy with a multiSelect payload can be set interactivly' {
            # Create a policy
            $policyName = "Pester - Interactive $(new-randomString -NumberOfChars 8)"
            $newPolicy = New-JCPolicy -TemplateName darwin_App_Notification_Settings -Name $policyName -AlertType None -BadgesEnabled $true -BundleIdentifier "test" -CriticalAlertEnabled $true -NotificationsEnabled $true -PreviewType Never -ShowInNotificationCenter $true -SoundsEnabled $true -ShowInLockScreen $trueScreen $true
            # manual tasks:
            # Update AlertType from "None" to be "Persistent Banner"
            # Update Preview Type from "Never" to be "Always"
            $updatedPolicy = Set-JCPolicy -PolicyID $newPolicy.id
            # AlertType should be 0 == "Persistent Banner"
            $updatedPolicy.values[0].value | Should -Be 2
            # Preview Type should be 0 == "Always"
            $updatedPolicy.values[5].value | Should -Be 0
        }
        It 'Policy with a customRegTable payload can be set interactivly' {
            # Create a policy
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
            $policyName = "Pester - Interactive $(new-randomString -NumberOfChars 8)"
            $newPolicy = New-JCPolicy -TemplateName windows_Advanced:_Custom_Registry_Keys -Name $policyName -customRegTable $policyValueList
            # manual tasks:
            # add a two new rows of data
            # modify each of the values in the first row of data, they should not be the same text values used to create the policy
            # remove the second row (test that delete works)
            # policy should have two rows when saved
            $updatedPolicy = Set-JCPolicy -PolicyID $newPolicy.id
            # Validate tests
            # two rows of data
            $updatedPolicy.values.value.count | Should -Be 2
            # first row of data should have been changed
            $updatedPolicy.values.value[0].customData | Should -Not -Be $policyValue.customData
            $updatedPolicy.values.value[0].customRegType | Should -Not -Be $policyValue.customRegType
            $updatedPolicy.values.value[0].customLocation | Should -Not -Be $policyValue.customLocation
            $updatedPolicy.values.value[0].customValueName | Should -Not -Be $policyValue.customValueName
        }
    }
}
