Describe -Tag:('JcUserGroup') 'Get-JCUserGroup' {
    BeforeAll {
        $TestGroupName = "SdkTestUserGroup-$(Get-Random)"
        $TestGroup = New-JCUserGroup -GroupName $TestGroupName
    }
    AfterAll {
        Remove-JCUserGroup -GroupName $TestGroupName -Force
    }
    It 'Get returns all user groups' {
        $groups = Get-JCUserGroup
        $groups | Should -Not -BeNullOrEmpty
        $groups.Name | Should -Contain $TestGroupName
    }
    It 'Get by ID returns single group' {
        $group = Get-JCUserGroup -Id $TestGroup.id
        $group | Should -Not -BeNullOrEmpty
        $group.Name | Should -Be $TestGroupName
    }
    It 'Get by name returns expected result' {
        $filtered = Get-JCUserGroup -Filter "name:eq:$TestGroupName"
        $filtered | Should -Not -BeNullOrEmpty
        $filtered.Name | Should -Be $TestGroupName
    }
    It 'Get by non-existent name returns nothing or error' {
        $nonExistentName = "DefinitelyNotARealGroupName-$(Get-Random)"
        $result = Get-JCUserGroup -Filter "name:eq:$nonExistentName"
        $result | Should -BeNullOrEmpty
    }
}
