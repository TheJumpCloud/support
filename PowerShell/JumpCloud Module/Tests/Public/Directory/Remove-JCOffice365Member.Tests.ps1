Describe -Tag:('JCCloudDirectory') 'Remove-JCOffice365Member' {
    BeforeAll {
        $Directories = Get-JCCloudDirectory -Type office_365

        $NewUser = New-RandomUser -domain "delCloudDirUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $NewGroup = New-JCUserGroup -GroupName 'CloudDirTestRemoveO365'

        Set-JcSdkOffice365Association -Office365Id $Directories.Id -Id $NewUser.Id -Type user -Op 'add'
        Set-JcSdkOffice365Association -Office365Id $Directories.Id -Id $NewGroup.Id -Type user_group -Op 'add'
    }
    It 'Removes a user by username with directory id' {
        $User = Remove-JCOffice365Member -Id $Directories.Id -Username $NewUser.username
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a user by username with directory name' {
        $User = Remove-JCOffice365Member -Name $Directories.Name -Username $NewUser.username
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a user by userID with directory id' {
        $User = Remove-JCOffice365Member -Id $Directories.Id -UserID $NewUser.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a user by userID with directory name' {
        $User = Remove-JCOffice365Member -Name $Directories.Name -Username $NewUser.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a userGroup by Name with directory id' {
        $User = Remove-JCOffice365Member -Id $Directories.Id -GroupName $NewGroup.Name
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a userGroup by Name with directory Name' {
        $User = Remove-JCOffice365Member -Name $Directories.Name -GroupName $NewGroup.Name
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a userGroup by ID with directory id' {
        $User = Remove-JCOffice365Member -Id $Directories.Id -GroupName $NewGroup.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Removed'
    }
    It 'Removes a userGroup by ID with directory Name' {
        $User = Remove-JCOffice365Member -Name $Directories.Name -GroupName $NewGroup.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Removed'
    }
    AfterAll {
        Remove-JCUser -UserID $NewUser.Id -force
        Remove-JCUserGroup -GroupID $NewGroup.Id -force
    }
}