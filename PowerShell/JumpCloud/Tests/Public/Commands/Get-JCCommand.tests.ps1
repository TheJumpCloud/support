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
