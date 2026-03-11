Describe -Tag:('JcPolicyGroup') 'Remove-JCPolicyGroup' {
    It 'Removes a policy group by ID does not throw' {
        $uniqueName = "SdkTestPolicyGroup-ForRemove-$(Get-Random)"
        $TestGroup = New-JCPolicyGroup -Name $uniqueName -Description "SDK Test Group"
        { Remove-JCPolicyGroup -PolicyGroupID $TestGroup.id -Force } | Should -Not -Throw
    }
    It 'Removes a policy group by Name does not throw' {
        $uniqueName = "SdkTestPolicyGroup-ForRemove-$(Get-Random)"
        $TestGroup = New-JCPolicyGroup -Name $uniqueName -Description "SDK Test Group"
        { Remove-JCPolicyGroup -Name $uniqueName -Force } | Should -Not -Throw
    }
    It 'Removing a non-existent policy group by ID returns Not Found' {
        $fakeId = [guid]::NewGuid().ToString()
        $result = Remove-JCPolicyGroup -PolicyGroupID $fakeId -Force
        $result.Name | Should -Be "Not Found"
    }
    It 'Removing a non-existent policy group by Name returns Not Found' {
        $fakeName = "DefinitelyNotARealGroupName-$(Get-Random)"
        $result = Remove-JCPolicyGroup -Name $fakeName -Force
        $result.Name | Should -Be "Not Found"
    }
}
