Describe 'Set-JCSystemUser' {

    It "Sets a standard user to an admin user using username" {
        
        Add-JCSystemUser -SystemID $PesterParams.SystemID -Username $PesterParams.Username -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams.SystemID -Username $PesterParams.Username -Administrator $True
        $CommandResults.Administrator | Should -Be $True
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $PesterParams.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $True

    }

    It "Sets an admin user to a standard user using username" {
        
        Set-JCSystemUser -SystemID $PesterParams.SystemID -Username $PesterParams.Username -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams.SystemID -Username $PesterParams.Username -Administrator $False
        $CommandResults.Administrator | Should -Be $False
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $PesterParams.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $False

    }

    It "Sets a standard user to an admin user using UserID" {
        
        Set-JCSystemUser -SystemID $PesterParams.SystemID -UserID $PesterParams.UserID -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams.SystemID -UserID $PesterParams.UserID -Administrator $True
        $CommandResults.Administrator | Should -Be $True
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $PesterParams.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $True

    }

    It "Sets an admin user to a standard user using UserID" {
        
        Set-JCSystemUser -SystemID $PesterParams.SystemID -UserID $PesterParams.UserID -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $PesterParams.SystemID -UserID $PesterParams.UserID -Administrator $False
        $CommandResults.Administrator | Should -Be $False
        $GetSystem = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $PesterParams.Username | Select-Object Administrator
        $GetSystem.Administrator | Should -Be $False

    }


}
