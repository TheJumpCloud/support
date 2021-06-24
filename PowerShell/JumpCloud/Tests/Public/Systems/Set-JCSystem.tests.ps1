Describe -Tag:('JCSystem') 'Set-JCSystem 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Updates the DisplayName and then set it back" {
        $CurrentDisplayName = Get-JCSystem -SystemID $PesterParams_SystemLinux._id | Select-Object DisplayName
        $UpdatedSystem = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -displayName 'NewName'
        $UpdatedSystem.displayName | Should -Be 'NewName'
        Set-JCSystem -SystemID $PesterParams_SystemLinux._id -displayName $CurrentDisplayName.displayName | Out-Null
    }

    It "Updates a system SshPasswordAuthentication -eq True" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -allowSshPasswordAuthentication $true
        $Update.allowSshPasswordAuthentication | Should -Be True
    }

    It "Updates a system SshPasswordAuthentication -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -allowSshPasswordAuthentication $false
        $Update.allowSshPasswordAuthentication | Should -Be False
    }

    It "Updates a system allowSshRootLogin -eq True" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -allowSshRootLogin $true
        $Update.allowSshRootLogin | Should -Be True
    }

    It "Updates a system allowSshRootLogin -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -allowSshRootLogin $false
        $Update.allowSshRootLogin | Should -Be False
    }

    It "Updates a system allowMultiFactorAuthentication -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -allowMultiFactorAuthentication $false
        $Update.allowMultiFactorAuthentication | Should -Be False
    }

    It "Updates a system allowPublicKeyAuthentication -eq True" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -allowPublicKeyAuthentication $true
        $Update.allowPublicKeyAuthentication | Should -Be True
    }

    It "Updates a system allowPublicKeyAuthentication -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -allowPublicKeyAuthentication $false
        $Update.allowPublicKeyAuthentication | Should -Be False
    }

    # 1.13.1 Tests ## $PesterParams_SystemLinux._id MUST BE A WINDOWS OR MAC SYSTEM
    # As of 7/29/19 systemInsights is only available for Windows / Mac
    It "Disables systemInsights on a system" {
        Set-JCSystem -SystemID $PesterParams_SystemLinux._id -systemInsights $true
        $Update = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -systemInsights $false
        $Update.systemInsights.state | Should -Be "deferred"
    }

    It "Enables systemInsights for a system" {
        Set-JCSystem -SystemID $PesterParams_SystemLinux._id -systemInsights $false
        $Update = Set-JCSystem -SystemID $PesterParams_SystemLinux._id -systemInsights $true
        $Update.systemInsights.state | Should -Be "enabled"
    }
}
