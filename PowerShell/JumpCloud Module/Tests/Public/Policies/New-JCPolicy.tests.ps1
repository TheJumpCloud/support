Describe -Tag:('JCPolicy') 'Set-JCPolicy' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null

        # Clean Up Pester Policy Tests:
        $headers = @{}
        $headers.Add("x-org-id", $PesterParams_OrgId)
        $headers.Add("x-api-key", $PesterParams_ApiKey)
    }

    Context 'Creates policies with dynamic parameters' {
        It 'Creates a new policy that tests textbox string' {
            $templateResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/policytemplates?filter=name:eq:rename_local_administrator_account_windows' -Method GET -Headers $headers
            $templateId = $templateResponse.id
            $stringPolicy = New-JCPolicy -name "Test textbox" -templateID $templateId -ADMINISTRATORSTRING "Test String"
            # Should not be null
            $stringPolicy.values.value | Should -Be "Test String"
        }
        It 'Creates a new policy that tests boolean' {
            $templateResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/policytemplates?filter=name:eq:allow_the_use_of_biometrics_windows' -Method GET -Headers $headers
            $templateId = $templateResponse.id
            $booleanPolicy = New-JCPolicy -name "Test textbox" -templateID $templateId -ALLOWUSEOFBIOMETRICS $true
            # Should not be null???
            $booleanPolicy.values.value | Should -be $true
        }
        #TODO: Registry
        It 'Creates a new policy that tests registry' {
            $templateResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/policytemplates?filter=name:eq:custom_registry_keys_policy_windows' -Method GET -Headers $headers
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
            $templateId = $templateResponse.id
            $tablePolicy = New-JCPolicy -templateID $templateId -customRegTable $policyValueList -Name "Pester - Registry"
            $tablePolicy | Should -Be 1
        }
        #TODO
        It 'Creates a new policy that tests upload file' {
            $templateResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/policytemplates?filter=name:eq:custom_mdm_profile_darwin' -Method GET -Headers $headers
            $templateId = $templateResponse.id
            $newPolicy = New-JCPolicy -name "Test file" -templateID $templateId -file ???
            # Should not be null???
            $newPolicy | Should -Not -BeNullOrEmpty
        }
        It 'Creates a new policy that select, string, boolean' {
            $templateResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/policytemplates?filter=id:eq:app_notifications_darwin' -Method GET -Headers $headers
            $templateId = $templateResponse.id
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
            $templateResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/policytemplates?filter=name:eq:allow_the_use_of_biometrics_windows' -Method GET -Headers $headers
            $templateId = $templateResponse.id
            $policyName = "Pester Test Policy boolean"
            $newPolicy = New-JCPolicy -name "Test boolean" -templateID $templateId -ALLOWUSEOFBIOMETRICS $false
            $pipelinePolicy = $newPolicy | New-JCPolicy -name "Pipeline New Policy Boolean Test"
            $pipelinePolicy.value.values | Should -Be "Pipeline New Policy Boolean Test"
        }
        #TODO: Registry
        It 'Creates a new policy that tests pipeline registry' {
            $templateResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/policytemplates?filter=name:eq:custom_registry_keys_policy_windows' -Method GET -Headers $headers
            $templateId = $templateResponse.id
            $policyName = "Pester Test Policy boolean"
            $pipelinePolicy = $newPolicy | New-JCPolicy -name "Pipeline Registry Test"
            $pipelinePolicy | Should -Be "Test Registry" #??
        }
        #Todo
        It 'Creates a new policy that tests pipeline upload file' {
            $templateResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/policytemplates?filter=name:eq:custom_mdm_profile_darwin' -Method GET -Headers $headers
            $templateId = $templateResponse.id
            $policyName = "Pester Test Policy file"
            $newPolicy = New-JCPolicy -name "Test file" -templateID $templateId -file ???
            # Should not be null???
            $newPolicy | Should -Not -BeNullOrEmpty
        }
        It 'Creates a new policy that tests pipeline parameters string' {
            $templateResponse = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/policytemplates?filter=name:eq:rename_local_administrator_account_windows' -Method GET -Headers $headers
            $templateId = $templateResponse.id
            $policyName = "Pester Test Policy"
            $newPolicy = New-JCPolicy -name "Test textbox" -templateID $templateId -ADMINISTRATORSTRING "Test String"
            # Should not be null
            $pipelinePolicy = $newPolicy | New-JCPolicy -name "Pipeline New Policy String Test"
            $pipelinePolicy.value.values | Should -Be "Pipeline New Policy String Test"
        }
    }

}