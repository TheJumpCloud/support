Describe -Tag:('MSP') 'Get-JCPolicyGroupTemplate' {
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
    It "Lists all policy group templates" {
        $allPolicyGroupTemplates = Get-JCPolicyGroupTemplate
        $allPolicyGroupTemplates | Should -Not -BeNullOrEmpty
    }
    It "Lists one policy group template policies by ID" {
        # get a single item:
        $policyGroupTemplateResult = Get-JCPolicyGroupTemplate -GroupTemplateID $newPolicyGroupTemplate.id
        $policyGroupTemplateResult | Should -Not -BeNullOrEmpty
        $policyGroupTemplateResult.id | Should -Be $newPolicyGroupTemplate.id
        $policyGroupTemplateResult.name | Should -Be $newPolicyGroupTemplate.name
        $policyGroupTemplateResult.description | Should -Be $newPolicyGroupTemplate.description
    }
    It "Lists one policy group template policies by Name" {
        # get a single item:
        $policyGroupTemplateResult = Get-JCPolicyGroupTemplate -Name "$($newPolicyGroupTemplate.name)"
        $policyGroupTemplateResult | Should -Not -BeNullOrEmpty
        $policyGroupTemplateResult.id | Should -Be $newPolicyGroupTemplate.id
        $policyGroupTemplateResult.name | Should -Be $newPolicyGroupTemplate.name
        $policyGroupTemplateResult.description | Should -Be $newPolicyGroupTemplate.description
        # if you get an item by name it will not contain values:
        $policyGroupTemplateResult.values | Should -BeNullOrEmpty
    }
    It "Should throw if an there is not an object found byID" {
        { Get-JCPolicyGroupTemplate -GroupTemplateID "111111111111111111111111" } | Should -Throw
    }
    It "Should return nothing if there is not an object found byName" {
        $search = Get-JCPolicyGroupTemplate -Name "111111111111111111111111"
        $search | Should -BeNullOrEmpty
    }
}