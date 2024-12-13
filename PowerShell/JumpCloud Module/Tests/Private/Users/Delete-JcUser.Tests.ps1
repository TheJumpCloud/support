Describe -Tag:('JCUser') "Delete-JCUser 2.16.0" {
    BeforeAll {
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $env:JCAPIKEY
        }

        Mock -CommandName Read-Host -MockWith {
            # Return "Y" to simulate 'Yes' answer
            return "Y"
        }
    }

    It "Remove manager and cascade managed users to the new manager" {
        $ManagerUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $ManagerUser2 = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewUser = New-RandomUser -Domain "delUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        # Set the manager for each user
        Set-JCUser -UserID $NewUser._id -ManagerID $ManagerUser._id
        # Remove the manager and set the new manager

        Delete-JCUser -Id $ManagerUser._id -managerId $ManagerUser2._id -Headers $hdrs | Should -Be 'Deleted'

        # The new manager should be set
        Get-JCUser -UserID $NewUser._id | Select-Object -ExpandProperty manager | Should -Be $ManagerUser2._id

        # Clean up
        Remove-JCUser -UserID $ManagerUser2._id -force
        Remove-JCUser -UserID $NewUser._id -force

    }

    It "Remove manager and cascade managed users to NULL" {
        $ManagerUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewUser = New-RandomUser -Domain "delUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        # Set the manager for user
        Set-JCUser -UserID $NewUser._id -ManagerID $ManagerUser._id

        Delete-JCUser -Id $ManagerUser._id -Headers $hdrs | Should -Be 'Deleted'

        # The new manager should be set to NULL
        Get-JCUser -UserID $NewUser._id | Select-Object -ExpandProperty manager | Should -BeNullOrEmpty

        # Clean up
        Remove-JCUser -UserID $NewUser._id -force
    }
}