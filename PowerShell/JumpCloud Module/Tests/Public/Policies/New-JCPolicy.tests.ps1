Describe -Tag:('JCPolicy') 'New-JCPolicy' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null

        $policies = Get-JCPolicy
        $policies | Where-Object { $_.Name -like "Pester -*" } | % { Remove-JcSdkPolicy -id $_.id }
        $policyTemplates = Get-JcSdkPolicyTemplate
    }

    Context 'Creates policies with dynamic parameters' {
        It 'Creates a new policy that tests textbox string' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "rename_local_administrator_account_windows" }
            $templateId = $policyTemplate.id
            $stringPolicy = New-JCPolicy -name "Pester - Textbox String" -templateID $templateId -ADMINISTRATORSTRING "Test String"
            # Should not be null
            $stringPolicy.values.value | Should -Be "Test String"
        }
        #TODO: Integer
        # It 'Creates a new policy that tests integer' {
        #     $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "lock_screen_darwin" }
        #     $templateId = $policyTemplate.id
        #     $intValue = 45
        #     $stringPolicy = New-JCPolicy -name "Pester - textbox" -templateID $templateId -inteValue $intValue
        #     # Should not be null
        #     $stringPolicy.values.value | Should -Be $intValue
        # }

        It 'Creates a new policy that tests boolean' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "allow_the_use_of_biometrics_windows" }
            $templateId = $policyTemplate.id
            $booleanPolicy = New-JCPolicy -name "Pester - Boolean" -templateID $templateId -ALLOWUSEOFBIOMETRICS $true
            # Should not be null???
            $booleanPolicy.values.value | Should -be $true
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
        It 'Creates a new policy that tests upload file' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_font_policy_darwin" }
            $templateId = $policyTemplate.id

            # Upload ps1 files for this test
            $firstFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select -First 1
            $fileBase64 = [convert]::ToBase64String((Get-Content -Path $firstFile.FullName -AsByteStream))

            # Add a new policy with file type:
            $newFilePolicy = New-JCPolicy -Name "Pester - File Test" -templateID $templateId -setFont $firstFile.FullName  -setName "Roboto Light"
            ($newFilePolicy.values | Where-Object { $_.configFieldName -eq "setFont" }).value | Should -Be $fileBase64
        }
        It 'Creates a new policy that select, string, boolean' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "app_notifications_darwin" }
            $templateId = $policyTemplate.id
            $policyName = "Pester Test Policy boolean"
            $multipleValPolicy = New-JCPolicy -name "Pester - Test multiple" -templateID $templateId -AlertType "Temporary Banner" -BundleIdentifier "Test" -PreviewType "Always" -BadgesEnabled $true
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
            $policyName = "Pester - Test Policy boolean"
            $firstPolicy = New-JCPolicy -name "Pester - value boolean" -templateID $templateId -ALLOWUSEOFBIOMETRICS $false
            $valuePolicy = New-JCPolicy -name "Pester - New Policy Value Boolean Test" -values $firstPolicy.values -templateID $templateId
            $valuePolicy.value.values | Should -Be $firstPolicy.value.values
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
            $valuePolicy = New-JCPolicy -name "Pester - new value registry test" -templateID $templateId -values $tablePolicy.values
            $valuePolicy.value.values | Should -Be $tablePolicy.value.values
        }
        It 'Creates a new policy that tests values upload file' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_font_policy_darwin" }
            $templateId = $policyTemplate.id

            # Upload ps1 files for this test
            $firstFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select -First 1

            # Add a new policy with file type:
            $newFilePolicy = New-JCPolicy -name "Pester - Values File" -templateID $templateId -setFont $firstFile.FullName -setName "Roboto Light"
            $valuePolicy = New-JCPolicy -name "Pester - Values Second Policy File" -templateID $templateId -values $newFilePolicy.values
            $valuePolicy.values.value | Should -Be $newFilePolicy.values.value
        }
        It 'Creates a new policy that tests values parameters string' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "rename_local_administrator_account_windows" }
            $templateId = $policyTemplate.id
            $newPolicy = New-JCPolicy -name "Pester - Test textbox" -templateID $templateId -ADMINISTRATORSTRING "Test String"
            # Should not be null
            $valuePolicy = New-JCPolicy -name "Pester - Values New Policy String Test" -templateID $templateId -values $newPolicy.values
            $valuePolicy.value.values | Should -Be $newPolicy.value.values
        }
    }
}