Connect-JCTestOrg

Describe 'Add-JCUserGroupMember 1.0' {

    It "Adds a JumpCloud user to a JumpCloud user group by User GroupName and Username" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $PesterParams.UserGroupName -username $PesterParams.Username

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $PesterParams.UserGroupName   -username $PesterParams.Username

        $SingleUserGroupAdd.Status | Should Be 'Added'
    }



    It "Adds a JumpCloud user to a JumpCloud user group by UserID and Group ID" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $PesterParams.UserGroupID -UserID $PesterParams.UserID

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $PesterParams.UserGroupID -UserID $PesterParams.UserID

        $SingleUserGroupAdd.Status | Should Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline" {

        $MultiUserGroupRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $PesterParams.UserGroupName  

        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $PesterParams.UserGroupName  

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline using -ByID" {

        $MultiUserGroupRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $PesterParams.UserGroupName    -ByID


        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $PesterParams.UserGroupName   -ByID

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

}
