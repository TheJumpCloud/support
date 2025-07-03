Describe -Tag:('JCPolicyGroup') 'Get-JCPolicyGroup' {
    BeforeAll {
        # get and remove "*pester* policy groups"
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
    }
    It ('Returns the policy group without searching by name') {
        $AllPolicyGroups = Get-JCPolicyGroup
        $matchedPolicy = $AllPolicyGroups | Where-Object { $_.id -eq $PesterGroup.Id }
        $matchedPolicy | Should -Not -BeNullOrEmpty
        $matchedPolicy.name | Should -BeIn $AllPolicyGroups.name
        $PesterGroup.id | Should -BeIn $AllPolicyGroups.id
    }
    It ('Returns the policy group by searching by name') {
        $matchedPolicy = Get-JCPolicyGroup -Name $PesterGroupName
        $matchedPolicy | Should -Not -BeNullOrEmpty
        $matchedPolicy.name | Should -Be $PesterGroupName
        $PesterGroup.description | Should -Be $PesterGroupDesc
        $PesterGroup.id | Should -Be $PesterGroup.id
    }
    It ('Returns the policy group by searching by Id') {
        $matchedPolicy = Get-JCPolicyGroup -PolicyGroupID $PesterGroup.id
        $matchedPolicy | Should -Not -BeNullOrEmpty
        $matchedPolicy.name | Should -Be $PesterGroupName
        $PesterGroup.description | Should -Be $PesterGroupDesc
        $PesterGroup.id | Should -Be $PesterGroup.id
    }
}