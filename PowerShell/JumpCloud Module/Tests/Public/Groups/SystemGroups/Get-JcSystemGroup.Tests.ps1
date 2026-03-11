Describe -Tag:('JcSystemGroup') 'Get-JCSystemGroup' {
    BeforeAll {
        $TestGroupName = "SdkTestSystemGroup-$(Get-Random)"
        $TestGroup = New-JCSystemGroup -GroupName $TestGroupName
    }
    AfterAll {
        Remove-JCSystemGroup -GroupName $TestGroupName -Force
    }
    It 'Get returns all system groups' {
        $groups = Get-JCSystemGroup
        $groups | Should -Not -BeNullOrEmpty
        $groups.GroupName | Should -Contain $TestGroupName
    }
    It 'Get by ID returns single group' {
        $group = Get-JCSystemGroup -GroupID $TestGroup.id
        $group | Should -Not -BeNullOrEmpty
        $group.GroupName | Should -Be $TestGroupName
    }
    It 'Get by name returns expected result' {
        $filtered = Get-JCSystemGroup -GroupName $TestGroupName
        $filtered | Should -Not -BeNullOrEmpty
        $filtered.GroupName | Should -Be $TestGroupName
    }
    It 'Get by non-existent name returns nothing or error' {
        $nonExistentName = "DefinitelyNotARealGroupName-$(Get-Random)"
        $result = Get-JCSystemGroup -GroupName $nonExistentName
        $result | Should -BeNullOrEmpty
    }
}
