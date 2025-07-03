Describe -Tag:('JCPolicyGroup') 'Remove-JCPolicyGroup' {
    BeforeAll {
        # remove pester policy groups before starting these tests
        $policyGroups = Get-JCPolicyGroup
        foreach ($policyGroup in $policyGroups) {
            if ($policyGroup.name -match "Pester") {
                Remove-JCPolicyGroup -PolicyGroupID $policyGroup.id -Force
            }
        }
    }
    It ("Removes a policy group using the 'Name' parameter") {
        # create the new policy group
        $randomName = "Pester-$(Get-Random)"
        $newGroup = New-JCPolicyGroup -Name "$randomName"
        # remove it
        $removedGroup = Remove-JCPolicyGroup -Name $randomName -Force
        # tests:
        $removedGroup.name | Should -Be $newGroup.name
    }
    It ("Removes a policy group using the 'id' parameter") {
        # create the new policy group
        $randomName = "Pester-$(Get-Random)"
        $newGroup = New-JCPolicyGroup -Name "$randomName"
        # remove it
        $removedGroup = Remove-JCPolicyGroup -PolicyGroupID $newGroup.id -Force
        # tests:
        $removedGroup.name | Should -Be $newGroup.name
    }
    It ("Removing a non-valid policy group by 'id' should throw") {
        # create the new policy group
        $randomName = $(Get-Random)
        # remove it
        $removedGroup = Remove-JCPolicyGroup -PolicyGroupID "$randomName" -Force
        $removedGroup.Name | Should -Be "Not Found"
        $removedGroup.Result | Should -BeNullOrEmpty

    }
    It ("Removing a non-valid policy group by 'name' should throw") {
        # create the new policy group
        $randomName = $(Get-Random)
        # remove it
        $removedGroup = Remove-JCPolicyGroup -Name "$randomName" -Force
        $removedGroup.Name | Should -Be "Not Found"
        $removedGroup.Result | Should -BeNullOrEmpty
    }
}