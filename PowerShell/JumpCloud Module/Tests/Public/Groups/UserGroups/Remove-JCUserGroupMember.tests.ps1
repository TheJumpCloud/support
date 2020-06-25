Describe -Tag:('JCUserGroupMember') 'Remove-JCUserGroupMember 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Removes JumpCloud user from a JumpCloud user group by User GroupName and Username" {

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name -username $PesterParams_User1.Username

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name -username $PesterParams_User1.Username

        $SingleUserGroupRemove.Status | Should -Be 'Removed'

    }

    It "Removes a JumpCloud system from a JumpCloud system group by System GroupID and SystemID" {

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $PesterParams_UserGroup.Id -UserID $PesterParams_User1.Id

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $PesterParams_UserGroup.Id -UserID $PesterParams_User1.Id

        $SingleUserGroupRemove.Status | Should -Be 'Removed'
    }

}
