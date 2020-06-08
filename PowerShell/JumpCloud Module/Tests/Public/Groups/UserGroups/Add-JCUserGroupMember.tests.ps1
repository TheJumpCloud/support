Describe -Tag:('JCUserGroupMember') 'Add-JCUserGroupMember 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null }
    It "Adds a JumpCloud user to a JumpCloud user group by User GroupName and Username" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $PesterParams_UserGroupName -username $PesterParams_Username

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $PesterParams_UserGroupName   -username $PesterParams_Username

        $SingleUserGroupAdd.Status | Should -Be 'Added'
    }



    It "Adds a JumpCloud user to a JumpCloud user group by UserID and Group ID" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $PesterParams_UserGroupID -UserID $PesterParams_UserID

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $PesterParams_UserGroupID -UserID $PesterParams_UserID

        $SingleUserGroupAdd.Status | Should -Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline" {

        $MultiUserGroupRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $PesterParams_UserGroupName

        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $PesterParams_UserGroupName

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline using -ByID" {

        $MultiUserGroupRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $PesterParams_UserGroupName    -ByID


        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $PesterParams_UserGroupName   -ByID

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }

}
