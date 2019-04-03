Describe 'Remove-JCUserGroupMember' {

    It "Removes JumpCloud user from a JumpCloud user group by User GroupName and Username" {

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $UserGroupName -username $Username

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $UserGroupName -username $Username

        $SingleUserGroupRemove.Status | Should Be 'Removed'

    }

    It "Removes a JumpCloud system from a JumpCloud system group by System GroupID and SystemID" {

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $UserGroupID -UserID $UserID

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $UserGroupID -UserID $UserID

        $SingleUserGroupRemove.Status | Should Be 'Removed'
    }


    It "Removes two JumpCLoud users from a JumpCloud user group using the pipeline" {
        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $UserGroupName
        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Removed'
    }


    It "Removes two JumpCLoud users from a JumpCloud user group using the pipeline using -ByID" {
        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $UserGroupName  -ByID
        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Removed'
    }
}
