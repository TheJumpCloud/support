Connect-JCOnlineTest
Describe -Tag:('JCCommandResult') 'Remove-JCCommandResult 1.0' {

    <#
    It "Ensures the warning message is displayed by default, Deletes a single JumpCloud command result declaring -CommandResultIT" {
        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1
        $DeletedResult = Remove-JCCommandResult -CommandResultID $SingleCommandResult._id
        $DeletedResult._id.count | Should -Be 1
    }
    #>

    It "Removes a JumpCloud command result using -CommandResultID with the force paramter" {
        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1
        $DeletedResult = Remove-JCCommandResult -CommandResultID $SingleCommandResult._id -force
        $DeletedResult._id.count | Should -Be 1
    }

    It "Removes a JumpCloud command result passed through the pipeline with the force parameter without declaring -CommandResultID" {

        $DeletedResult = Get-JCCommandResult | Select-Object -Last 1 | Remove-JCCommandResult -force
        $DeletedResult._id.count | Should -Be 1

    }

    It "Removes two JumpCloud command results passed through the pipeline with force parameter without declaring -CommandResultID" {
        $DeletedResult = Get-JCCommandResult | Select-Object -Last 2 | Remove-JCCommandResult -force
        $DeletedResult._id.count | Should -Be 2

    }

}
