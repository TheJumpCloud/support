Describe -Tag:('JCSystem') 'Set-JCSystem 1.0' {
    BeforeAll {  }
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
Describe -Tag:('JCSystem') "Get-JCSystem 2.1.0 & 2.1.2" {
    BeforeAll {
        # Reset Description
        $systems = Get-JCSystem | Where-Object { $_.description -ne "" }
        foreach ($system in $systems) {
            Set-JCSystem -SystemID $system._id -description ""
        }
    }
    It "Gets/ Sets a JumpCloud system by description" {
        $descriptionText = "Pester"
        $systemBfore = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -description $descriptionText
        $FoundSystem = Get-JCSystem -description $descriptionText
        $FoundSystem._id | Should -Be $($PesterParams_SystemWindows._id)
        # Return system to orig state
        Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -description $systemBfore.description
    }
    It "Sets a System using a pipeline without throwing" {
        $descriptionText = "Pester"
        $systemBfore = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -description $descriptionText
        { Get-JCSystem -description $descriptionText | Set-JCSystem -description "Modified" } | Should -Not -Throw
        # Return system to orig state
        Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -description $systemBfore.description
    }
}
Describe -Tag:('JCSystem') "Set-JCSystem 2.18" {
    It "Sets a primarySystemUser by UserID" {
        $NewUser = New-RandomUser -domain "delPrimarySystemUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        $addUserAssociation = Set-JcSdkSystemAssociation -SystemId $($PesterParams_SystemWindows._id) -Op "add" -Type 'user' -Id $NewUser._id
        $systemAssociations = Get-JcSdkSystemAssociation -SystemId $($PesterParams_SystemWindows._id) -Targets 'user'
        $NewUser._id | Should -BeIn $systemAssociations.ToId

        $primarySystemUser = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -primarySystemUser $NewUser._id
        $primarySystemUserCheck = Get-JCSystem -SystemID $($PesterParams_SystemWindows._id)
        $primarySystemUserCheck.primarySystemUser.id | Should -Be $NewUser._id

        Remove-JCUser -UserID $NewUser._id -ByID -force
    }
    It "Sets a primarySystemUser by Username" {
        $NewUser = New-RandomUser -domain "delPrimarySystemUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        $addUserAssociation = Set-JcSdkSystemAssociation -SystemId $($PesterParams_SystemWindows._id) -Op "add" -Type 'user' -Id $NewUser._id
        $systemAssociations = Get-JcSdkSystemAssociation -SystemId $($PesterParams_SystemWindows._id) -Targets 'user'
        $NewUser._id | Should -BeIn $systemAssociations.ToId

        $primarySystemUser = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -primarySystemUser $NewUser.username
        $primarySystemUserCheck = Get-JCSystem -SystemID $($PesterParams_SystemWindows._id)
        $primarySystemUserCheck.primarySystemUser.id | Should -Be $NewUser._id

        Remove-JCUser -UserID $NewUser._id -ByID -force
    }
    It "Sets a primarySystemUser by Email" {
        $NewUser = New-RandomUser -domain "delPrimarySystemUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        $addUserAssociation = Set-JcSdkSystemAssociation -SystemId $($PesterParams_SystemWindows._id) -Op "add" -Type 'user' -Id $NewUser._id
        $systemAssociations = Get-JcSdkSystemAssociation -SystemId $($PesterParams_SystemWindows._id) -Targets 'user'
        $NewUser._id | Should -BeIn $systemAssociations.ToId

        $primarySystemUser = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -primarySystemUser $NewUser.email
        $primarySystemUserCheck = Get-JCSystem -SystemID $($PesterParams_SystemWindows._id)
        $primarySystemUserCheck.primarySystemUser.id | Should -Be $NewUser._id

        Remove-JCUser -UserID $NewUser._id -ByID -force
    }
    It "Sets a primarySystemUser to null" {
        $NewUser = New-RandomUser -domain "delPrimarySystemUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        $addUserAssociation = Set-JcSdkSystemAssociation -SystemId $($PesterParams_SystemWindows._id) -Op "add" -Type 'user' -Id $NewUser._id
        $systemAssociations = Get-JcSdkSystemAssociation -SystemId $($PesterParams_SystemWindows._id) -Targets 'user'
        $NewUser._id | Should -BeIn $systemAssociations.ToId

        $primarySystemUser = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -primarySystemUser $NewUser.email
        $primarySystemUserCheck = Get-JCSystem -SystemID $($PesterParams_SystemWindows._id)
        $primarySystemUserCheck.primarySystemUser.id | Should -Be $NewUser._id

        $removePrimarySystemUser = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -primarySystemUser $null
        $primarySystemUserCheck = Get-JCSystem -SystemID $($PesterParams_SystemWindows._id)
        $primarySystemUserCheck.primarySystemUser.id | Should -BeNullOrEmpty

        Remove-JCUser -UserID $NewUser._id -ByID -force
    }
    It "Try to set an invalid primarySystemUser" {
        $removePrimarySystemUser = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -primarySystemUser $null
        $primarySystemUser = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -primarySystemUser "RandomUserThatDoesntExist"
        $primarySystemUserCheck = Get-JCSystem -SystemID $($PesterParams_SystemWindows._id)
        $primarySystemUserCheck.primarySystemUser.id | Should -BeNullOrEmpty
    }
    It "Try to set a primarySystemUser that is not associated with the device" {
        $NewUser = New-RandomUser -domain "delPrimarySystemUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        { $primarySystemUser = Set-JCSystem -SystemID $($PesterParams_SystemWindows._id) -primarySystemUser $NewUser.email } | Should -Throw

        Remove-JCUser -UserID $NewUser._id -ByID -force
    }
}