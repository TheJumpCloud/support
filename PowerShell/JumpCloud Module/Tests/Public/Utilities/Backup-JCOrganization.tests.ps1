Describe -Tag:('JCBackup') "Backup-JCOrganization" {
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
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        Expand-Archive -Path "$zipArchive" -DestinationPath ./
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'System.json' }) | Should -BeTrue
        ($backupChildItem | Where-Object { $_.Name -match 'SystemGroup.json' }) | Should -BeTrue
        ($backupChildItem | Where-Object { $_.Name -match 'SystemUser.json' }) | Should -BeTrue
        ($backupChildItem | Where-Object { $_.Name -match 'UserGroup.json' }) | Should -BeTrue
        ($backupLocation.Parent.EnumerateFiles() | Where-Object { $_.Name -match "$($backupLocation.BaseName).zip" }) | Should -BeTrue
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force

    }
    It "Backs up JumpCloud Org SystemUser" {
        $backupLocation = Backup-JCOrganization -Path ./ -Type SystemUser
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        Expand-Archive -Path "$zipArchive" -DestinationPath ./
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'SystemUser.json' }) | Should -BeTrue
        ($backupLocation.Parent.EnumerateFiles() | Where-Object { $_.Name -match "$($backupLocation.BaseName).zip" }) | Should -BeTrue
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force
    }
    It "Backs up JumpCloud Org System" {
        $backupLocation = Backup-JCOrganization -Path ./ -Type SystemUser
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        Expand-Archive -Path "$zipArchive" -DestinationPath ./
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'SystemUser.json' }) | Should -BeTrue
        ($backupLocation.Parent.EnumerateFiles() | Where-Object { $_.Name -match "$($backupLocation.BaseName).zip" }) | Should -BeTrue
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force
    }
    It "Backs up JumpCloud Org SystemGroup" {
        $backupLocation = Backup-JCOrganization -Path ./ -Type SystemGroup
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        Expand-Archive -Path "$zipArchive" -DestinationPath ./
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'SystemGroup.json' }) | Should -BeTrue
        ($backupLocation.Parent.EnumerateFiles() | Where-Object { $_.Name -match "$($backupLocation.BaseName).zip" }) | Should -BeTrue
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force
    }
    It "Backs up JumpCloud Org UserGroup" {
        $backupLocation = Backup-JCOrganization -Path ./ -Type UserGroup
        $zipArchive = Get-Item "$($backupLocation.FullName).zip"
        Expand-Archive -Path "$zipArchive" -DestinationPath ./
        $backupChildItem = Get-ChildItem $backupLocation.FullName
        ($backupChildItem | Where-Object { $_.Name -match 'UserGroup.json' }) | Should -BeTrue
        ($backupLocation.Parent.EnumerateFiles() | Where-Object { $_.Name -match "$($backupLocation.BaseName).zip" }) | Should -BeTrue
        $zipArchive | Remove-Item -Force
        $backupLocation | Remove-Item -Recurse -Force
    }
    # It "Backs up JumpCloud Org with Associations" {
    #     $backupLocation = Backup-JCOrganization -Path ./ -All -Associations
    #     $Files = Get-ChildItem -Path:('JumpCloud*_*.csv')
    #     ($Files | Where-Object { $_.Name -match 'JumpCloudUsers_' }) | Should -BeTrue
    #     ($Files | Where-Object { $_.Name -match 'JumpCloudUserGroupMembers_' }) | Should -BeTrue
    #     $Files | Remove-Item
    # }
}
