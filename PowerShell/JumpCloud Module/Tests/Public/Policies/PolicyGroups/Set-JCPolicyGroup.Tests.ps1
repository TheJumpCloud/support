Describe -Tag:('JCPolicyGroup') 'Set-JCPolicyGroup' {
    BeforeAll {
        # remove pester policy groups before starting these tests
        $policyGroups = Get-JCPolicyGroup
        foreach ($policyGroup in $policyGroups) {
            if ($policyGroup.name -match "Pester") {
                Remove-JCPolicyGroup -PolicyGroupID $policyGroup.id -Force
            }
        }
    }
    It ("Changes the name of the policy group by 'Name'") {
        # create a new group
        $randomName = "Pester-$(Get-Random)"
        $newRandomName = "Pester-$(Get-Random)"
        $newGroup = New-JCPolicyGroup -Name "$randomName" -Description "Description"
        # set the group
        $setGroup = Set-JCPolicyGroup -Name "$randomName" -NewName $newRandomName
        # test:
        $setGroup.Name | Should -Be $newRandomName
        $setGroup.Description | Should -Be $newGroup.description
        $setGroup.Id | Should -Be $newGroup.Id
    }
    It ("Changes the description of the policy group by 'Name'") {
        # create a new group
        $randomName = "Pester-$(Get-Random)"
        $newGroup = New-JCPolicyGroup -Name "$randomName" -Description "Description"
        # set the group
        $setGroup = Set-JCPolicyGroup -Name "$randomName" -Description "NewDescription"
        # test:
        $setGroup.Name | Should -Be $randomName
        $setGroup.Description | Should -Not -Be $newGroup.description
        $setGroup.Description | Should -Be "NewDescription"
        $setGroup.Id | Should -Be $newGroup.Id
    }
    It ("Changes the name of the policy group by 'Id'") {
        # create a new group
        $randomName = "Pester-$(Get-Random)"
        $newRandomName = "Pester-$(Get-Random)"
        $newGroup = New-JCPolicyGroup -Name "$randomName" -Description "Description"
        # set the group
        $setGroup = Set-JCPolicyGroup -PolicyGroupID "$($newGroup.id)" -NewName "$($newRandomName)"
        # test:
        $setGroup.Name | Should -Be $newRandomName
        $setGroup.Description | Should -Be $newGroup.description
        $setGroup.Id | Should -Be $newGroup.Id
    }
    It ("Changes the description of the policy group by 'Id'") {
        # create a new group
        $randomName = "Pester-$(Get-Random)"
        $newGroup = New-JCPolicyGroup -Name "$randomName" -Description "Description"
        # set the group
        $setGroup = Set-JCPolicyGroup -PolicyGroupID "$($newGroup.id)" -Description "NewDescription"
        # test:
        $setGroup.Name | Should -Be $randomName
        $setGroup.Description | Should -Not -Be $newGroup.description
        $setGroup.Description | Should -Be "NewDescription"
        $setGroup.Id | Should -Be $newGroup.Id
    }
    # It ("Throws when the policy group name does not exist")
    Context ("Using the pipeline parameters") {
        It ("Sets a newly created policy group") {

        }
        It ("Sets an existing policy group") {

        }
        It ("Throws if the policy group does not exist") {

        }
    }

}