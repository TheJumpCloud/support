Describe -Tag:('JCCommand') 'New-JCCommand 1.2' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null }
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
