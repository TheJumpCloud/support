Connect-JCTestOrg

Describe 'Remove-JCUserGroupMember 1.0' {

    It "Removes JumpCloud user from a JumpCloud user group by User GroupName and Username" {

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $PesterParams.UserGroupName -username $PesterParams.Username

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $PesterParams.UserGroupName -username $PesterParams.Username

        $SingleUserGroupRemove.Status | Should Be 'Removed'

    }

    It "Removes a JumpCloud system from a JumpCloud system group by System GroupID and SystemID" {

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $PesterParams.UserGroupID -UserID $PesterParams.UserID

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $PesterParams.UserGroupID -UserID $PesterParams.UserID

        $SingleUserGroupRemove.Status | Should Be 'Removed'
    }

}
