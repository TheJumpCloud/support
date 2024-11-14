Describe -Tag:('JCPolicyGroup') 'Get-JCPolicyGroupMember' {
    BeforeAll {
        # remove pester policy groups before starting these tests
        $policyGroups = Get-JCPolicyGroup
        foreach ($policyGroup in $policyGroups) {
            if ($policyGroup.name -match "Pester") {
                Remove-JCPolicyGroup -PolicyGroupID $policyGroup.id -Force
            }
        }
        # create a single policy group
        $PesterGroupName = "Pester-$(Get-Random)"
        $PesterGroupDesc = "$(Get-Random)"
        $PesterGroup = New-JCPolicyGroup -Name $PesterGroupName -Description $PesterGroupDesc
        # create a policy for these tests:
        $policyTemplates = Get-JcSdkPolicyTemplate
        $usbTemplateLinux = $policyTemplates | Where-Object { $_.name -eq "disable_usb_storage_linux" }
        $usbLinuxPolicy = New-JCPolicy -TemplateID $usbTemplateLinux.Id  -Name "Pester - USB Linux $(new-randomString -NumberOfChars 8)" -disable_mtp $true -disable_afc $false -disable_mmc $false -Notes "usb"
    }
    It ('Returns null when there are no members of the policy group') {
        $policyGroupMembers = Get-JCPolicyGroupMember -PolicyGroupID $PesterGroup.Id
        # response should return nothing
        $policyGroupMembers | Should -BeNullOrEmpty
    }
    It ('Returns a list of members when a policy has been added to the group') {
        # add a policy to the group
        Set-JcSdkPolicyGroupMember -GroupId $PesterGroup.Id -Op "add" -Id $usbLinuxPolicy.id
        # get the group members
        $policyGroupMembers = Get-JCPolicyGroupMember -PolicyGroupID $PesterGroup.Id
        # The response should not be Null
        $policyGroupMembers | Should -Not -BeNullOrEmpty
        # there should be a count of 1
        $policyGroupMembers.Count | Should -BeExactly 1
        # the policyGroup should contain the new Policy
        $usbLinuxPolicy.Name | Should -BeIn $policyGroupMembers.Name
    }
    It ('Returns members of a policy group specified by name') {
        $policyGroupMembers = Get-JCPolicyGroupMember -Name $PesterGroup.name
        # response should return nothing
        $policyGroupMembers | Should -Not -BeNullOrEmpty
    }
    It
}