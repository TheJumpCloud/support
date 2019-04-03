Describe 'Get-JCUserGroupMember' {

    It 'Gets a User Groups membership by Groupname' {
        $UserGroupMembers = Get-JCUserGroupMember -GroupName $UserGroupName
        $UserGroupMembers.id.Count | Should -BeGreaterThan 0
    }

    It 'Gets a User Groups membership -ByID' {
        $UserGroupMembers = Get-JCUserGroupMember -ByID $UserGroupID
        $UserGroupMembers.to.id.Count | Should -BeGreaterThan 0
    }

}