Describe -Tag:('JcPolicyGroup') 'New-JCPolicyGroup' {
    BeforeAll {
        $existing = Get-JCPolicyGroup -Name "SdkTestPolicyGroup-ForCreate"
        if ($existing) {
            $existing | ForEach-Object { Remove-JCPolicyGroup -PolicyGroupID $_.id -Force }
        }
    }
    AfterAll {
        $created = Get-JCPolicyGroup -Name "SdkTestPolicyGroup-ForCreate"
        if ($created) {
            $created | ForEach-Object { Remove-JCPolicyGroup -PolicyGroupID $_.id -Force }
        }
    }
    It 'Creating a new policy group does not throw' {
        { $TestGroup = New-JCPolicyGroup -Name "SdkTestPolicyGroup-ForCreate" -Description "SDK Test Group" } | Should -Not -Throw
    }
    It 'Creating a new policy group returns the ID and name of the group' {
        $uniqueName = "SdkTestPolicyGroup-ForCreate-$(Get-Random)"
        $TestGroup = New-JCPolicyGroup -Name $uniqueName -Description "SDK Test Group"
        $TestGroup | Should -Not -BeNullOrEmpty
        $TestGroup.id | Should -Not -BeNullOrEmpty
        $TestGroup.name | Should -Be $uniqueName
        Remove-JCPolicyGroup -PolicyGroupID $TestGroup.id -Force | Out-Null
    }

}
