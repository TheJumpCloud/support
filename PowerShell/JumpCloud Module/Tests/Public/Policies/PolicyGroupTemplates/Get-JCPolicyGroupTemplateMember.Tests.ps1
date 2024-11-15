Describe -Tag:('MSP') 'Get-JCPolicyGroupTemplateMember' {
    BeforeAll {
        # remove any Policy Group Templates with *Pester* in the Name:
        $allPolicyGroupTemplates = Get-JCPolicyGroupTemplate
        foreach ($policyGroupTemplate in $allPolicyGroupTemplates) {
            if ($policyGroupTemplate.name -match "Pester") {
                Remove-JCPolicyGroupTemplate -GroupTemplateID $policyGroupTemplate.id -Force
            }
        }
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
    It "Lists members of a policy group templates by ID" {
        $templateMembers = Get-JCPolicyGroupTemplateMember -GroupTemplateID $newPolicyGroupTemplate.id
        # the template created in beforeAll should contain members:
        $templateMembers | Should -Not -BeNullOrEmpty
        # the policy added to the template in beforeAll should be in the member list:
        $usbLinuxPolicy.name | Should -BeIn $templateMembers.name
        $usbLinuxPolicy.templateId | Should -BeIn $templateMembers.policyTemplateId
    }
    It "Lists members of a policy group templates by Name" {
        $templateMembers = Get-JCPolicyGroupTemplateMember -Name "$($newPolicyGroupTemplate.Name)"
        # the template created in beforeAll should contain members:
        $templateMembers | Should -Not -BeNullOrEmpty
        # the policy added to the template in beforeAll should be in the member list:
        $usbLinuxPolicy.name | Should -BeIn $templateMembers.name
        $usbLinuxPolicy.templateId | Should -BeIn templateMembers.policyTemplateId
    }
}