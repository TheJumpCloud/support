Describe -Tag:('JcPolicyGroupMember') 'Get-JCPolicyGroupMember and Set-JCPolicyGroupMember' {
    BeforeAll {
        $TestGroupName = "SdkTestPolicyGroupMember-$(Get-Random)"
        $TestGroup = New-JCPolicyGroup -Name $TestGroupName
        $policyTemplates = Get-JcSdkPolicyTemplate
        $usbTemplateLinux = $policyTemplates | Where-Object { $_.name -eq "disable_usb_storage_linux" }
        $TestPolicy = New-JCPolicy -TemplateID $usbTemplateLinux.Id -Name "Pester-USB-Linux-$(Get-Random)" -disable_mtp $true -disable_afc $false -disable_mmc $false -Notes "usb"
    }
    AfterAll {
        if ($TestPolicy) { Remove-JCPolicy -PolicyID $TestPolicy.Id -force | Out-Null }
        if ($TestGroup) { Remove-JCPolicyGroup -id $TestGroup.id | Out-Null }
    }
    It 'Returns null when there are no members of the policy group' {
        $members = Get-JCPolicyGroupMember -GroupId $TestGroup.id
        $members | Should -BeNullOrEmpty
    }
    It 'Adds a policy to the group and Get-JCPolicyGroupMember returns it' {
        Set-JCPolicyGroupMember -GroupId $TestGroup.id -Op "add" -Id $TestPolicy.id | Out-Null
        $members = Get-JCPolicyGroupMember -GroupId $TestGroup.id
        $members | Should -Not -BeNullOrEmpty
        $TestPolicy.id | Should -BeIn $members.toId
    }
    It 'Removes a policy from the group and Get-JCPolicyGroupMember returns empty' {
        Set-JCPolicyGroupMember -GroupId $TestGroup.id -Op "remove" -Id $TestPolicy.id | Out-Null
        $members = Get-JCPolicyGroupMember -GroupId $TestGroup.id
        $members | Should -BeNullOrEmpty
    }
    It 'Returns groups for a policy using -PolicyId' {
        # Add policy to group
        Set-JCPolicyGroupMember -GroupId $TestGroup.id -Op "add" -Id $TestPolicy.id | Out-Null
        $groups = Get-JCPolicyGroupMember -PolicyId $TestPolicy.id
        $groups | Should -Not -BeNullOrEmpty
        $TestGroup.id | Should -BeIn $groups.id
        # Remove policy from group for cleanup
        Set-JCPolicyGroupMember -GroupId $TestGroup.id -Op "remove" -Id $TestPolicy.id | Out-Null
    }
}
