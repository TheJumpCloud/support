Describe -Tag:('JCCloudDirectory') 'Remove-JCGsuiteMember' {
    BeforeAll {
        $Directories = Get-JCCloudDirectory -Type g_suite

        $NewUser = New-RandomUser -domain "delCloudDirUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $NewGroup = New-JCUserGroup -GroupName 'CloudDirTestRemoveGsuite'

        Set-JcSdkGSuiteAssociation -GsuiteId $Directories.Id -Id $NewUser.Id -Type user -Op 'add'
        Set-JcSdkGSuiteAssociation -GsuiteId $Directories.Id -Id $NewGroup.Id -Type user_group -Op 'add'
    }
    It 'Removes a user by username with directory id' {
        $User = Remove-JCGsuiteMember -Id $Directories.Id -Username $NewUser.username
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a user by username with directory name' {
        $User = Remove-JCGsuiteMember -Name $Directories.Name -Username $NewUser.username
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a user by userID with directory id' {
        $User = Remove-JCGsuiteMember -Id $Directories.Id -UserID $NewUser.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a user by userID with directory name' {
        $User = Remove-JCGsuiteMember -Name $Directories.Name -UserID $NewUser.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a userGroup by Name with directory id' {
        $User = Remove-JCGsuiteMember -Id $Directories.Id -GroupName $NewGroup.Name
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a userGroup by Name with directory Name' {
        $User = Remove-JCGsuiteMember -Name $Directories.Name -GroupName $NewGroup.Name
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a userGroup by ID with directory id' {
        $User = Remove-JCGsuiteMember -Id $Directories.Id -GroupID $NewGroup.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a userGroup by ID with directory Name' {
        $User = Remove-JCGsuiteMember -Name $Directories.Name -GroupID $NewGroup.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Attempts to remove user by username and userid' {
        {Remove-JCGsuiteMember -Name $Directories.Name -Username $NewUser.username -userID $NewUser.ID} | Should -Throw
    }
    It 'Attempts to remove userGroup by name and ID' {
        {Remove-JCGsuiteMember -Name $Directories.Name -GroupID $NewGroup.ID -GroupName $NewGroup.Name} | Should -Throw
    }
    It 'Attempts to remove a user and a usergroup' {
        {Remove-JCGsuiteMember -Name $Directories.Name -GroupID $NewGroup.ID -UserID $NewUser.ID} | Should -Throw
    }
    It 'Attempts to remove a non-existent user' {
        { $User = Remove-JCGsuiteMember -Name $Directories.Name -Username "Dummy.User" } | Should -Throw
        $User = Remove-JCGsuiteMember -Name $Directories.Name -UserID 123456
        $User.Status | Should -BeLike 'Bad Request*'
    }
    It 'Attempts to remove a non-existent group' {
        { $Group = Remove-JCGsuiteMember -Name $Directories.Name -GroupName 'Dummy Group' } | Should -Throw
        $Group = Remove-JCGsuiteMember -Name $Directories.Name -GroupID 123456
        $Group.Status | Should -BeLike 'Bad Request*'
    }
    AfterEach {
        Set-JcSdkGSuiteAssociation -GsuiteId $Directories.Id -Id $NewUser.Id -Type user -Op 'add' -ErrorAction SilentlyContinue
        Set-JcSdkGSuiteAssociation -GsuiteId $Directories.Id -Id $NewGroup.Id -Type user_group -Op 'add' -ErrorAction SilentlyContinue
    }
    AfterAll {
        Remove-JCUser -UserID $NewUser.Id -force
        Remove-JCUserGroup -GroupID $NewGroup.Id -force
    }
}