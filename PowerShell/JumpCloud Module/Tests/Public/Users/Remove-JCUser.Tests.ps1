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
        Mock -CommandName Delete-JCUser -MockWith { return "Y" }
    }
    It "Tests for CascadeManager param with Force" {
        $ManagerUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        { Remove-JCUser -UserID $ManagerUser._id -CascadeManager NULL -force } | Should -Throw
        # Clean up
        Remove-JCUser -UserID $ManagerUser._id -force
    }
}