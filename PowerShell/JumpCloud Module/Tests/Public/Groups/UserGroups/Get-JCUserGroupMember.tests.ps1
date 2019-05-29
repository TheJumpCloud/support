Connect-JCOnlineTest
Describe 'Get-JCUserGroupMember 1.0' {

    It 'Gets a User Groups membership by Groupname' {
        $UserGroupMembers = Get-JCUserGroupMember -GroupName $PesterParams.UserGroupName
        $UserGroupMembers.id.Count | Should -BeGreaterThan 0
    }

    It 'Gets a User Groups membership -ByID' {
        $UserGroupMembers = Get-JCUserGroupMember -ByID $PesterParams.UserGroupID
        $UserGroupMembers.to.id.Count | Should -BeGreaterThan 0
    }

}