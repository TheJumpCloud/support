Describe -Tag:('JCCloudDirectory') 'Add-JCGSuiteMember' {
    BeforeAll {
        $Directories = Get-JCCloudDirectory -Type g_suite

        $NewUser = New-RandomUser -domain "delCloudDirUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $NewGroup = New-JCUserGroup -GroupName 'CloudDirTest'
    }
    It 'Adds a user by username with directory id' {
        $User = Add-JCGSuiteMember -Id $Directories.Id -Username $NewUser.username
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a user by username with directory name' {
        $User = Add-JCGSuiteMember -Name $Directories.Name -Username $NewUser.username
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a user by userID with directory id' {
        $User = Add-JCGSuiteMember -Id $Directories.Id -UserID $NewUser.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a user by userID with directory name' {
        $User = Add-JCGSuiteMember -Id $Directories.Name -Username $NewUser.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a userGroup by Name with directory id' {
        $User = Add-JCGSuiteMember -Id $Directories.Id -GroupName $NewGroup.Name
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a userGroup by Name with directory Name' {
        $User = Add-JCGSuiteMember -Id $Directories.Name -GroupName $NewGroup.Name
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a userGroup by ID with directory id' {
        $User = Add-JCGSuiteMember -Id $Directories.Id -GroupName $NewGroup.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a userGroup by ID with directory Name' {
        $User = Add-JCGSuiteMember -Id $Directories.Name -GroupName $NewGroup.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Added'
    }
    AfterAll {
        Remove-JCUser -UserID $NewUser.Id -force
        Remove-JCUserGroup -GroupID $NewGroup.Id -force
    }
}