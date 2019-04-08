Connect-JCTestOrg

Describe "Set-JCCommand 1.7" {

    It "Updates the command" {
        $CmdUpdate = Set-JCCommand -CommandID $PesterParams.SetCommandID -command "Updated command"
        $CmdUpdate.command | Should -be "Updated command"
        $CmdUpdate = Set-JCCommand -CommandID $PesterParams.SetCommandID -command "Not updated command"

    }

    It "Updates the launchType to manual" {
        $CmdUpdate = Set-JCCommand -CommandID $PesterParams.SetCommandID -launchType manual
        $CmdUpdate.launchType | Should -be "manual"
    }

    It "Updates the launchType to trigger" {
        $CmdUpdate = Set-JCCommand -CommandID $PesterParams.SetCommandID -launchType trigger -trigger "pesterTrigger"
        $CmdUpdate.launchType | Should -be "trigger"
        $CmdUpdate.trigger | Should -be "pesterTrigger"
    }

    It "Updates the name" {
        $CmdQuery = Get-JCCommand -CommandID $PesterParams.SetCommandID
        $CmdUpdate = Set-JCCommand -CommandID $PesterParams.SetCommandID -name "Updated name"
        $CmdUpdate.name | Should be "Updated Name"
        $SetBack = Set-JCCommand -CommandID $PesterParams.SetCommandID -name $CmdQuery.name

    }

    It "Updates the timeout" {
        $CmdQuery = Get-JCCommand -CommandID $PesterParams.SetCommandID
        $CmdUpdate = Set-JCCommand -CommandID $PesterParams.SetCommandID -timeout "200"
        $CmdUpdate.timeout | Should be "200"
        $SetBack = Set-JCCommand -CommandID $PesterParams.SetCommandID -timeout $CmdQuery.timeout
    }
}