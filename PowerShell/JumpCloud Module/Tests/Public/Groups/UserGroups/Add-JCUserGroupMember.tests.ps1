Describe 'Add-JCUserGroupMember' {

    It "Adds a JumpCloud user to a JumpCloud user group by User GroupName and Username" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $UserGroupName -username $Username

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $UserGroupName -username $Username

        $SingleUserGroupAdd.Status | Should Be 'Added'
    }



    It "Adds a JumpCloud user to a JumpCloud user group by UserID and Group ID" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $UserGroupID -UserID $UserID

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $UserGroupID -UserID $UserID

        $SingleUserGroupAdd.Status | Should Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline" {

        $MultiUserGroupRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $UserGroupName

        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $UserGroupName

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline using -ByID" {

        $MultiUserGroupRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $UserGroupName  -ByID


        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $UserGroupName -ByID

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

}
