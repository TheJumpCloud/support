Describe -Tag:('JcUserGroup') 'Set-JCUserGroup' {
    It 'Creates a user group, updates name and description with Set-JCUserGroup, verifies via Get-JCUserGroup, then removes the group' {
        $suffix = [guid]::NewGuid().ToString('N').Substring(0, 8)
        $initialName = "Pester-SetUsrGrp-$suffix"
        $newName = "Pester-SetUsrGrp-Renamed-$suffix"
        $newDescription = "Pester Set-JCUserGroup $suffix"

        $created = New-JCUserGroup -GroupName $initialName
        $created.Result | Should -Be 'Created'
        $groupId = $created.id
        $groupId | Should -Not -BeNullOrEmpty

        try {
            $null = Set-JCUserGroup -Id $groupId -Name $newName -Description $newDescription

            $fetched = Get-JCUserGroup -Id $groupId
            $fetched | Should -Not -BeNullOrEmpty
            $fetched.Name | Should -Be $newName
            $fetched.Description | Should -Be $newDescription
        } finally {
            Remove-JCUserGroup -GroupID $groupId -Force
        }
    }
}
