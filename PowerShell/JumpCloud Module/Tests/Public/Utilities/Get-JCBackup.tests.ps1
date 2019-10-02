Describe -Tag:('JCBackup') "Get-JCBackup 1.5.0" {
    # Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
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
