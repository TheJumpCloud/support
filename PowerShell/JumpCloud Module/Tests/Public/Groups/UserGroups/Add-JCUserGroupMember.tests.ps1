Describe -Tag:('JCUserGroupMember') 'Add-JCUserGroupMember 1.0' {
    BeforeAll {
        $user1 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
        $user2 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))

        $NewUser1 = @{
            email     = "pt-$($user1)su@DeleteMe.com"
            firstname = 'pester_sysUser1'
            lastname  = 'pester_sysLastName'
            username  = "pt.$($user1)"
        };
        $testUser = New-JCUser @NewUser1

        $NewUser2 = @{
            email     = "pt-$($user2)su@DeleteMe.com"
            firstname = 'pester_sysUser2'
            lastname  = 'pester_sysLastName'
            username  = "pt.$($user2)"
        };
        $testUser2 = New-JCUser @NewUser2

        $groupName = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
        $testUserGroup = New-JCUserGroup -GroupName "pt-$groupName"
    }
    It "Adds a JumpCloud user to a JumpCloud user group by User GroupName and Username" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $testUserGroup.Name -username $testUser.Username

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $testUserGroup.Name   -username $testUser.Username

        $SingleUserGroupAdd.Status | Should -Be 'Added'
    }



    It "Adds a JumpCloud user to a JumpCloud user group by UserID and Group ID" {

        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $testUserGroup.Id -UserID $testUser.Id

        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $testUserGroup.Id -UserID $testUser.Id

        $SingleUserGroupAdd.Status | Should -Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline" {
        $users = Get-JCUser | Where-Object { ($_.username -eq "$($testUser.username)") -OR ($_.username -eq "$($testUser2.username)") }

        $MultiUserGroupRemove = $users | Remove-JCUserGroupMember -GroupName $testUserGroup.Name

        $MultiUserGroupAdd = $users | Add-JCUserGroupMember -GroupName $testUserGroup.Name

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }


    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline using -ByID" {
        $users = Get-JCUser | Where-Object { ($_.username -eq "$($testUser.username)") -OR ($_.username -eq "$($testUser2.username)") }

        $MultiUserGroupRemove = $users | Remove-JCUserGroupMember -GroupName $testUserGroup.Name -ByID


        $MultiUserGroupAdd = $users | Add-JCUserGroupMember -GroupName $testUserGroup.Name  -ByID

        $MultiUserGroupAdd.Status | Select-Object -Unique | Should -Be 'Added'
    }
    AfterAll {
        Remove-JCUser -Username $testUser.username -force
        Remove-JCUser -Username $testUser2.username -force
        Remove-JCUserGroup -GroupName $testUserGroup.Name -force
    }

}
