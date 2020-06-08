Describe -Tag:('JCSystem') 'Set-JCSystem 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Updates the DisplayName and then set it back" {
        $CurrentDisplayName = Get-JCSystem -SystemID $PesterParams_SystemID | Select-Object DisplayName
        $UpdatedSystem = Set-JCSystem -SystemID $PesterParams_SystemID -displayName 'NewName'
        $UpdatedSystem.displayName | Should -be 'NewName'
        Set-JCSystem -SystemID $PesterParams_SystemID -displayName $CurrentDisplayName.displayName | Out-Null
    }

    It "Updates a system SshPasswordAuthentication -eq True" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemID -allowSshPasswordAuthentication $true
        $Update.allowSshPasswordAuthentication | Should -Be True
    }

    It "Updates a system SshPasswordAuthentication -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemID -allowSshPasswordAuthentication $false
        $Update.allowSshPasswordAuthentication | Should -Be False
    }

    It "Updates a system allowSshRootLogin -eq True" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemID -allowSshRootLogin $true
        $Update.allowSshRootLogin | Should -Be True
    }

    It "Updates a system allowSshRootLogin -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemID -allowSshRootLogin $false
        $Update.allowSshRootLogin | Should -Be False
    }

    It "Updates a system allowMultiFactorAuthentication -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemID -allowMultiFactorAuthentication $false
        $Update.allowMultiFactorAuthentication | Should -Be False
    }

    It "Updates a system allowPublicKeyAuthentication -eq True" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemID -allowPublicKeyAuthentication $true
        $Update.allowPublicKeyAuthentication | Should -Be True
    }

    It "Updates a system allowPublicKeyAuthentication -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemID -allowPublicKeyAuthentication $false
        $Update.allowPublicKeyAuthentication | Should -Be False
    }

    # 1.13.1 Tests ## $PesterParams_SystemID MUST BE A WINDOWS OR MAC SYSTEM
    # As of 7/29/19 systemInsights is only available for Windows / Mac

    It "Enables systemInsights for a system" {

        Set-JCSystem -SystemID $PesterParams_SystemId_Windows -systemInsights $false
        $Update = Set-JCSystem -SystemID $PesterParams_SystemId_Windows -systemInsights $true
        $Update.systemInsights.state | Should -Be "enabled"
    }

    It "Disables systemInsights on a system" {
        $Update = Set-JCSystem -SystemID $PesterParams_SystemId_Windows -systemInsights $false
        $Update.systemInsights.state | Should -Be "deferred"
    }
}
