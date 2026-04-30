Describe -Tag:('JcSystemGroup') 'Set-JCSystemGroup' {
    It 'Creates a system group, updates name and description with Set-JCSystemGroup, verifies via Get-JCSystemGroup, then removes the group' {
        $suffix = [guid]::NewGuid().ToString('N').Substring(0, 8)
        $initialName = "Pester-SetSysGrp-$suffix"
        $newName = "Pester-SetSysGrp-Renamed-$suffix"
        $newDescription = "Pester Set-JCSystemGroup $suffix"

        $created = New-JCSystemGroup -GroupName $initialName
        $created.Result | Should -Be 'Created'
        $groupId = $created.id
        $groupId | Should -Not -BeNullOrEmpty

        try {
            $null = Set-JCSystemGroup -Id $groupId -Name $newName -Description $newDescription

            $fetched = Get-JCSystemGroup -Id $groupId
            $fetched | Should -Not -BeNullOrEmpty
            $fetched.Name | Should -Be $newName
            $fetched.Description | Should -Be $newDescription
        } finally {
            Remove-JCSystemGroup -GroupID $groupId -Force
        }
    }
}
