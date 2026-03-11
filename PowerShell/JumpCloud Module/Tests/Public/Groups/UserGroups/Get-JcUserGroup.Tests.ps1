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
        $groups.GroupName | Should -Contain $TestGroupName
    }
    It 'Get by ID returns single group' {
        $group = Get-JCUserGroup -GroupID $TestGroup.id
        $group | Should -Not -BeNullOrEmpty
        $group.GroupName | Should -Be $TestGroupName
    }
    It 'Get by name returns expected result' {
        $filtered = Get-JCUserGroup -GroupName $TestGroupName
        $filtered | Should -Not -BeNullOrEmpty
        $filtered.GroupName | Should -Be $TestGroupName
    }
    It 'Get by non-existent name returns nothing or error' {
        $nonExistentName = "DefinitelyNotARealGroupName-$(Get-Random)"
        $result = Get-JCUserGroup -GroupName $nonExistentName
        $result | Should -BeNullOrEmpty
    }
}
