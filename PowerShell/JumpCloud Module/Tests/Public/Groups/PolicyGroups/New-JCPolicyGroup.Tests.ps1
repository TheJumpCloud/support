Describe -Tag:('JCPolicyGroup') 'New-JCPolicyGroup' {
    BeforeAll {
        $existing = Get-JCPolicyGroup -Filter "name:eq:SdkTestPolicyGroup-ForCreate"
        if ($existing) {
            $existing | ForEach-Object { Remove-JCPolicyGroup -Id $_.id }
        }
    }
    AfterAll {
        $created = Get-JCPolicyGroup -Filter "name:search:SdkTestPolicyGroup-ForCreate"
        if ($created) {
            $created | ForEach-Object { Remove-JCPolicyGroup -Id $_.id }
        }
    }
    It 'Creating a new policy group does not throw' {
        { $TestGroup = New-JCPolicyGroup -Name "SdkTestPolicyGroup-ForCreate" } | Should -Not -Throw
    }
    It 'Creating a new policy group returns the ID and name of the group' {
        $uniqueName = "SdkTestPolicyGroup-ForCreate-$(Get-Random)"
        $TestGroup = New-JCPolicyGroup -Name $uniqueName
        $TestGroup | Should -Not -BeNullOrEmpty
        $TestGroup.id | Should -Not -BeNullOrEmpty
        Remove-JCPolicyGroup -id $TestGroup.id | Out-Null
    }
}