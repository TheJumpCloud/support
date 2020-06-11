Describe -Tag:('JCSystemUser') 'Add-JCSystemUser 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Adds a single user to a single system by Username and SystemID" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams_Username -SystemID $PesterParams_SystemID -force
        $UserAdd = Add-JCSystemUser -Username $PesterParams_Username -SystemID $PesterParams_SystemID
        $UserAdd.Status | Should -Be 'Added'
    }


    It "Adds a single user to a single system by UserID and SystemID" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams_Username -SystemID $PesterParams_SystemID -force
        $UserAdd = Add-JCSystemUser -UserID $PesterParams_UserID -SystemID $PesterParams_SystemID
        $UserAdd.Status | Should -Be 'Added'
    }

    It "Adds two users to a single system using the pipeline and system ID" {
        $MultiUserRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCSystemUser -SystemID $PesterParams_SystemID -force
        $MultiUserAdd = Get-JCUser | Select-Object -Last 2 | Add-JCSystemUser -SystemID $PesterParams_SystemID
        $MultiUserAdd.Status.Count | Should -Be 2
    }

}

Describe -Tag:('JCSystemUser') 'Add-JCSystemUser 1.1.0' {

    It "Adds a JumpCloud User to a JumpCloud System with admin `$False using username" {

        $FalseUser = Add-JCSystemUser -Username $PesterParams_User1.username -SystemID $PesterParams_SystemID -Administrator $False

        $FalseUser.Administrator | Should -Be $False

        $GetUser = Get-JCSystemUser -SystemID $PesterParams_SystemID | Where-Object Username -EQ $FalseUser.Username | Select-Object Administrator

        $GetUser.Administrator | Should -Be $False

    }

    It "Adds a JumpCloud User to a JumpCloud System with admin $False using username" {

        $FalseUser = Add-JCSystemUser -Username $PesterParams_User1.username -SystemID $PesterParams_SystemID -Administrator $False

        $FalseUser.Administrator | Should -Be $False

        $GetUser = Get-JCSystemUser -SystemID $PesterParams_SystemID | Where-Object Username -EQ $FalseUser.Username | Select-Object Administrator

        $GetUser.Administrator | Should -Be $False

    }

    It "Adds a JumpCloud User to a JumpCloud System with admin `$False using UserID" {

        $FalseUser = Add-JCSystemUser -UserID $PesterParams_User1._id -SystemID $PesterParams_SystemID -Administrator $False

        $FalseUser.Administrator | Should -Be $False

        $GetUser = Get-JCSystemUser -SystemID $PesterParams_SystemID | Where-Object Username -EQ $PesterParams_User1.Username | Select-Object Administrator

        $GetUser.Administrator | Should -Be $False

    }

    It "Adds a JumpCloud User to a JumpCloud System with admin `$True using UserID" {

        $UserRemove = Remove-JCSystemUser -Username $PesterParams_Username -SystemID $PesterParams_SystemID -force
        $TrueUser = Add-JCSystemUser -UserID $PesterParams_User1._id -SystemID $PesterParams_SystemID -Administrator $True

        $TrueUser.Administrator | Should -Be $True

        $GetUser = Get-JCSystemUser -SystemID $PesterParams_SystemID | Where-Object Username -EQ $PesterParams_User1.Username | Select-Object Administrator

        $GetUser.Administrator | Should -Be $True

    }

    It "Adds a JumpCloud User to a JumpCloud System with admin $True using username" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams_Username -SystemID $PesterParams_SystemID -force
        $TrueUser = Add-JCSystemUser -Username $PesterParams_User1.username -SystemID $PesterParams_SystemID -Administrator $True

        $TrueUser.Administrator | Should -Be $True

        $GetUser = Get-JCSystemUser -SystemID $PesterParams_SystemID | Where-Object Username -EQ $TrueUser.Username | Select-Object Administrator

        $GetUser.Administrator | Should -Be $True

    }


}
