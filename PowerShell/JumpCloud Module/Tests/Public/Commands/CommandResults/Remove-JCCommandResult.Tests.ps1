Describe -Tag:('JCCommandResult') 'Remove-JCCommandResult 1.0' -Skip {
    <#
    It "Ensures the warning message is displayed by default, Deletes a single JumpCloud command result declaring -CommandResultIT" {
        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1
        $DeletedResult = Remove-JCCommandResult -CommandResultID $SingleCommandResult._id
        $DeletedResult._id.count | Should -Be 1
    }
    #>

    It "Removes a JumpCloud command result using -CommandResultID with the force parameter" {
        # Invoke Command to generate result
        $SingleTrigger = Get-JCCommand | Where-Object trigger -NotLike '' | Select-Object -Last 1 | Select-Object trigger
        $SingleResult = Invoke-JCCommand -trigger $SingleTrigger.trigger
        Start-Sleep -Seconds 5
        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1
        $DeletedResult = Remove-JCCommandResult -CommandResultID $SingleCommandResult._id -force
        $DeletedResult._id.count | Should -Be 1
    }

    It "Removes a JumpCloud command result passed through the pipeline with the force parameter without declaring -CommandResultID" {
        # Invoke Command to generate result
        $SingleTrigger = Get-JCCommand | Where-Object trigger -NotLike '' | Select-Object -Last 1 | Select-Object trigger
        $SingleResult = Invoke-JCCommand -trigger $SingleTrigger.trigger
        Start-Sleep -Seconds 5
        $DeletedResult = Get-JCCommandResult | Select-Object -Last 1 | Remove-JCCommandResult -force
        $DeletedResult._id.count | Should -Be 1

    }

    It "Removes two JumpCloud command results passed through the pipeline with force parameter without declaring -CommandResultID" {
        for ($i = 0; $i -lt 2; $i++) {
            # Invoke Command to generate result
            $SingleTrigger = Get-JCCommand | Where-Object trigger -NotLike '' | Select-Object -Last 1 | Select-Object trigger
            $SingleResult = Invoke-JCCommand -trigger $SingleTrigger.trigger
        }
        Start-Sleep -Seconds 5
        $DeletedResult = Get-JCCommandResult | Select-Object -Last 2 | Remove-JCCommandResult -force
        $DeletedResult._id.count | Should -Be 2

    }

}
