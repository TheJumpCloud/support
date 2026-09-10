Describe -Tag:('JCWorkflow') 'Get-JCWorkflow' {
    BeforeAll {
        $limitURL = "$JCUrlBasePath/api/v2/roles"
        $roles = Get-JCResults -URL $limitURL -method 'GET' -limit 100
        $executionRoleId = ($roles | Select-Object -First 1).id

        if (-not $executionRoleId) {
            throw 'No execution role id found from GET /api/v2/roles'
        }

        $workflowDsl = @{
            schedule = @{
                on = @{
                    one = @{
                        with = @{
                            source = 'external'
                        }
                    }
                }
            }
            do       = @(
                @{
                    getUsers = @{
                        call = 'jc_operation'
                        with = @{
                            operationId = 'getApiSystemusers'
                            queryParams = @{
                                limit = 1
                            }
                        }
                    }
                }
            )
        }

        $workflowName = "pester-get-workflow-$(Get-Random)"
        $PesterParams_Workflow = New-JCWorkflow -Name $workflowName -ExecutionRoleId $executionRoleId -Dsl $workflowDsl -Description 'Pester workflow for Get-JCWorkflow tests'
    }

    AfterAll {
        if ($PesterParams_Workflow -and $PesterParams_Workflow.id) {
            Invoke-JCApi -Method DELETE -Url "/api/v2/workflows/$($PesterParams_Workflow.id)"
        }
    }

    It 'Gets all JumpCloud workflows' {
        $AllWorkflows = Get-JCWorkflow
        $AllWorkflows.Count | Should -BeGreaterThan 0
    }

    It 'Gets a single JumpCloud workflow declaring -Id' {
        $SingleResult = Get-JCWorkflow -Id $PesterParams_Workflow.id
        $SingleResult.id | Should -Be $PesterParams_Workflow.id
    }

    It 'Gets a single JumpCloud workflow by name' {
        $SingleResult = Get-JCWorkflow -Name $PesterParams_Workflow.name
        $SingleResult.name | Should -Be $PesterParams_Workflow.name
    }
}
