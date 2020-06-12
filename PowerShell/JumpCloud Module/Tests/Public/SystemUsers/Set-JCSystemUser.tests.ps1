Describe -Tag:('JCSystemUser') 'Set-JCSystemUser 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Sets a standard user to an admin user using username" {

        Add-JCSystemUser -SystemID $PesterParams_SystemLinux._id -Username $PesterParams_User1.Username -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams_SystemLinux._id -Username $PesterParams_User1.Username -Administrator $True
        $CommandResults.Administrator | Should -Be $True
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object Username -EQ $PesterParams_User1.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $True

    }

    It "Sets an admin user to a standard user using username" {

        Set-JCSystemUser -SystemID $PesterParams_SystemLinux._id -Username $PesterParams_User1.Username -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams_SystemLinux._id -Username $PesterParams_User1.Username -Administrator $False
        $CommandResults.Administrator | Should -Be $False
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object Username -EQ $PesterParams_User1.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $False

    }

    It "Sets a standard user to an admin user using UserID" {

        Set-JCSystemUser -SystemID $PesterParams_SystemLinux._id -UserID $PesterParams_User1.Id -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams_SystemLinux._id -UserID $PesterParams_User1.Id -Administrator $True
        $CommandResults.Administrator | Should -Be $True
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object Username -EQ $PesterParams_User1.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $True

    }

    It "Sets an admin user to a standard user using UserID" {

        Set-JCSystemUser -SystemID $PesterParams_SystemLinux._id -UserID $PesterParams_User1.Id -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams_SystemLinux._id -UserID $PesterParams_User1.Id -Administrator $False
        $CommandResults.Administrator | Should -Be $False
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object Username -EQ $PesterParams_User1.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $False

    }


}
