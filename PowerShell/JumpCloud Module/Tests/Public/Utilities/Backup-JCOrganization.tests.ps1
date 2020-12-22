Describe -Tag:('JCBackup') "Get-JCBackup 1.5.0" {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        If (-not (Get-JCAssociation -Type:('user') -Name:($PesterParams_User1.username) -TargetType:('system') -IncludeNames | Where-Object { $_.TargetName -eq $PesterParams_SystemLinux.displayName })) {
            Add-JCAssociation -Type:('user') -Name:($PesterParams_User1.username) -TargetType:('system') -TargetName:($PesterParams_SystemLinux.displayName) -Force
        }
        Add-JCUserGroupMember -GroupName $PesterParams_UserGroup.Name -username $PesterParams_User1.Username
        Add-JCSystemGroupMember -GroupName $PesterParams_SystemGroup.Name -SystemID $PesterParams_SystemLinux._id
    }
    It "Backs up JumpCloud Org" {
        $backupLocation = Backup-JCOrganization -Path ./ -All
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'System.json' }) | Should -BeTrue
        ($backupChildItem | Where-Object { $_.Name -match 'SystemGroup.json' }) | Should -BeTrue
        ($backupChildItem | Where-Object { $_.Name -match 'SystemUser.json' }) | Should -BeTrue
        ($backupChildItem | Where-Object { $_.Name -match 'UserGroup.json' }) | Should -BeTrue
        ($backupChildItem | Where-Object { $_.Name -match "$($backupLocation.BaseName).zip" }) | Should -BeTrue
        $backupLocation | Remove-Item -Force
    }
    It "Backs up JumpCloud Org Users" {
        $backupLocation = Backup-JCOrganization -Path ./ -Type SystemUser
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'SystemUser.json' }) | Should -BeTrue
        $backupLocation | Remove-Item -Force
    }
    It "Backs up JumpCloud Org systems" {
        $backupLocation = Backup-JCOrganization -Path ./ -Type System
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'System.json' }) | Should -BeTrue
        $Files | Remove-Item -Force
    }
    It "Backs up JumpCloud Org System Groups" {
        $backupLocation = Backup-JCOrganization -Path ./ -Type SystemGroup
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'SystemGroup.json' }) | Should -BeTrue
        $Files | Remove-Item -Force
    }
    It "Backs up JumpCloud Org User Groups" {
        $backupLocation = Backup-JCOrganization -Path ./ -Type UserGroup
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'UserGroup.json' }) | Should -BeTrue
        $Files | Remove-Item -Force
    }
    # It "Backs up JumpCloud Org with Associations" {
    #     $backupLocation = Backup-JCOrganization -Path ./ -All -Associations
    #     $Files = Get-ChildItem -Path:('JumpCloud*_*.csv')
    #     ($Files | Where-Object { $_.Name -match 'JumpCloudUsers_' }) | Should -BeTrue
    #     ($Files | Where-Object { $_.Name -match 'JumpCloudUserGroupMembers_' }) | Should -BeTrue
    #     $Files | Remove-Item
    # }
}
