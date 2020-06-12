Describe -Tag:('JCSystemGroupMember') 'Get-JCSystemGroupMember 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It 'Gets a System Groups membership by Groupname' {

        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroup.Name

        $SystemGroupMembers = Get-JCSystemGroupMember -GroupName $PesterParams_SystemGroup.Name
        $SystemGroupMembers.SystemID.Count | Should -BeGreaterThan 0
    }

    It 'Gets a System Groups membership -ByID' {
        $SystemGroupMembers = Get-JCSystemGroupMember -ByID $PesterParams_SystemGroup.Id
        $SystemGroupMembers.SystemID.Count | Should -BeGreaterThan 0
    }

    It 'Gets all System Group members using Get-JCGroup -type system and the pipeline' {
        $AllSystemGroupmembers = Get-JCGroup -Type System | Get-JCSystemGroupMember
        $AllSystemGroupmembers.GroupName.Count | Should -BeGreaterThan 1
    }

}
