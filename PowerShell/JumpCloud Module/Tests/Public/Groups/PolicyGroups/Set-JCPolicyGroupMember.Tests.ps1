Describe -Tag:('JcPolicyGroupMember') 'Set-JCPolicyGroupMember' {
    BeforeAll {
        $script:GroupName = "Pester-SetPolGrpMbr-$(Get-Random)"
        $script:PolicyGroup = New-JCPolicyGroup -Name $script:GroupName
        $policyTemplates = Get-JcSdkPolicyTemplate
        $usbTemplateLinux = $policyTemplates | Where-Object { $_.name -eq 'disable_usb_storage_linux' }
        $script:TestPolicy = New-JCPolicy -TemplateID $usbTemplateLinux.Id -Name "Pester-SetPolGrpMbr-USB-$(Get-Random)" -disable_mtp $true -disable_afc $false -disable_mmc $false -Notes 'Set-JCPolicyGroupMember test'
    }
    AfterAll {
        if ($script:TestPolicy) {
            Remove-JCPolicy -PolicyID $script:TestPolicy.Id -Force | Out-Null
        }
        if ($script:PolicyGroup -and $script:PolicyGroup.id) {
            Remove-JCPolicyGroup -Id $script:PolicyGroup.id | Out-Null
        }
    }
    It 'Set-JCPolicyGroupMember add places the policy in the group (validated with Get-JCPolicyGroupMember)' {
        Set-JCPolicyGroupMember -GroupId $script:PolicyGroup.id -Op 'add' -Id $script:TestPolicy.id | Out-Null
        $members = Get-JCPolicyGroupMember -GroupId $script:PolicyGroup.id
        $members | Should -Not -BeNullOrEmpty
        $script:TestPolicy.Name | Should -BeIn $members.Name
    }
    It 'Set-JCPolicyGroupMember remove clears the policy from the group' {
        Set-JCPolicyGroupMember -GroupId $script:PolicyGroup.id -Op 'remove' -Id $script:TestPolicy.id | Out-Null
        $members = Get-JCPolicyGroupMember -GroupId $script:PolicyGroup.id
        $members | Should -BeNullOrEmpty
    }
    It 'Set-JCPolicyGroupMember add/remove round-trip keeps group membership consistent' {
        Set-JCPolicyGroupMember -GroupId $script:PolicyGroup.id -Op 'add' -Id $script:TestPolicy.id | Out-Null
        $afterAdd = Get-JCPolicyGroupMember -GroupId $script:PolicyGroup.id
        $afterAdd | Should -Not -BeNullOrEmpty

        Set-JCPolicyGroupMember -GroupId $script:PolicyGroup.id -Op 'remove' -Id $script:TestPolicy.id | Out-Null
        $afterRemove = Get-JCPolicyGroupMember -GroupId $script:PolicyGroup.id
        $afterRemove | Should -BeNullOrEmpty
    }
}
