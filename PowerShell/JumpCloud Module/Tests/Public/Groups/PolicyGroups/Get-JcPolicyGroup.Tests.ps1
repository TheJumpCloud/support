Describe -Tag:('JcPolicyGroup') 'Get-JcPolicyGroup' {
    BeforeAll {
        $TestGroupName = "SdkTestPolicyGroup-$(Get-Random)"
        $TestGroup = New-JCPolicyGroup -Name $TestGroupName -Description "SDK Test Group"
    }
    AfterAll {
        Remove-JCPolicyGroup -PolicyGroupID $TestGroup.id -Force
    }
    It 'Get returns all policy groups' {
        $groups = Get-JCPolicyGroup
        $groups | Should -Not -BeNullOrEmpty
        $groups.name | Should -Contain $TestGroupName
    }
    It 'Get by ID returns single group' {
        $group = Get-JCPolicyGroup -PolicyGroupID $TestGroup.id
        $group | Should -Not -BeNullOrEmpty
        $group.name | Should -Be $TestGroupName
    }
    It 'Get by filter "name:eq:something" returns expected result' {
        $filtered = Get-JCPolicyGroup -Filter "name:eq:$TestGroupName"
        $filtered | Should -BeNullOrEmpty
    }
}
