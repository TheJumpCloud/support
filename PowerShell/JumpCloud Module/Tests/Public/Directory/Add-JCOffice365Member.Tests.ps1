Describe -Tag:('JCCloudDirectory') 'Add-JCOffice365Member' {
    BeforeAll {
        $Directories = Get-JCCloudDirectory -Type office_365

        $NewUser = New-RandomUser -domain "delCloudDirUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $NewGroup = New-JCUserGroup -GroupName 'CloudDirTestAddO365'
    }
    It 'Adds a user by username with directory id' {
        $User = Add-JCOffice365Member -Id $Directories.Id -Username $NewUser.username
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a user by username with directory name' {
        $User = Add-JCOffice365Member -Name $Directories.Name -Username $NewUser.username
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a user by userID with directory id' {
        $User = Add-JCOffice365Member -Id $Directories.Id -UserID $NewUser.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a user by userID with directory name' {
        $User = Add-JCOffice365Member -Name $Directories.Name -UserID $NewUser.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.UserID | Should -Be $NewUser.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a userGroup by Name with directory id' {
        $User = Add-JCOffice365Member -Id $Directories.Id -GroupName $NewGroup.Name
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a userGroup by Name with directory Name' {
        $User = Add-JCOffice365Member -Name $Directories.Name -GroupName $NewGroup.Name
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a userGroup by ID with directory id' {
        $User = Add-JCOffice365Member -Id $Directories.Id -GroupID $NewGroup.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Adds a userGroup by ID with directory Name' {
        $User = Add-JCOffice365Member -Name $Directories.Name -GroupID $NewGroup.Id
        $User.DirectoryName | Should -Be $Directories.Name
        $User.GroupID | Should -Be $NewGroup.ID
        $User.Status | Should -Be 'Added'
    }
    It 'Attempts to add user by username and userid' {
        {Add-JCOffice365Member -Name $Directories.Name -Username $NewUser.username -userID $NewUser.ID} | Should -Throw
    }
    It 'Attempts to add userGroup by name and ID' {
        {Add-JCOffice365Member -Name $Directories.Name -GroupID $NewGroup.ID -GroupName $NewGroup.Name} | Should -Throw
    }
    It 'Attempts to add a user and a usergroup' {
        {Add-JCOffice365Member -Name $Directories.Name -GroupID $NewGroup.ID -UserID $NewUser.ID} | Should -Throw
    }
    It 'Attempts to add a non-existent user' {
        $User = Add-JCOffice365Member -Name $Directories.Name -Username "Dummy.User"
        $User.Status | Should -Be 'Not Found'
        $User = Add-JCOffice365Member -Name $Directories.Name -UserID 123456
        $User.Status | Should -Be 'Not Found'
    }
    It 'Attempts to add a non-existent group' {
        $Group = Add-JCOffice365Member -Name $Directories.Name -GroupName 'Dummy Group'
        $Group.Status | Should -Be 'Not Found'
        $Group = Add-JCOffice365Member -Name $Directories.Name -GroupID 123456
        $Group.Status | Should -Be 'Not Found'
    }
    AfterEach {
        Set-JcSdkOffice365Association -Office365Id $Directories.Id -Id $NewUser.Id -Type user -Op 'remove' -ErrorAction SilentlyContinue
        Set-JcSdkOffice365Association -Office365Id $Directories.Id -Id $NewGroup.Id -Type user_group -Op 'remove' -ErrorAction SilentlyContinue
    }
    AfterAll {
        Remove-JCUser -UserID $NewUser.Id -force
        Remove-JCUserGroup -GroupID $NewGroup.Id -force
    }
}