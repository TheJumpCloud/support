Describe -Tag('JCWorkflow') 'Get-JCWorkflowRun 1.0' {
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

        # Create test workflow and invoke an execution run
        $script:testName = "Pester_WorkflowRun_$(Get-Random)"
        $script:testWorkflow = New-JCWorkflow -Name $script:testName -ExecutionRoleId $script:roleId -Dsl $script:dsl
        $null = Invoke-JCWorkflow -Id $script:testWorkflow.id
        Start-Sleep -Seconds 3
    }

    AfterAll {
        if ($script:testWorkflow.id) {
            try {
                InModuleScope 'JumpCloud' {
                    Invoke-JCApi -Method DELETE -Url "$JCUrlBasePath/api/v2/workflows/$($script:testWorkflow.id)"
                }
            } catch { }
        }
    }

    It "Returns all workflow runs when no parameters are specified" {
        $runs = Get-JCWorkflowRun
        $runs | Should -Not -BeNullOrEmpty
    }

    It "Returns workflow runs by workflow ID" {
        $runs = Get-JCWorkflowRun -Id $script:testWorkflow.id
        $runs | Should -Not -BeNullOrEmpty
    }

    It "Returns workflow runs by workflow Name" {
        $runs = Get-JCWorkflowRun -Name $script:testName
        $runs | Should -Not -BeNullOrEmpty
    }

    It "Accepts workflow object via pipeline" {
        $runs = $script:testWorkflow | Get-JCWorkflowRun
        $runs | Should -Not -BeNullOrEmpty
    }

    It "Throws when workflow Name is invalid" {
        { Get-JCWorkflowRun -Name "NonExistentWorkflowName_99999" } | Should -Throw "*was not found*"
    }
}