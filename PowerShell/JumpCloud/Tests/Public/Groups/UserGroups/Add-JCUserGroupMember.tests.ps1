Describe -Tag:('JCUserGroupMember') 'Add-JCUserGroupMember 1.0' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
    }
    It "Adds a JumpCloud user to a JumpCloud user group by User GroupName and Username" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name -username $PesterParams_User1.Username

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name   -username $PesterParams_User1.Username

        $SingleUserGroupAdd.Status | Should -Be 'Added'
    }



    It "Adds a JumpCloud user to a JumpCloud user group by UserID and Group ID" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $PesterParams_UserGroup.Id -UserID $PesterParams_User1.Id

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $PesterParams_UserGroup.Id -UserID $PesterParams_User1.Id

        $SingleUserGroupAdd.Status | Should -Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline" {

        $MultiUserGroupRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name

        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline using -ByID" {

        $MultiUserGroupRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name    -ByID


        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name   -ByID

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }

}
