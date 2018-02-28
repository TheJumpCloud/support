#Tests for JumpCloud Module Version 1.3.0

#Fill out below varibles to test

$JC_APIKey = ''

$JCTestUser  = 'GroupAddTest'

$JCTestSystem = ''

Describe 'Connect-JCOnline with force parameter' {

    it "Connects to JumpCloud using the -Force parameter"{

        $Connect = Connect-JCOnline -JumpCloudAPIKey $JC_APIKey -force
        $Connect | Should -be $null
    }

}

Describe 'New-JCCommand and Remove-JCCommand' {

    It "Creates a new Windows command" {

        $NewCommand = New-JCCommand -commandType windows -name windows_test -command 'dir'
        
        $NewCommand.commandType | Should -be 'windows'

        Remove-JCCommand -CommandID $NewCommand._id -force

    } 

    It "Creates a new Mac command" {

        $NewCommand = New-JCCommand -commandType mac -name mac_test -command 'ls'
        
        $NewCommand.commandType | Should -be 'mac'
        
        Remove-JCCommand -CommandID $NewCommand._id -force

    }

    It "Creates a new Linux command" {

        $NewCommand = New-JCCommand -commandType linux -name linux_test -command 'ls'
        
        $NewCommand.commandType | Should -be 'linux'
        
        Remove-JCCommand -CommandID $NewCommand._id -force
    }


}
Describe 'Import-JCCommand' {

    It "Imports a JumpCloud command from a long URL" {

        $Command = Import-JCCommand -URL 'https://github.com/scottd3v/JumpCloudX/blob/master/Command%20Library/Mac/Mac%20-%20List%20All%20Users.md'

        $Command.commandType | Should be 'mac'

        Remove-JCCommand -CommandID $Command._id -force

    }

    It "Imports a JumpCloud command from a short URL" {

        $Command = Import-JCCommand -URL 'https://git.io/JCXC-Mac-ListAllUsers'

        $Command.commandType | Should be 'mac'

        Remove-JCCommand -CommandID $Command._id -force

    }


}
Describe 'Get-JCUser' {

    it "Searches a JumpCloud user by username" {

        $User = Get-JCUser -Username 'find.username'
        $User.username | Should -be 'find.username'
    }

    it "Searches a JumpCloud user by lastname" {

        $User = Get-JCUser -LastName 'FindLastName'
        $User.lastname | Should -be 'FindLastName'
    }

    it "Searches a JumpCloud user by firstname" {

        $User = Get-JCUser -FirstName 'FindFirstName'
        $User.firstname | Should -be 'FindFirstName'

    }

    it "Searches a JumpCloud user by email" {

        $User = Get-JCUser -Email 'find.email@sup.com'
        $User.email | Should -be 'find.email@sup.com'

    }

    it "Searches two JumpCloud users by username" {

        $Search2 = Get-JCUser -Username 'Search2'
        $Search2.Count | Should -Be 2
        $Search2.username | Should  -BeLike 'Search2*'

    }

    it "Searches two JumpCloud users by firstname" {

        $Search2 = Get-JCUser -FirstName 'Search2FN'
        $Search2.Count | Should -Be 2
        $Search2.firstname | Should -BeLike 'Search2FN'

    }

    it "Searches two JumpCloud users by lastname" {

        $Search2 = Get-JCUser -LastName 'Search2LN'
        $Search2.Count | Should -Be 2
        $Search2.lastname | Should -BeLike 'Search2LN'
        
    }

    it "Searches two JumpCloud users by email" {

        $Search2 = Get-JCUser -Email 'search2.'
        $Search2.Count | Should -be  2
        $Search2.email | Should -belike 'search2.*'
    }
}

Describe 'Get-JCGroup -type User Add-JCUserGroupmember' {

    it "Adds a JumpCloud user to JumpCloud groups using the pipleline" {

        $GroupAdds = Get-JCGroup -Type User | Add-JCUserGroupMember -Username $JCTestUser 

        $GroupAdds | Select -ExpandProperty Status -Unique | Should -BeLike 'Added'

    }

    it "Removes a JumpCloud user from JumpCloud groups using the pipleline" {

        $GroupRemoves = Get-JCGroup -Type User | Remove-JCUserGroupMember -Username $JCTestUser 

        $GroupRemoves | Select -ExpandProperty Status -Unique | Should -Be 'Removed'

    }

    it "Adds a JumpCloud system to a JumpCloud system group using the pipeline"{

        $GroupsAdd = Get-JCGroup -Type System | ? name -NotLike *_* | Add-JCSystemGroupMember -SystemID $JCTestSystem

        $GroupsAdd | Select -ExpandProperty Status -Unique |  Should -Be 'Added'

    }

    it "Removes a JumpCloud system from a JumpCloud system group using the pipeline" {

        $GroupsRemove = Get-JCGroup -Type System | ? name -NotLike *_* | Remove-JCSystemGroupMember -SystemID $JCTestSystem

        $GroupsRemove | Select -ExpandProperty Status -Unique | Should -Be 'Removed'

    }

}

