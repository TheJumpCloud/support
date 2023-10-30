Describe -Tag:('JCBackup') "Get-JCBackup 1.5.0" {
    BeforeAll {

        If (-not (Get-JCAssociation -Type:('user') -Name:($PesterParams_User1.username) -TargetType:('system') -IncludeNames | Where-Object { $_.TargetName -eq $PesterParams_SystemLinux.displayName })) {
            Add-JCAssociation -Type:('user') -Name:($PesterParams_User1.username) -TargetType:('system') -TargetName:($PesterParams_SystemLinux.displayName) -Force
        }
        # Create new user and system group

        $BackupTestsUserGroup = New-JCUserGroup -GroupName "backup_usr_$(New-RandomString -NumberOfChars 5)"
        $BackupTestsSystemGroup = New-JCSystemGroup -GroupName "backup_sys_$(New-RandomString -NumberOfChars 5)"
        Add-JCUserGroupMember -GroupName $BackupTestsUserGroup.Name -username $PesterParams_User1.Username
        Add-JCSystemGroupMember -GroupName $BackupTestsSystemGroup.Name -SystemID $PesterParams_SystemLinux._id
    }
    AfterAll {
        # Remove user and system groups
        Remove-JCUserGroup -GroupName $BackupTestsUserGroup.Name -force
        Remove-JCSystemGroup -GroupName $BackupTestsSystemGroup.Name -force
    }
    It "Backs up JumpCloud users" {
        Get-JCBackup -All
        $Files = Get-ChildItem -Path:('JumpCloud*_*.csv')
        ($Files | Where-Object { $_.Name -match 'JumpCloudUsers_' }) | Should -BeTrue
        ($Files | Where-Object { $_.Name -match 'JumpCloudSystemUsers_' }) | Should -BeTrue
        ($Files | Where-Object { $_.Name -match 'JumpCloudUserGroupMembers_' }) | Should -BeTrue
        ($Files | Where-Object { $_.Name -match 'JumpCloudSystemGroupMembers_' }) | Should -BeTrue
        $Files | Remove-Item
    }
    It "Backs up JumpCloud users" {
        Get-JCBackup -Users
        $Files = Get-ChildItem -Path:('JumpCloud*_*.csv')
        ($Files | Where-Object { $_.Name -match 'JumpCloudUsers_' }) | Should -BeTrue
        $Files | Remove-Item
    }
    It "Backs up JumpCloud systems" {
        Get-JCBackup -Systems
        $Files = Get-ChildItem -Path:('JumpCloud*_*.csv')
        ($Files | Where-Object { $_.Name -match 'JumpCloudSystems_' }) | Should -BeTrue
        $Files | Remove-Item
    }
    It "Backs up JumpCloud system users" {
        Get-JCBackup -SystemUsers
        $Files = Get-ChildItem -Path:('JumpCloud*_*.csv')
        ($Files | Where-Object { $_.Name -match 'JumpCloudSystemUsers_' }) | Should -BeTrue
        $Files | Remove-Item
    }
    It "Backs up JumpCloud system groups" {
        Get-JCBackup -SystemGroups
        $Files = Get-ChildItem -Path:('JumpCloud*_*.csv')
        ($Files | Where-Object { $_.Name -match 'JumpCloudSystemGroupMembers_' }) | Should -BeTrue
        $Files | Remove-Item
    }
    It "Backs up JumpCloud user groups" {
        Get-JCBackup -UserGroups
        $Files = Get-ChildItem -Path:('JumpCloud*_*.csv')
        ($Files | Where-Object { $_.Name -match 'JumpCloudUserGroupMembers_' }) | Should -BeTrue
        $Files | Remove-Item
    }
    It "Backs up JumpCloud users and user groups" {
        Get-JCBackup -Users -UserGroups
        $Files = Get-ChildItem -Path:('JumpCloud*_*.csv')
        ($Files | Where-Object { $_.Name -match 'JumpCloudUsers_' }) | Should -BeTrue
        ($Files | Where-Object { $_.Name -match 'JumpCloudUserGroupMembers_' }) | Should -BeTrue
        $Files | Remove-Item
    }
}
