Describe -Tag:('JCCloudDirectory') 'Get-JCCloudDirectory' {
    BeforeAll {
        $Directories = Get-JCCloudDirectory

        $NewUser = New-RandomUser -domain "delCloudDirUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $NewGroup = New-JCUserGroup -GroupName 'CloudDirTest'

        $Directories | ForEach-Object {
            If ($_.Type -eq 'office_365') {
                Set-JcSdkOffice365Association -Office365Id $_.Id -Id $NewUser.Id -Type user -Op 'add'
                Set-JcSdkOffice365Association -Office365Id $_.Id -Id $NewGroup.Id -Type user_group -Op 'add'
            } else {
                Set-JcSdkGSuiteAssociation -GsuiteId $_.Id -Id $NewUser.Id -Type user -Op 'add'
                Set-JcSdkGSuiteAssociation -GsuiteId $_.Id -Id $NewGroup.Id -Type user_group -Op 'add'
            }
        }
    }
    It "Returns all cloud directories" {
        $AllDirectories = Get-JCCloudDirectory
        $AllDirectories | Should -Be 2
    }
    It "Returns gsuite directories" {
        $GsuiteDirectories = Get-JCCloudDirectory -Type gsuite
        $GsuiteDirectories | Should -Be 1
    }
    It "Returns office365 directories" {
        $Office365Directories = Get-JCCloudDirectory -Type office_365
        $Office365Directories | Should -Be 1
    }
    It "Returns directory by Name" {
        $DirectoryByName = Get-JCCloudDirectory -Name 'JumpCloud'
        $DirectoryByName | Should -Not -BeNullOrEmpty
    }
    It "Returns directory by ID" {
        $Directory = $Directories | Select-Object -First 1
        $DirectoryByID = Get-JCCloudDirectory -Id $Directory.Id
        $DirectoryByID | Should -Not -BeNullOrEmpty
    }
    It "Returns user associations by name" {
        $DirectoryByName = Get-JCCloudDirectory -Name 'JumpCloud' -Association Users
        $DirectoryByName | Should -Not -BeNullOrEmpty
    }
    It "Returns user associations by Id" {
        $testDirectory = $Directories | Select-Object -First 1
        $DirectoryById = Get-JCCloudDirectory -Id $testDirectory.Id -Association Users
        $DirectoryById | Should -Not -BeNullOrEmpty
    }
    It "Returns user_group associations by name" {
        $DirectoryByName = Get-JCCloudDirectory -Name 'JumpCloud' -Association UserGroups
        $DirectoryByName | Should -Not -BeNullOrEmpty
    }
    It "Returns user_group associations by Id" {
        $testDirectory = $Directories | Select-Object -First 1
        $DirectoryById = Get-JCCloudDirectory -Id $testDirectory.Id -Association UserGroups
        $DirectoryById | Should -Not -BeNullOrEmpty
    }
    AfterAll {
        Remove-JCUser -UserID $NewUser.Id
        Remove-JCUserGroup -GroupID $NewGroup.Id
    }
}