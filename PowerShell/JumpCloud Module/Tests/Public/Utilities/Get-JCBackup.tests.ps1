Connect-JCOnlineTest

Describe -Tag:('JCBackup') "Get-JCBackup 1.5.0" {

    It "Backs up JumpCloud users" {

        Get-JCBackup -All

        Test-Path ./"JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV"

        Test-Path ./"JumpCloudSystemUsers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudSystemUsers_$(Get-Date -Format MMddyyyy).CSV"

        Test-Path ./"JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV"

        Test-Path ./"JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV"

        Test-Path ./"JumpCloudSystemGroupMembers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudSystemGroupMembers_$(Get-Date -Format MMddyyyy).CSV"
    }

    It "Backs up JumpCloud users" {
        Get-JCBackup -Users
        Test-Path ./"JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV"
    }
    It "Backs up JumpCloud systems" {
        Get-JCBackup -Systems
        Test-Path ./"JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV"
    }
    It "Backs up JumpCloud system users" {
        Get-JCBackup -SystemUsers
        Test-Path ./"JumpCloudSystemUsers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudSystemUsers_$(Get-Date -Format MMddyyyy).CSV"
    }
    It "Backs up JumpCloud system groups" {
        Get-JCBackup -SystemGroups
        Test-Path ./"JumpCloudSystemGroupMembers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudSystemGroupMembers_$(Get-Date -Format MMddyyyy).CSV"
    }

    It "Backs up JumpCloud user groups" {
        Get-JCBackup -UserGroups
        Test-Path ./"JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV"
    }

    It "Backs up JumpCloud users and user groups" {
        Get-JCBackup -Users -UserGroups

        Test-Path ./"JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV"

        Test-Path ./"JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV" | Should -Be $true
        Remove-Item -Path ./"JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV"
    }

}
