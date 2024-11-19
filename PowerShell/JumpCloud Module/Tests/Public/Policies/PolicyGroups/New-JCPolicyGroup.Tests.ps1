Describe -Tag:('JCPolicyGroup') 'New-JCPolicyGroup' {
    BeforeAll {
        # remove pester policy groups before starting these tests
        $policyGroups = Get-JCPolicyGroup
        foreach ($policyGroup in $policyGroups) {
            if ($policyGroup.name -match "Pester") {
                Remove-JCPolicyGroup -PolicyGroupID $policyGroup.id -Force
            }
        }
    }
    It ("Creates a Policy Group with the name parameter") {
        $randomName = "Pester-$(Get-Random)"
        $newGroup = New-JCPolicyGroup -Name "$randomName"
        $newGroup | Should -Not -BeNullOrEmpty
        $newGroup.Name | Should -Be $randomName
        $newGroup.Description | Should -BeNullOrEmpty

    }
    It ("Creates a Policy Group with the 'name' and 'description' parameter") {
        $randomName = "Pester-$(Get-Random)"
        $description = "PesterTest"
        $newGroup = New-JCPolicyGroup -Name "$randomName" -Description "$description"
        $newGroup | Should -Not -BeNullOrEmpty
        $newGroup.Name | Should -Be $randomName
        $newGroup.Description | Should -Be $description
    }
    It ("Throws if the Policy Group already exists") {
        $policyGroups = Get-JCPolicyGroup
        $randomPolicyGroup = $policyGroups | Where-Object { $_.name -match "pester" } | Select-Object -First 1
        { New-JCPolicyGroup -Name "$($randomPolicyGroup.name)" } | Should -Throw
    }
}

Describe -Tag:('MSP') 'New-JCPolicyGroup Templates' {
    Context ('From TemplateID') {
        BeforeAll {
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

        It ("Creates a policy group from template when the group exists") {
            $existingPolicyGroup = Get-JCPolicyGroupTemplate -GroupTemplateID $newPolicyGroupTemplate.id
            if (-Not $existingPolicyGroup) {
                New-JCPolicyGroup -TemplateID $newPolicyGroupTemplate.id
            }
            # this behavior is actually expected
            { $templateResult = New-JCPolicyGroup -TemplateID $newPolicyGroupTemplate.id } | Should -Not -Throw
            # the second time we run this it should throw:
            { $templateResult = New-JCPolicyGroup -TemplateID $newPolicyGroupTemplate.id } | Should -Throw
        }
        AfterAll {
            $policyGroups = Get-JCPolicyGroup
            foreach ($policyGroup in $policyGroups) {
                if ($policyGroup.name -match "Pester") {
                    Remove-JCPolicyGroup -PolicyGroupID $policyGroup.id -Force
                }
            }
            $policyGroupTemplates = Get-JCPolicyGroupTemplate
            foreach ($policyGroupTemplate in $policyGroupTemplates) {
                if ($policyGroupTemplate.name -match "Pester") {
                    Remove-JCPolicyGroupTemplate -id $policyGroupTemplate.id -Force
                }
            }
        }
    }
}
