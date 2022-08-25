Describe -Tag:('JCCommandResult') 'Get-JCCommandResults 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Gets all JumpCloud command results" {
        $CommandResults = Get-JCCommandResult
        $CommandResults.count | Should -BeGreaterThan 1
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
}
Describe -Tag:('JCCommandResult') "Get-JCCommandResult 1.4.1" {
    It "Returns the total count of JumpCloud command results" {
        $TotalCount = Get-JCCommandResult -TotalCount
        $TotalCount | Should -BeGreaterThan 0
    }
}
Describe -Tag:('JCCommandResult') "Get-JCCommandResult 1.5.0" {
    It "Returns a command result with the SystemID" {
        $CommandResult = Get-JCCommandResult | Select-Object -Last 1
        $VerifySystemID = Get-JCSystem -SystemID $CommandResult.SystemID
        $CommandResult.system | Should -Be $VerifySystemID.displayname
    }
    It "Returns a command result -byID with the SystemID" {
        $CommandResult = Get-JCCommandResult | Select-Object -Last 1 | Get-JCCommandResult -ByID
        $VerifySystemID = Get-JCSystem -SystemID $CommandResult.SystemID
        $CommandResult.system | Should -Be $VerifySystemID.displayname
    }
}
Describe -Tag:('JCCommandResult') "Get-JCCommandResult 2.0" {
    It "Returns command results with the workflowId" {
        $Command = Get-JCCommandResult | Select-Object -First 1
        $CommandResults = Get-JCCommandResult -WorkflowId $Command.workflowId
        $CommandResults | Should -Not -BeNullOrEmpty
    }
    It "Returns command results with the CommandId" {
        $Command = Get-JCCommandResult | Select-Object -First 1
        $CommandResults = Get-JCCommandResult -CommandID $Command.workflowId
        $CommandResults | Should -Not -BeNullOrEmpty
    }
    It "Returns all results for Command via pipeline (command object)" {
        $CommandResults = Get-JCCommand | Get-JCCommandResult -ByCommandID
        $CommandResults | Should -Not -BeNullOrEmpty
    }
    It "Tests the -Detail Parameter should return same data as piped -ById" {
        $cmdResults = Get-JCCommandResult
        $cmdResultsByID = Get-JCCommandResult | Get-JCCommandResult -ByID
        $cmdResultsDetail = Get-JCCommandResult -Detailed
        $origMembers = $cmdResults | GM | Where-Object { $_.MemberType -eq "NoteProperty" }
        $cmdResultsByIDMembers = $cmdResultsByID | GM | Where-Object { $_.MemberType -eq "NoteProperty" }
        $cmdResultsDetailMembers = $cmdResultsDetail | GM | Where-Object { $_.MemberType -eq "NoteProperty" }
        # Test that the commandResults members (command, exitCode, name, requestTime, responseTime, sudo, system, systemId, user, workflowId, _id) are in the detailed results:
        $origMembers.Name | Should -BeIn $cmdResultsByIDMembers.Name
        $origMembers.Name | Should -BeIn $cmdResultsDetailMembers.Name
        # Test that the detailed results should contain the same results as the list all endpoint
        $cmdResultsByID.count | should -Be $cmdResults.count
        $cmdResultsDetail.count | should -Be $cmdResults.count
        # For Each cmdResultsByID & cmdResultsDetail, check that each matching command result id contains the exact same information
        foreach ($byIdResult in $cmdResultsByID) {
            foreach ($detailedResult in $cmdResultsDetail) {
                if ($byIdResult._id -eq $detailedResult._id) {
                    foreach ($byIdMember in $cmdResultsByIDMembers) {
                        # "Checking $($byIdMember.Name) $($byIdResult.$($byIdMember.Name)) Should Be $($detailedResult.$($byIdMember.Name))"
                        $($byIdResult.$($byIdMember.Name)) | Should -Be $($detailedResult.$($byIdMember.Name))
                    }
                }

            }
        }
    }
}
