Describe -Tag:('JCUserGroupMember') 'Get-JCUserGroupMember 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    Add-JCUserGroupMember -GroupName $PesterParams.UserGroupName -username $PesterParams.Username
    It 'Gets a User Groups membership by Groupname' {
        $UserGroupMembers = Get-JCUserGroupMember -GroupName $PesterParams.UserGroupName
        $UserGroupMembers.id.Count | Should -BeGreaterThan 0
    }

    It 'Gets a User Groups membership -ByID' {
        $UserGroupMembers = Get-JCUserGroupMember -ByID $PesterParams.UserGroupID
        $UserGroupMembers.to.id.Count | Should -BeGreaterThan 0
    }
    Remove-JCUserGroupMember -GroupName $PesterParams.UserGroupName -username $PesterParams.Username
}
