Describe -Tag:('JCPolicy') 'New-JCPolicy' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null

        # Clean Up Pester Policy Tests:
        $headers = @{}
        $headers.Add("x-org-id", $PesterParams_OrgId)
        $headers.Add("x-api-key", $PesterParams_ApiKey)
        #TODO: Pester - name
        #LIstbox https://console.jumpcloud.com/#/configurations/configure/darwin/62e2ae60ab9878000167ca7a
        # Set-JCpolicy -policyid adsfklsdf -singleListBoxPolicy @('1','2','3')
        $policyTemplates = Get-JcSdkPolicyTemplate
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
            $booleanPolicy = New-JCPolicy -name "Test textbox" -templateID $templateId -ALLOWUSEOFBIOMETRICS $true
            # Should not be null???
            $booleanPolicy.values.value | Should -be $true
        }
        #TODO: Registry
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
            $tablePolicy | Should -Be 1
        }
        #TODO
        It 'Creates a new policy that tests upload file' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_mdm_profile_darwin" }
            $templateId = $policyTemplate.id
            $newPolicy = New-JCPolicy -name "Test file" -templateID $templateId -file ???
            # Should not be null???
            $newPolicy | Should -Not -BeNullOrEmpty
        }
        It 'Creates a new policy that select, string, boolean' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "app_notifications_darwin" }
            $templateId = $policyTemplate.id
            $policyName = "Pester Test Policy boolean"
            $multipleValPolicy = New-JCPolicy -name "Test textbsdox" -templateID $templateId -AlertType "Temporary Banner" -BundleIdentifier "Test" -PreviewType "Always" -BadgesEnabled $true
            #Test each param
            ($multipleValPolicy.values | Where-Object { $_.configFieldName -eq "AlertType" }).value | Should -Be "Temporary Banner"
            ($multipleValPolicy.values | Where-Object { $_.configFieldName -eq "-BundleIdentifier" }).value | Should -Be "Test"
            ($multipleValPolicy.values | Where-Object { $_.configFieldName -eq "PreviewType" }).value | Should -Be "Always"
            ($multipleValPolicy.values | Where-Object { $_.configFieldName -eq "BadgesEnabled" }).value | Should -Be $true
        }
    }
    Context 'Sets policies using the pipeline parameters' {
        It 'Creates a policy using the pipeline parameters boolean' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "allow_the_use_of_biometrics_windows" }
            $templateId = $policyTemplate.id
            $policyName = "Pester Test Policy boolean"
            $newPolicy = New-JCPolicy -name "Pester - pipeline boolean" -templateID $templateId -ALLOWUSEOFBIOMETRICS $false
            $pipelinePolicy = $newPolicy | New-JCPolicy -name "Pipeline New Policy Boolean Test"
            $pipelinePolicy.value.values | Should -Be "Pipeline New Policy Boolean Test"
        }
        #TODO: Registry
        It 'Creates a new policy that tests pipeline registry' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_registry_keys_policy_windows" }
            $templateId = $policyTemplate.id
            $policyName = "Pester Test Policy boolean"
            $pipelinePolicy = $newPolicy | New-JCPolicy -name "Pipeline Registry Test"
            $pipelinePolicy | Should -Be "Test Registry" #??
        }
        #Todo
        It 'Creates a new policy that tests pipeline upload file' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "custom_mdm_profile_darwin" }
            $templateId = $policyTemplate.id
            $policyName = "Pester Test Policy file"
            $newPolicy = New-JCPolicy -name "Test file" -templateID $templateId -file ???
            # Should not be null???
            $newPolicy | Should -Not -BeNullOrEmpty
        }
        It 'Creates a new policy that tests pipeline parameters string' {
            $policyTemplate = $policyTemplates | Where-Object { $_.name -eq "rename_local_administrator_account_windows" }
            $templateId = $policyTemplate.id
            $policyName = "Pester Test Policy"
            $newPolicy = New-JCPolicy -name "Test textbox" -templateID $templateId -ADMINISTRATORSTRING "Test String"
            # Should not be null
            $pipelinePolicy = $newPolicy | New-JCPolicy -name "Pipeline New Policy String Test"
            $pipelinePolicy.value.values | Should -Be "Pipeline New Policy String Test"
        }
    }

    #TODO: Create tests for Objects

}