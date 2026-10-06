Describe -Tag('JCWorkflow') 'Remove-JCWorkflow 1.0' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../../../JumpCloud.psd1" -Force

        if ([string]::IsNullOrEmpty($global:JCAPIKEY) -and [string]::IsNullOrEmpty($env:JCAPIKEY)) {
            [void](Connect-JCOnline)
        } else {
            [void](Connect-JCOnline -JumpCloudAPIKey ($global:JCAPIKEY ?? $env:JCAPIKEY) -Force)
        }

        $script:roleId = InModuleScope 'JumpCloud' {
            $roles = Invoke-JCApi -Method GET -Url "$JCUrlBasePath/api/v2/roles"
            if ($roles.results -and $roles.results.Count -gt 0) {
                return $roles.results[0].id
            } elseif ($roles -and $roles.Count -gt 0) {
                return $roles[0].id
            }
            return $null
        }

        $script:dsl = @{
            schedule = @{ on = @{ one = @{ with = @{ source = "external" } } } }
            do = @( @{ getSystemUsers = @{ call = "jc_operation"; with = @{ operationId = "getApiSystemusers"; queryParams = @{ limit = 10 } } } } )
        }
    }

    It "Removes a workflow by ID using -Force" {
        $testName = "Pester_Remove_ID_$(Get-Random)"
        $workflow = New-JCWorkflow -Name $testName -ExecutionRoleId $script:roleId -Dsl $script:dsl

        { Remove-JCWorkflow -Id $workflow.id -Force } | Should -Not -Throw

        # Confirm it is deleted by catching the expected 404 from Get-JCWorkflow
        { Get-JCWorkflow -Id $workflow.id } | Should -Throw "*404 (Not Found)*"
    }

    It "Removes a workflow by Name using -Force" {
        $testName = "Pester_Remove_Name_$(Get-Random)"
        $workflow = New-JCWorkflow -Name $testName -ExecutionRoleId $script:roleId -Dsl $script:dsl

        { Remove-JCWorkflow -Name $testName -Force } | Should -Not -Throw

        # Confirm it is deleted by catching the expected 404/Empty from Get-JCWorkflow
        $deleted = Get-JCWorkflow -Name $testName
        $deleted | Should -BeNullOrEmpty
    }

    It "Accepts workflow object via pipeline" {
        $testName = "Pester_Remove_Pipeline_$(Get-Random)"
        $workflow = New-JCWorkflow -Name $testName -ExecutionRoleId $script:roleId -Dsl $script:dsl

        { $workflow | Remove-JCWorkflow -Force } | Should -Not -Throw

        { Get-JCWorkflow -Id $workflow.id } | Should -Throw "*404 (Not Found)*"
    }

    It "Supports -WhatIf parameter" {
        $testName = "Pester_Remove_WhatIf_$(Get-Random)"
        $workflow = New-JCWorkflow -Name $testName -ExecutionRoleId $script:roleId -Dsl $script:dsl

        $result = Remove-JCWorkflow -Id $workflow.id -WhatIf
        $result | Should -BeNullOrEmpty

        # Ensure it was NOT actually deleted (Get-JCWorkflow should NOT throw)
        { Get-JCWorkflow -Id $workflow.id } | Should -Not -Throw

        # Cleanup
        Remove-JCWorkflow -Id $workflow.id -Force
    }

    It "Throws when workflow ID or Name is invalid" {
        { Remove-JCWorkflow -Id "invalid-id-99999" -Force } | Should -Throw "*Failed to remove workflow*"
        { Remove-JCWorkflow -Name "NonExistentWorkflowName_99999" -Force } | Should -Throw "*was not found*"
    }
}