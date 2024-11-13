Describe -Tag:('MSP') 'Get-JCPolicyGroupTemplate' {
    BeforeAll {
        # remove any Policy Group Templates with *Pester* in the Name:
        $allPolicyGroupTemplates = Get-JCPolicyGroupTemplate
        foreach ($policyGroupTemplate in $allPolicyGroupTemplates) {
            if ($policyGroupTemplate.name -match "Pester") {
                Remove-JCPolicyGroupTemplate -GroupTemplateID $policyGroupTemplate.id -Force
            }
        }
    }
    BeforeEach {
        # create a policy for these tests:
        $policyTemplates = Get-JcSdkPolicyTemplate
        $usbTemplateLinux = $policyTemplates | Where-Object { $_.name -eq "disable_usb_storage_linux" }
        $usbLinuxPolicy = New-JCPolicy -TemplateID $usbTemplateLinux.Id  -Name "Pester - USB Linux $(new-randomString -NumberOfChars 8)" -disable_mtp $true -disable_afc $false -disable_mmc $false -Notes "usb"

        $PesterTemplateGroupName = "Pester-$(Get-Random)"
        $PesterTemplateGroupDesc = "Pester-$(Get-Random)"

        $headers = @{
            "content-type" = "application/json"
            "x-api-key"    = "$env:JCApiKey"
        }
        $body = @{
            "description" = "$PesterTemplateGroupDesc"
            "name"        = "$PesterTemplateGroupName"
            "policyIds"   = @("$($usbLinuxPolicy.Id)")
        } | ConvertTo-Json

        $newPolicyGroupTemplate = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/providers/$env:JCProviderId/policygrouptemplates" -Method POST -Headers $headers -ContentType 'application/json' -Body $body

    }
    It "Removes a policy group template by name" {
        # Get the group template
        $foundPolicyGroupTemplate = Get-JCPolicyGroupTemplate -Name $newPolicyGroupTemplate.name
        # the policy group template created in the beforeEach block should be in the org
        $foundPolicyGroupTemplate | Should -Not -BeNullOrEmpty
        # remove the policy group template
        { Remove-JCPolicyGroupTemplate -Name $newPolicyGroupTemplate.name -Force } | Should -Not -Throw
        # Get the group template after it's been removed
        $foundPolicyGroupTemplate = Get-JCPolicyGroupTemplate -Name $newPolicyGroupTemplate.name
        # the policy group template created in the beforeEach block should NOT be in the org
        $foundPolicyGroupTemplate | Should -BeNullOrEmpty
    }
    It "Removes a policy group template by ID" {
        # Get the group template
        $foundPolicyGroupTemplate = Get-JCPolicyGroupTemplate -GroupTemplateID $newPolicyGroupTemplate.id
        # the policy group template created in the beforeEach block should be in the org
        $foundPolicyGroupTemplate | Should -Not -BeNullOrEmpty
        # remove the policy group template
        { Remove-JCPolicyGroupTemplate -GroupTemplateID $newPolicyGroupTemplate.id -Force } | Should -Not -Throw
        # Get the group template after it's been removed
        $foundPolicyGroupTemplate = Get-JCPolicyGroupTemplate -GroupTemplateID $newPolicyGroupTemplate.id
        # the policy group template created in the beforeEach block should NOT be in the org
        $foundPolicyGroupTemplate | Should -BeNullOrEmpty
    }
    It "Should throw if an there is not an object found byID" {
        $removedPolicyGroupTemplate = Remove-JCPolicyGroupTemplate -GroupTemplateID "111111111111111111111111"
        $removedPolicyGroupTemplate.Name | Should -Be "Not Found"
        $removedPolicyGroupTemplate.Result | Should -BeNullOrEmpty
    }
    It "Should return nothing if there is not an object found byName" {
        $removedPolicyGroupTemplate = Remove-JCPolicyGroupTemplate -Name "111111111111111111111111"
        $removedPolicyGroupTemplate.Name | Should -Be "Not Found"
        $removedPolicyGroupTemplate.Result | Should -BeNullOrEmpty
    }
}