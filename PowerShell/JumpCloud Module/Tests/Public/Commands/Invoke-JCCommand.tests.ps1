Describe 'Invoke-JCCommand' {

    It "Invokes a single JumpCloud command declaring the -trigger" {
        $SingleTrigger = Get-JCCommand | Where-Object trigger -NotLike '' | Select-Object -Last 1 | Select-Object trigger
        $SingleResult = Invoke-JCCommand -trigger $SingleTrigger.trigger
        $SingleResult.triggered.Count | Should Be 1

    }

    It "Invokes a single JumpCloud command passed through the pipeline from Get-JCCommand without declaring -trigger" {
        $SingleResult = Get-JCCommand | Where-Object trigger -NotLike '' | Select-Object -Last 1 | Invoke-JCCommand
        $SingleResult.triggered.Count | Should Be 1
    }

    It "Invokes two JumpCloud command passed through the pipeline from Get-JCCommand without declaring -trigger" {
        $MultiResult = Get-JCCommand | Where-Object trigger -NotLike '' | Select-Object -Last 2 | Invoke-JCCommand
        $MultiResult.triggered.Count | Should Be 2
    }

}