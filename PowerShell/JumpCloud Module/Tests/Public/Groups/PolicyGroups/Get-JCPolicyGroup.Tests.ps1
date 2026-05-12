Describe -Tag:('JCPolicyGroup') 'Get-JCPolicyGroup' {
    BeforeAll {
        $TestGroupName = "SdkTestPolicyGroup-$(Get-Random)"
        $TestGroup = New-JCPolicyGroup -Name $TestGroupName
    }
    AfterAll {
        if ($TestGroup -and $TestGroup.id) {
            Remove-JCPolicyGroup -Id $TestGroup.id
        }
    }
    It 'Get returns all policy groups' {
        $groups = Get-JCPolicyGroup
        $groups | Should -Not -BeNullOrEmpty
        $groups.name | Should -Contain $TestGroupName
    }
    It 'Get by ID returns single group' {
        $group = Get-JCPolicyGroup -Id $TestGroup.id
        $group | Should -Not -BeNullOrEmpty
        $group.name | Should -Be $TestGroupName
    }
    It 'Get by name returns expected result' {
        $filtered = Get-JCPolicyGroup -Filter "name:eq:$TestGroupName"
        $filtered | Should -Not -BeNullOrEmpty
        $filtered.name | Should -Be $TestGroupName
    }
    It 'Get by non-existent name returns nothing or error' {
        $nonExistentName = "DefinitelyNotARealGroupName-$(Get-Random)"
        $result = Get-JCPolicyGroup -Filter "name:eq:$nonExistentName"
        $isEmpty = ($null -eq $result -or ($result.PSObject.Properties.Name -inotcontains 'name' -and $result.PSObject.Properties.Name -inotcontains 'id' -and $result.PSObject.Properties.Name -inotcontains 'Id'))
        $isEmpty | Should -BeTrue
    }
}
