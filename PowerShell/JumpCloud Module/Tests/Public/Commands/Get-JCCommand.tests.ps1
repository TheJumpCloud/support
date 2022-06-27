Describe -Tag:('JCCommand') 'Get-JCCommand 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Gets all JumpCloud commands" {
        $AllCommands = Get-JCCommand
        $AllCommands._id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud command  declaring -CommandID" {
        $SingleCommand = Get-JCCommand | Select-Object -Last 1
        $SingleResult = Get-JCCommand -CommandID $SingleCommand._id
        $SingleResult._id.Count | Should -Be 1

    }

    It "Gets a single JumpCloud command  without declaring -CommandID" {
        $SingleCommand = Get-JCCommand | Select-Object -Last 1
        $SingleResult = Get-JCCommand $SingleCommand._id
        $SingleResult._id.Count | Should -Be 1
    }

    It "Gets a single JumpCloud command using -ByID passed through the pipeline" {
        $SingleResult = Get-JCCommand | Select-Object -Last 1 | Get-JCCommand -ByID
        $SingleResult._id.Count | Should -Be 1
    }

    It "Gets a single JumpCloud command passed through the pipeline without declaring -ByID" {
        $SingleResult = Get-JCCommand | Select-Object -Last 1 | Get-JCCommand
        $SingleResult._id.Count | Should -Be 1
    }


    It "Gets all JumpCloud command passed through the pipeline declaring -ByID" {
        $MultiResult = Get-JCCommand | Get-JCCommand -ByID
        $MultiResult._id.Count | Should -BeGreaterThan 1
    }

    It "Gets all JumpCloud command triggers" {
        $Triggers = Get-JCCommand | Where-Object trigger -ne ''
        $Triggers._id.Count | Should -BeGreaterThan 1
    }
}

Describe -Tag('JCCommand') 'Get-JCCommand Search' {
    BeforeAll {
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        # Get Command3 because it does not contain a wildcard
        $PesterParams_Command3 = Get-JCCommand -CommandID:($PesterParams_Command3.Id)
    }
    It "Searches a JumpCloud command by name" {
        $Command = Get-JCCommand -name $PesterParams_Command3.name
        $Command.name | Should -Be $PesterParams_Command3.name
    }
    It "Searches a JumpCloud command by command" {
        $Command = Get-JCCommand -command $PesterParams_Command3.command
        $Command.command | Should -Be $PesterParams_Command3.command
    }
    It "Searches a JumpCloud command by commandType" {
        $Command = Get-JCCommand -commandType $PesterParams_Command3.commandType
        $Command.commandType | Should -Bein $PesterParams_Command3.commandType
    }
    It "Searches a JumpCloud command by launchType" {
        $Command = Get-JCCommand -launchType $PesterParams_Command3.launchType
        $Command.launchType | Should -Bein $PesterParams_Command3.launchType
    }
    It "Searches a JumpCloud command by trigger" {
        $Command = Get-JCCommand -trigger $PesterParams_Command3.trigger
        $Command.trigger | Should -Be $PesterParams_Command3.trigger
    }
    It "Searches a JumpCloud command by scheduleRepeatType" {
        $Command = Get-JCCommand -scheduleRepeatType $PesterParams_Command3.scheduleRepeatType
        $Command.scheduleRepeatType | Should -Bein $PesterParams_Command3.scheduleRepeatType
    }
}