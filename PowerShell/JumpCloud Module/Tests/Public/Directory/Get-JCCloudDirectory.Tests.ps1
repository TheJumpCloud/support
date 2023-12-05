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
        $AllDirectories.id | Should -Not -BeNullOrEmpty
        $AllDirectories.Name | Should -Not -BeNullOrEmpty
        $AllDirectories.Type | Should -BeIn "office_365", "g_suite"
    }
    It "Returns gsuite directories" {
        $GsuiteDirectories = Get-JCCloudDirectory -Type g_suite
        $GsuiteDirectories.id | Should -Not -BeNullOrEmpty
        $GsuiteDirectories.Name | Should -Not -BeNullOrEmpty
        $GsuiteDirectories.Type | Should -BeIn "g_suite"
    }
    It "Returns office365 directories" {
        $Office365Directories = Get-JCCloudDirectory -Type office_365
        $Office365Directories.id | Should -Not -BeNullOrEmpty
        $Office365Directories.Name | Should -Not -BeNullOrEmpty
        $Office365Directories.Type | Should -BeIn "office_365"
    }
    It "Returns directory by Name" {
        $Directory = $Directories | Select-Object -First 1
        $DirectoryByName = Get-JCCloudDirectory -Name $Directory.Name
        $DirectoryByName | Should -Not -BeNullOrEmpty
    }
    It "Returns directory by ID" {
        $Directory = $Directories | Select-Object -First 1
        $DirectoryByID = Get-JCCloudDirectory -Id $Directory.Id
        $DirectoryByID | Should -Not -BeNullOrEmpty
    }
    It "Returns user associations by name" {
        $Directory = $Directories | Select-Object -First 1
        $DirectoryByName = Get-JCCloudDirectory -Name $Directory.Name -Association Users
        $DirectoryByName | Should -Not -BeNullOrEmpty
    }
    It "Returns user associations by Id" {
        $testDirectory = $Directories | Select-Object -First 1
        $DirectoryById = Get-JCCloudDirectory -Id $testDirectory.Id -Association Users
        $DirectoryById | Should -Not -BeNullOrEmpty
    }
    It "Returns user_group associations by name" {
        $Directory = $Directories | Select-Object -First 1
        $DirectoryByName = Get-JCCloudDirectory -Name $Directory.Name -Association UserGroups
        $DirectoryByName | Should -Not -BeNullOrEmpty
    }
    It "Returns user_group associations by Id" {
        $testDirectory = $Directories | Select-Object -First 1
        $DirectoryById = Get-JCCloudDirectory -Id $testDirectory.Id -Association UserGroups
        $DirectoryById | Should -Not -BeNullOrEmpty
    }
    AfterAll {
        Remove-JCUser -UserID $NewUser.Id -Force
        Remove-JCUserGroup -GroupID $NewGroup.Id -Force
    }
}