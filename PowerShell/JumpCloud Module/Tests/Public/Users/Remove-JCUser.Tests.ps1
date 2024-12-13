Describe -Tag:('JCUser') "Remove-JCUser 1.10" {
    BeforeAll {  }

    It "Remove-JCUser 1.0" {
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $DeleteUser = Remove-JCUser -UserID $NewUser._id -ByID -Force
        $DeleteUser.results | Should -Be 'Deleted'
    }

    It "Removes JumpCloud User by Username and -force" {

        $NewUser = New-RandomUser -Domain "delUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        $RemoveUser = Remove-JCUser  -Username $NewUser.username -force

        $RemoveUser.Results | Should -Be 'Deleted'

    }

    It "Removes JumpCloud User by UserID and -force" {

        $NewUser = New-RandomUser -Domain "delUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        $RemoveUser = Remove-JCUser  -UserID $NewUser._id -force

        $RemoveUser.Results | Should -Be 'Deleted'

    }

}
Describe -Tag:('JCUser') "Remove-JCUser 2.16.0" {
    BeforeAll {

        Mock -CommandName Read-Host -MockWith {
            # Return "Y" to simulate 'Yes' answer
            return "Y"
        }
    }
    It "Removes JumpCloud Manager and cascades the managed user managers to the given manager (id). Test CascadeManager param with by setting a manager id" {
        $ManagerUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $ManagerUser2 = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewUser = New-RandomUser -Domain "delUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        # Set the manager for each user
        Set-JCUser -UserID $NewUser._id -ManagerID $ManagerUser._id
        # Remove the manager and set the new manager

        Mock -CommandName Read-Host -MockWith {
            # Return "Y" to simulate 'Yes' answer
            param (
                [string]$prompt
            )
            if ($prompt -eq "Enter the UserID of the new manager") {
                return $ManagerUser2._id
            }
        }
        $RemoveUser = Remove-JCUser -UserID $ManagerUser._id -CascadeManager ID

        # The manager should be removed and the new manager should be set
        $RemoveUser.Results | Should -Be 'Deleted'
        # The new manager should be set
        Get-JCUser -UserID $NewUser._id | Select-Object -ExpandProperty manager | Should -Be $ManagerUser2._id

        # Clean up
        Remove-JCUser -UserID $ManagerUser2._id -force
        Remove-JCUser -UserID $NewUser._id -force
    }

    It "Removes JumpCloud Manager but also managed by a manager. Test CascadeManager param auto" {
        $ManagerUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $ManagerUser2 = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewUser = New-RandomUser -Domain "delUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        # Set the manager for user
        Set-JCUser -UserID $ManagerUser._id -ManagerID $ManagerUser2._id # ManagerUser2 is the manager of ManagerUser
        Set-JCUser -UserID $NewUser._id -ManagerID $ManagerUser._id
        # Remove the manager and set the new manager
        $RemoveUser = Remove-JCUser -UserID $ManagerUser._id -CascadeManager Auto # Remove ManagerUser and should cascade to ManagerUser2


        # The manager should be removed and the new manager should be set
        $RemoveUser.Results | Should -Be 'Deleted'
        # The new manager should be set to ManagerUser2
        Get-JCUser -UserID $NewUser._id | Select-Object -ExpandProperty manager | Should -Be $ManagerUser2._id

        # Clean up
        Remove-JCUser -UserID $ManagerUser2._id -force
        Remove-JCUser -UserID $NewUser._id -force

    }

    It "Removes JumpCloud user (manager) and set managed users manager to null. Test CascadeManager param null" {
        $ManagerUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewUser = New-RandomUser -Domain "delUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        # Set the manager for user
        Set-JCUser -UserID $NewUser._id -ManagerID $ManagerUser._id
        # Remove the manager and set the new manager
        $RemoveUser = Remove-JCUser -UserID $ManagerUser._id -CascadeManager NULL # Remove ManagerUser and should cascade to ManagerUser2

        # The manager should be removed and the new manager should be set
        $RemoveUser.Results | Should -Be 'Deleted'
        # The new manager should be set to ManagerUser2
        Get-JCUser -UserID $NewUser._id | Select-Object -ExpandProperty manager | Should -BeNullOrEmpty

        # Clean up
        Remove-JCUser -UserID $NewUser._id -force
    }

    It "Tests for CascadeManager param with Force" {
        $ManagerUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewUser = New-RandomUser -Domain "delUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser

        # Set the manager for user
        Set-JCUser -UserID $NewUser._id -ManagerID $ManagerUser._id

        Remove-JCUser -UserID $ManagerUser._id -CascadeManager NULL -force | Should -Throw

        # Clean up
        Remove-JCUser -UserID $NewUser._id -force
    }
}