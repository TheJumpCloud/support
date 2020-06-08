Describe -Tag:('JCSystemUser') 'Set-JCSystemUser 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Sets a standard user to an admin user using username" {

        Add-JCSystemUser -SystemID $PesterParams_SystemID -Username $PesterParams_Username -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams_SystemID -Username $PesterParams_Username -Administrator $True
        $CommandResults.Administrator | Should -Be $True
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams_SystemID | Where-Object Username -EQ $PesterParams_Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $True

    }

    It "Sets an admin user to a standard user using username" {

        Set-JCSystemUser -SystemID $PesterParams_SystemID -Username $PesterParams_Username -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams_SystemID -Username $PesterParams_Username -Administrator $False
        $CommandResults.Administrator | Should -Be $False
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams_SystemID | Where-Object Username -EQ $PesterParams_Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $False

    }

    It "Sets a standard user to an admin user using UserID" {

        Set-JCSystemUser -SystemID $PesterParams_SystemID -UserID $PesterParams_UserID -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams_SystemID -UserID $PesterParams_UserID -Administrator $True
        $CommandResults.Administrator | Should -Be $True
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams_SystemID | Where-Object Username -EQ $PesterParams_Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $True

    }

    It "Sets an admin user to a standard user using UserID" {

        Set-JCSystemUser -SystemID $PesterParams_SystemID -UserID $PesterParams_UserID -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams_SystemID -UserID $PesterParams_UserID -Administrator $False
        $CommandResults.Administrator | Should -Be $False
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams_SystemID | Where-Object Username -EQ $PesterParams_Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $False

    }


}
