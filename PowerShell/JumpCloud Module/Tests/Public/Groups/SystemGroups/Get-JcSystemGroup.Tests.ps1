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
        $groups.Name | Should -Contain $TestGroupName
    }
    It 'Get by ID returns single group' {
        $group = Get-JCSystemGroup -Id $TestGroup.id
        $group | Should -Not -BeNullOrEmpty
        $group.Name | Should -Be $TestGroupName
    }
    It 'Get by name returns expected result' {
        $filtered = Get-JCSystemGroup -Filter "name:eq:$TestGroupName"
        $filtered | Should -Not -BeNullOrEmpty
        $filtered.Name | Should -Be $TestGroupName
    }
    It 'Get by non-existent name returns nothing or error' {
        $nonExistentName = "DefinitelyNotARealGroupName-$(Get-Random)"
        $result = Get-JCSystemGroup -Filter "name:eq:$nonExistentName"
        $result | Should -BeNullOrEmpty
    }
}
