Describe -Tag:('JcPolicyGroup') 'Set-JCPolicyGroup' {
    It 'Creates a policy group, updates the display name with Set-JCPolicyGroup, verifies via Get-JCPolicyGroup, then removes the group' {
        $suffix = [guid]::NewGuid().ToString('N').Substring(0, 12)
        $initialName = "Pester-SetPolicyGroup-$suffix"
        $renamed = "Pester-SetPolicyGroup-Renamed-$suffix"

        $created = New-JCPolicyGroup -Name $initialName
        $created | Should -Not -BeNullOrEmpty
        $created.id | Should -Not -BeNullOrEmpty

        try {
            $updated = Set-JCPolicyGroup -Id $created.id -Name $renamed
            $updated | Should -Not -BeNullOrEmpty

            $fetched = Get-JCPolicyGroup -Id $created.id
            $fetched | Should -Not -BeNullOrEmpty
            $fetched.Name | Should -Be $renamed
        } finally {
            Remove-JCPolicyGroup -Id $created.id
        }
    }
}
