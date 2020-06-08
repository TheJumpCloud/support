Describe -Tag:('JCUserGroupMember') 'Remove-JCUserGroupMember 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Removes JumpCloud user from a JumpCloud user group by User GroupName and Username" {

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $PesterParams_UserGroupName -username $PesterParams_Username

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $PesterParams_UserGroupName -username $PesterParams_Username

        $SingleUserGroupRemove.Status | Should Be 'Removed'

    }

    It "Removes a JumpCloud system from a JumpCloud system group by System GroupID and SystemID" {

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $PesterParams_UserGroupID -UserID $PesterParams_UserID

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $PesterParams_UserGroupID -UserID $PesterParams_UserID

        $SingleUserGroupRemove.Status | Should Be 'Removed'
    }

}
