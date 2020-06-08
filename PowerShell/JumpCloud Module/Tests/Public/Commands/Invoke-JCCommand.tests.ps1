Describe -Tag:('JCCommand') 'Invoke-JCCommand 1.0' {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
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


Describe -Tag:('JCCommand') "Invoke-JCCommand 1.4.0" {

    It "Triggers a command with one variable" {

        $Trigger = Invoke-JCCommand -trigger $PesterParams_OneTrigger -NumberOfVariables 1 -Variable1_name 'One' -Variable1_value 'One variable'
        $Trigger.triggered | Should -be 'Invoke - Pester One Variable'

    }

    It "Triggers a command with two variables" {

        $Trigger = Invoke-JCCommand -trigger $PesterParams_TwoTrigger -NumberOfVariables 2 -Variable1_name 'One' -Variable1_value 'One variable' -Variable2_name 'Two' -Variable2_value 'Two Variable'
        $Trigger.triggered | Should -be  'Invoke - Pester Two Variable'
    }

    It "Triggers a command with three variables" {
        $Trigger = Invoke-JCCommand -trigger $PesterParams_ThreeTrigger -NumberOfVariables 3 -Variable1_name 'One' -Variable1_value 'One variable' -Variable2_name 'Two' -Variable2_value 'Two Variable' -Variable3_name 'Three' -Variable3_value 'Three variable'
        $Trigger.triggered | Should -be  'Invoke - Pester Three Variable'

    }

}
