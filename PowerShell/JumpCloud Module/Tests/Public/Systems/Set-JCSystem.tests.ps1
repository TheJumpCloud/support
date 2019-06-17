Describe -Tag:('JCSystem') 'Set-JCSystem 1.0' {
    Connect-JCOnlineTest
    It "Updates the DisplyName and then set it back" {
        $CurrentDisplayName = Get-JCSystem -SystemID $PesterParams.SystemID | Select-Object DisplayName
        $UpdatedSystem = Set-JCSystem -SystemID $PesterParams.SystemID -displayName 'NewName'
        $UpdatedSystem.displayName | Should -be 'NewName'
        Set-JCSystem -SystemID $PesterParams.SystemID -displayName $CurrentDisplayName.displayName | Out-Null
    }

    It "Updates a system SshPasswordAuthentication -eq True" {
        $Update = Set-JCSystem -SystemID $PesterParams.SystemID -allowSshPasswordAuthentication $true
        $Update.allowSshPasswordAuthentication | Should -Be True
    }

    It "Updates a system SshPasswordAuthentication -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams.SystemID -allowSshPasswordAuthentication $false
        $Update.allowSshPasswordAuthentication | Should -Be False
    }

    It "Updates a system allowSshRootLogin -eq True" {
        $Update = Set-JCSystem -SystemID $PesterParams.SystemID -allowSshRootLogin $true
        $Update.allowSshRootLogin | Should -Be True
    }

    It "Updates a system allowSshRootLogin -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams.SystemID -allowSshRootLogin $false
        $Update.allowSshRootLogin | Should -Be False
    }

    It "Updates a system allowMultiFactorAuthentication -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams.SystemID -allowMultiFactorAuthentication $false
        $Update.allowMultiFactorAuthentication | Should -Be False
    }

    It "Updates a system allowPublicKeyAuthentication -eq True" {
        $Update = Set-JCSystem -SystemID $PesterParams.SystemID -allowPublicKeyAuthentication $true
        $Update.allowPublicKeyAuthentication | Should -Be True
    }

    It "Updates a system allowPublicKeyAuthentication -eq False" {
        $Update = Set-JCSystem -SystemID $PesterParams.SystemID -allowPublicKeyAuthentication $false
        $Update.allowPublicKeyAuthentication | Should -Be False
    }
}
