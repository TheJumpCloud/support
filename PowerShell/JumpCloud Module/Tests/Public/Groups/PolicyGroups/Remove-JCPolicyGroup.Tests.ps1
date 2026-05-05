Describe -Tag:('JcPolicyGroup') 'Remove-JCPolicyGroup' {
    It 'Removes a policy group by ID does not throw' {
        $uniqueName = "SdkTestPolicyGroup-ForRemove-$(Get-Random)"
        $TestGroup = New-JCPolicyGroup -Name $uniqueName
        { Remove-JCPolicyGroup -ID $TestGroup.id } | Should -Not -Throw
    }
}
