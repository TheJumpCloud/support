Describe -Tag:('JCPolicy') 'New-JCPolicy' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null

        $policies = Get-JCPolicy
        $policies | Where-Object { $_.Name -like "Pester -*" } | ForEach-Object { Remove-JcSdkPolicy -Id $_.id }
        $policyTemplates = Get-JcSdkPolicyTemplate
    }

    Context 'Creates policies with dynamic parameters' {
        It 'Creates a new policy that tests textbox string' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "rename_local_administrator_account_windows" }
            $templateId = $policyTemplate.id
            $stringPolicy = New-JCPolicy -Name "Pester - Textbox String" -templateID $templateId -ADMINISTRATORSTRING "Test String"
            # Should not be null
            $stringPolicy.values.value | Should -Be "Test String"
        }
        It 'Creates a new policy that tests integer' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "lock_screen_darwin" }
            $templateId = $policyTemplate.id
            $intValue = 45
            $intPolicy = New-JCPolicy -Name "Pester - Integer Dynamic" -templateID $templateId -timeout $intValue
            $intPolicy.values.value | Should -Be $intValue
        }

        It 'Creates a new policy that tests boolean' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "allow_the_use_of_biometrics_windows" }
            $templateId = $policyTemplate.id
            $booleanPolicy = New-JCPolicy -Name "Pester - Boolean" -templateID $templateId -ALLOWUSEOFBIOMETRICS $true
            # Should not be null???
            $booleanPolicy.values.value | Should -Be $true
        }
        It 'Creates a new policy that tests registry' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            $templateId = $policyTemplate.id
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
            $tablePolicy = New-JCPolicy -Name "Pester - Registry Test" -templateID $templateId -customRegTable $policyValueList
            $tablePolicy.values.value.count | Should -Be 1
        }
        It 'Creates a policy with a listbox using dynamic parameters' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "encrypted_dns_https_darwin" }
            $templateId = $policyTemplate.id
            $listboxPolicy = New-JCPolicy -Name "Pester - Mac - Encrypted DNS Policy New" -templateID $templateId -ServerAddresses "Test Pester Address" -ServerURL "Test URL" -SupplementalMatchDomains "Test Domain"
            # set should set the policies to the correct type
            ($listboxPolicy.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.getType() | Should -BeOfType object
            ($listboxPolicy.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.getType() | Should -BeOfType object
            ($listboxPolicy.values | Where-Object { $_.ConfigFieldName -eq 'ServerURL' }).value.getType().Name | Should -BeOfType string
            # since we set only one value the count for each of these objects should be 1
            ($listboxPolicy.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.count | Should -Be 1
            ($listboxPolicy.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.count | Should -Be 1
            # Create another policy w/ multiple values here and test
            $multipleServerAddresses = @("Test Pester Address1", "Test Pester Address2")
            $multipleSupplementalMatchDomains = @("Test Domain3", "Test Domain4")
            $listboxPolicyMultiple = New-JCPolicy -Name "Pester - Mac - Encrypted DNS Policy New Multiple" -templateID $templateId -ServerAddresses $multipleServerAddresses -ServerURL "Test URL" -SupplementalMatchDomains $multipleSupplementalMatchDomains
            # set should set the policies to the correct type
            ($listboxPolicyMultiple.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.getType() | Should -BeOfType object
            ($listboxPolicyMultiple.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.getType() | Should -BeOfType object
            ($listboxPolicyMultiple.values | Where-Object { $_.ConfigFieldName -eq 'ServerURL' }).value.getType().Name | Should -BeOfType string
            # Count for listbox policy should be 2
            ($listboxPolicyMultiple.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value.count | Should -Be 2
            ($listboxPolicyMultiple.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value.count | Should -Be 2
            # validate that the items are correct:
            ($listboxPolicyMultiple.values | Where-Object { $_.ConfigFieldName -eq 'ServerAddresses' }).value | Should -Be $multipleServerAddresses
            ($listboxPolicyMultiple.values | Where-Object { $_.ConfigFieldName -eq 'SupplementalMatchDomains' }).value | Should -Be $multipleSupplementalMatchDomains
        }
        It 'Creates a new policy that tests upload file' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_font_policy_darwin" }
            $templateId = $policyTemplate.id

            # Upload ps1 files for this test
            $firstFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select-Object -First 1
            $fileBase64 = [convert]::ToBase64String((Get-Content -Path $firstFile.FullName -AsByteStream))

            # Add a new policy with file type:
            $newFilePolicy = New-JCPolicy -Name "Pester - File Test" -templateID $templateId -setFont $firstFile.FullName  -setName "Roboto Light"
            ($newFilePolicy.values | Where-Object { $_.configFieldName -eq "setFont" }).value | Should -Be $fileBase64
        }
        It 'Creates a new policy that select, string, boolean' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "app_notifications_darwin" }
            $templateId = $policyTemplate.id
            $multipleValPolicy = New-JCPolicy -Name "Pester - Test multiple" -templateID $templateId -AlertType "Temporary Banner" -BundleIdentifier "Test" -PreviewType "Always" -BadgesEnabled $true
            #Test each param
            ($multipleValPolicy.values | Where-Object { $_.configFieldName -eq "AlertType" }).value | Should -Be 1 # 1 is the value for Temporary Banner on the dropdown
            ($multipleValPolicy.values | Where-Object { $_.configFieldName -eq "BundleIdentifier" }).value | Should -Be "Test"
            ($multipleValPolicy.values | Where-Object { $_.configFieldName -eq "PreviewType" }).value | Should -Be 0 # 0 is the value for Always on the dropdown
            ($multipleValPolicy.values | Where-Object { $_.configFieldName -eq "BadgesEnabled" }).value | Should -Be $true
        }
    }

    Context 'Creates policies using the value parameters' {
        It 'Creates a policy using the pipeline parameters boolean' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "allow_the_use_of_biometrics_windows" }
            $templateId = $policyTemplate.id
            $firstPolicy = New-JCPolicy -Name "Pester - value boolean" -templateID $templateId -ALLOWUSEOFBIOMETRICS $false
            $valuePolicy = New-JCPolicy -Name "Pester - New Policy Value Boolean Test" -values $firstPolicy.values -templateID $templateId
            $valuePolicy.value.values | Should -Be $firstPolicy.value.values
        }
        It 'Creates a new policy that tests integer' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "lock_screen_darwin" }
            $templateId = $policyTemplate.id
            $intValue = 45
            $firstIntPolicy = New-JCPolicy -Name "Pester - Integer Values" -templateID $templateId -timeout $intValue
            $valueIntPolicy = New-JCPolicy -Name "Pester - Value Integer" -templateID $templateId -Values $firstIntPolicy.values
            $valueIntPolicy.values.value | Should -Be $firstIntPolicy.values.value
        }
        It 'Creates a new policy that tests values registry' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            $templateId = $policyTemplate.id
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
            $tablePolicy = New-JCPolicy -Name "Pester - Registry value test" -templateID $templateId -customRegTable $policyValueList
            $valuePolicy = New-JCPolicy -Name "Pester - new value registry test" -templateID $templateId -values $tablePolicy.values
            $valuePolicy.value.values | Should -Be $tablePolicy.value.values
        }
        It 'Creates a new policy that tests values upload file' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_font_policy_darwin" }
            $templateId = $policyTemplate.id

            # Upload ps1 files for this test
            $firstFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select-Object -First 1

            # Add a new policy with file type:
            $newFilePolicy = New-JCPolicy -Name "Pester - Values File" -templateID $templateId -setFont $firstFile.FullName -setName "Roboto Light"
            $valuePolicy = New-JCPolicy -Name "Pester - Values Second Policy File" -templateID $templateId -values $newFilePolicy.values
            $valuePolicy.values.value | Should -Be $newFilePolicy.values.value
        }
        It 'Creates a new policy that tests values parameters string' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "rename_local_administrator_account_windows" }
            $templateId = $policyTemplate.id
            $newPolicy = New-JCPolicy -Name "Pester - Test textbox" -templateID $templateId -ADMINISTRATORSTRING "Test String"
            # Should not be null
            $valuePolicy = New-JCPolicy -Name "Pester - Values New Policy String Test" -templateID $templateId -values $newPolicy.values
            $valuePolicy.value.values | Should -Be $newPolicy.value.values
        }
    }
    Context 'New-JCPolicy should error on specific conditions' {
        It 'When a user enters an ID for PolicyID parameter for a non-existant policy' {
            { New-JCPolicy -templateID 123456 -Name "Pester - $(new-randomString -NumberOfChars 8)" } | Should -Throw
        }
        It 'When a user enters a name for TempalteName parameter for a non-existant policy' {
            { New-JCPolicy -templateName 123456 -Name "Pester - $(new-randomString -NumberOfChars 8)" } | Should -Throw
        }
        It 'When a user specifies a non-valid dynamicParameter' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "rename_local_administrator_account_windows" }
            $templateId = $policyTemplate.id
            { New-JCPolicy -Name "Pester - Test textbox $(new-randomString -NumberOfChars 8)" -templateID $templateId -fakeParam "Test String" } | Should -Throw
        }

    }
    Context 'Custom Registry Table validation tests' {
        It 'customRegTable param should throw if only a string is passed in' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable "string" -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
        }
        It 'customRegTable param should throw if a list of strings is passed in' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable @("string", "string2") -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
        }
        It 'customRegTable param should throw if a single object is passed in with incorrect data types' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            $data = @{random = 'someString'; customLocation = 'location'; customRegType = 'String'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
            $data = @{customData = 'someString'; random = 'location'; customRegType = 'String'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
            $data = @{customData = 'someString'; customLocation = 'location'; random = 'String'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'String'; random = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
        }
        It 'customRegTable param should not throw if a single object is passed in with correct data types' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'String'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Not -Throw
        }
        It 'customRegTable param should throw if a list of objects is passed in with incorrect data types' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            # Define list Values:
            $policyValueList = New-Object System.Collections.ArrayList
            $policyValue = [pscustomobject]@{
                'random'          = 'data'
                'customRegType'   = 'DWORD'
                'customLocation'  = 'location'
                'customValueName' = 'CustomValue'
            }
            $policyValue2 = [pscustomobject]@{
                'customData'      = 'data2'
                'customRegType'   = 'DWORD'
                'customLocation'  = 'location2'
                'customValueName' = 'CustomValue2'
            }
            $policyValueList.add($policyValue) | Out-Null
            $policyValueList.add($policyValue2) | Out-Null
            # New Policy
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $policyValueList -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw

        }
        It 'customRegTable param should not throw if a list of objects is passed in with correct data types' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            # Define list Values:
            $policyValueList = New-Object System.Collections.ArrayList
            $policyValue = [pscustomobject]@{
                'customData'      = 'customData'
                'customRegType'   = 'DWORD'
                'customLocation'  = 'location'
                'customValueName' = 'CustomValue'
            }
            $policyValue2 = [pscustomobject]@{
                'customData'      = 'data2'
                'customRegType'   = 'DWORD'
                'customLocation'  = 'location2'
                'customValueName' = 'CustomValue2'
            }
            $policyValueList.add($policyValue) | Out-Null
            $policyValueList.add($policyValue2) | Out-Null
            # New Policy
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $policyValueList -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Not -Throw
        }
        It 'customRegTable param should throw if an invalid customRegType is passed in' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'SZ'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'EXPAND_SZ'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'MULTI_SZ'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'RANDOM'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
        }
        It 'customRegTable param should not throw if an invalid customRegType is passed in' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'DWORD'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation DWORD $(new-randomString -NumberOfChars 8)" } | Should -Not -Throw
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'QWORD'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation QWORD $(new-randomString -NumberOfChars 8)" } | Should -Not -Throw
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'multiString'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation multiString $(new-randomString -NumberOfChars 8)" } | Should -Not -Throw
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'String'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation String $(new-randomString -NumberOfChars 8)" } | Should -Not -Throw
            $data = @{customData = 'someString'; customLocation = 'location'; customRegType = 'expandString'; customValueName = 'registryKeyValue' }
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $data -Name "Pester - Registry Validation expandString $(new-randomString -NumberOfChars 8)" } | Should -Not -Throw
        }
        It 'customRegTable param should throw if a list of objects is passed in with an invalid customRegType type' {
            $registryTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            # Define list Values:
            $policyValueList = New-Object System.Collections.ArrayList
            $policyValue = [pscustomobject]@{
                'customData'      = 'data'
                'customRegType'   = 'SZ'
                'customLocation'  = 'location'
                'customValueName' = 'CustomValue'
            }
            $policyValue2 = [pscustomobject]@{
                'customData'      = 'data2'
                'customRegType'   = 'DWORD'
                'customLocation'  = 'location2'
                'customValueName' = 'CustomValue2'
            }
            $policyValueList.add($policyValue) | Out-Null
            $policyValueList.add($policyValue2) | Out-Null
            # New Policy
            { New-JCPolicy -templateID $registryTemplate.id -customRegTable $policyValueList -Name "Pester - Registry Validation $(new-randomString -NumberOfChars 8)" } | Should -Throw
        }
    }
    Context 'New-JCPolicy should reutrn policies with the correct data types' {
        It 'New-JCPolicy returns expected parameters' {
            $usbTemplateLinux = $policyTemplates | Where-Object { $_.name -eq "disable_usb_storage_linux" }
            $usbLinuxPolicy = New-JCPolicy -TemplateID $usbTemplateLinux.Id -Name "Pester - USB Linux $(new-randomString -NumberOfChars 8)"
            $usbLinuxPolicy.name | Should -Not -BeNullOrEmpty
            $usbLinuxPolicy.id | Should -Not -BeNullOrEmpty
            $usbLinuxPolicy.values | Should -BeNullOrEmpty
            $usbLinuxPolicy.template | Should -Not -BeNullOrEmpty
            $usbLinuxPolicy.templateID | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Create new policy using Registry file' {
        It 'New-JCPolicy using regFilePath parameter' {
            $registryPolicy = New-JCPolicy -Name 'Pester - RegFileUpload' -registryFile $PesterParams_RegistryFilePath
            $registryPolicy.name | Should -Not -BeNullOrEmpty
            $registryPolicy.templateID | Should -Be '5f07273cb544065386e1ce6f'
            $registryPolicy.values | Should -Not -BeNullOrEmpty
            $registryPolicy.id | Should -Not -BeNullOrEmpty
            $registryPolicy.template | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Manual Test Cases' -Skip {
        It 'When you press *tab* after typing the TemplateName parameter, a list of policy templates are generated' {
            # manual tasks (press tab key in place of *tab*)
            # type New-JCPolicy -PolicyName *tab*
            # a list of templates should be visible
        }
    }
}
