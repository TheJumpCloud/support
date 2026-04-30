Describe -Tag:('JcPolicyGroup') 'New-JCPolicyGroup' {
    BeforeAll {
        $existing = Get-JCPolicyGroup -Name "SdkTestPolicyGroup-ForCreate"
        $existing = Get-JCPolicyGroup -Filter "name:eq:SdkTestPolicyGroup-ForCreate"
        if ($existing) {
            $existing | ForEach-Object { Remove-JCPolicyGroup -PolicyGroupID $_.id -Force }
            $existing | ForEach-Object { Remove-JCPolicyGroup -Id $_.id }
        }
    }
    AfterAll {
        $created = Get-JCPolicyGroup -Name "SdkTestPolicyGroup-ForCreate"
        $created = Get-JCPolicyGroup -Filter "name:search:SdkTestPolicyGroup-ForCreate"
        if ($created) {
            $created | ForEach-Object { Remove-JCPolicyGroup -PolicyGroupID $_.id -Force }
            $created | ForEach-Object { Remove-JCPolicyGroup -Id $_.id }
        }
    }
    It 'Creating a new policy group does not throw' {
        { $TestGroup = New-JCPolicyGroup -Name "SdkTestPolicyGroup-ForCreate" -Description "SDK Test Group" } | Should -Not -Throw
        { $TestGroup = New-JCPolicyGroup -Name "SdkTestPolicyGroup-ForCreate" } | Should -Not -Throw
    }
    It 'Creating a new policy group returns the ID and name of the group' {
        $uniqueName = "SdkTestPolicyGroup-ForCreate-$(Get-Random)"
        $TestGroup = New-JCPolicyGroup -Name $uniqueName -Description "SDK Test Group"
        $TestGroup = New-JCPolicyGroup -Name $uniqueName
        $TestGroup | Should -Not -BeNullOrEmpty
        $TestGroup.id | Should -Not -BeNullOrEmpty
        $TestGroup.name | Should -Be $uniqueName
        Remove-JCPolicyGroup -PolicyGroupID $TestGroup.id -Force | Out-Null
        Remove-JCPolicyGroup -id $TestGroup.id | Out-Null
    }
}