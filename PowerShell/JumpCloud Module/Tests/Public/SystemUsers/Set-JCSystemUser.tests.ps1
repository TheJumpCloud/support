Describe -Tag:('JCSystemUser') 'Set-JCSystemUser 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Sets a standard user to an admin user using username" {

        Add-JCSystemUser -SystemID $PesterParams.SystemID -Username $PesterParams.Username -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams.SystemID -Username $PesterParams.Username -Administrator $True
        $CommandResults.Administrator | Should -Be $true
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $PesterParams.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $true

    }

    It "Sets an admin user to a standard user using username" {

        Set-JCSystemUser -SystemID $PesterParams.SystemID -Username $PesterParams.Username -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams.SystemID -Username $PesterParams.Username -Administrator $False
        $CommandResults.Administrator | Should -Be $false
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $PesterParams.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $false

    }

    It "Sets a standard user to an admin user using UserID" {

        Set-JCSystemUser -SystemID $PesterParams.SystemID -UserID $PesterParams.UserID -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams.SystemID -UserID $PesterParams.UserID -Administrator $True
        $CommandResults.Administrator | Should -Be $true
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $PesterParams.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $true

    }

    It "Sets an admin user to a standard user using UserID" {

        Set-JCSystemUser -SystemID $PesterParams.SystemID -UserID $PesterParams.UserID -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams.SystemID -UserID $PesterParams.UserID -Administrator $False
        $CommandResults.Administrator | Should -Be $false
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $PesterParams.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $false

    }


}
