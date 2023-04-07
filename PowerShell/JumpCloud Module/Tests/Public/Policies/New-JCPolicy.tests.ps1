Describe -Tag:('JCPolicy') 'New-JCPolicy' {
    BeforeAll {
        Connect-JCOnline 6ef51a1f78e68ec71a06e00c6203e6b37795fe20 -force | Out-Null

        $policies = Get-JCPolicy
        $policies | Where-Object { $_.Name -like "Pester -*" } | % { Remove-JcSdkPolicy -id $_.id }
        $policyTemplates = Get-JcSdkPolicyTemplate
        #https://console.jumpcloud.com/#/configurations/configure/darwin/634583650757f90001431726
    }

    Context 'Creates policies with dynamic parameters' {
        It 'Creates a new policy that tests textbox string' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "rename_local_administrator_account_windows" }
            $templateId = $policyTemplate.id
            $stringPolicy = New-JCPolicy -name "Pester - textbox" -templateID $templateId -ADMINISTRATORSTRING "Test String"
            # Should not be null
            $stringPolicy.values.value | Should -Be "Test String"
        }
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
            $tablePolicy = New-JCPolicy -templateID $templateId -customRegTable $policyValueList -Name "Pester - Registry"
            $tablePolicy.values.value.count | Should -Be 1
        }
        It 'Creates a new policy that tests upload file' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_font_policy_darwin" }
            $templateId = $policyTemplate.id

            # Upload ps1 files for this test
            $firstFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select -First 1
            $fileBase64 = [convert]::ToBase64String((Get-Content -Path $firstFile.FullName -AsByteStream))

            # Add a new policy with file type:
            $newFilePolicy = New-JCPolicy -templateID $templateId -setFont $firstFile.FullName -Name "Pester - File Test" -setName "Roboto Light"
            ($newFilePolicy.values | Where-Object { $_.configFieldName -eq "setFont" }).value | Should -Be $fileBase64
        }
        It 'Creates a new policy that select, string, boolean' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "app_notifications_darwin" }
            $templateId = $policyTemplate.id
            $policyName = "Pester Test Policy boolean"
            $multipleValPolicy = New-JCPolicy -name "Test textbsdox" -templateID $templateId -AlertType "Temporary Banner" -BundleIdentifier "Test" -PreviewType "Always" -BadgesEnabled $true
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
            $tablePolicy = New-JCPolicy -templateID $templateId -customRegTable $policyValueList -Name "Pester - Registry"
            $valuePolicy = New-JCPolicy -name "Pester - new value registry test" -templateID $templateId -values $tablePolicy.values
            $valuePolicy.value.values | Should -Be $tablePolicy.value.values
        }
        It 'Creates a new policy that tests values upload file' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_font_policy_darwin" }
            $templateId = $policyTemplate.id

            # Upload ps1 files for this test
            $firstFile = Get-ChildItem $($PSScriptRoot) -Filter *.ps1 | Select -First 1

            # Add a new policy with file type:
            $newFilePolicy = New-JCPolicy -templateID $templateId -setFont $firstFile.FullName -Name "Pester - File Test" -setName "Roboto Light"

            $valuePolicy = New-JCPolicy -name "Pester - value file test" -templateID $templateId -values $newFilePolicy.values
            $valuePolicy.value.values | Should -Be $newFilePolicy.value.values
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