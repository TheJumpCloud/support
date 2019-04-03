Describe 'Get-JCCommandResults' {

    It "Gets all JumpCloud command results" {

        $CommandResults = Get-JCCommandResult
        $CommandResults.count | Should -BeGreaterThan 1
        return $CommandResults.count

    }

    It "Gets a single JumpCloud command result using -ByID" {

        $SingleCommand = Get-JCCommandResult | Select-Object -Last 1
        $SingleCommandResult = Get-JCCommandResult -ByID $SingleCommand._id
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty

    }

    It "Gets a single JumpCloud command result without declaring -ByID" {

        $SingleCommand = Get-JCCommandResult | Select-Object -Last 1
        $SingleCommandResult = Get-JCCommandResult $SingleCommand._id
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty

    }

    It "Gets a single JumpCloud command result declaring CommandResultID" {

        $SingleCommand = Get-JCCommandResult | Select-Object -Last 1
        $SingleCommandResult = Get-JCCommandResult -CommandResultID $SingleCommand._id
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty

    }

    It "Gets a single JumpCloud command result using -ByID passed through the pipeline" {

        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1 | Get-JCCommandResult -ByID
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty
    }

    It "Gets a single JumpCloud command result passed through the pipeline without declaring -ByID" {

        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1 | Get-JCCommandResult
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty
    }

    It "Gets all JumpCloud commandresults using -ByID passed through the pipeline" {

        $CommandResults = Get-JCCommandResult | Get-JCCommandResult -ByID
        $CommandResults._id.count | Should -BeGreaterThan 1

    }

    It "Gets all JumpCloud commandresults passed through the pipeline with out declaring -ByID" {

        $CommandResults = Get-JCCommandResult | Get-JCCommandResult
        $CommandResults._id.count | Should -BeGreaterThan 1

    }

}
