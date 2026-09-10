Describe -Tag:('JCWorkflow') 'New-JCWorkflow' {
    BeforeAll {
        $limitURL = "$JCUrlBasePath/api/v2/roles"
        $roles = Get-JCResults -URL $limitURL -method 'GET' -limit 100
        $PesterParams_ExecutionRoleId = ($roles | Select-Object -First 1).id

        $PesterParams_WorkflowDsl = @{
            schedule = @{
                on = @{
                    one = @{
                        with = @{
                            source = 'external'
                        }
                    }
                }
            }
            do       = @()
        }
    }

    It 'Creates a new JumpCloud workflow' {
        $workflowName = "pester-new-workflow-$(Get-Random)"
        $NewWorkflow = New-JCWorkflow -Name $workflowName -ExecutionRoleId $PesterParams_ExecutionRoleId -Dsl $PesterParams_WorkflowDsl

        $NewWorkflow.name | Should -Be $workflowName
        $NewWorkflow.execution_role_id | Should -Be $PesterParams_ExecutionRoleId

        Invoke-JCApi -Method DELETE -Url "/api/v2/workflows/$($NewWorkflow.id)"
    }

    It 'Creates a new JumpCloud workflow with a description' {
        $workflowName = "pester-new-workflow-desc-$(Get-Random)"
        $workflowDescription = 'Pester workflow description'
        $NewWorkflow = New-JCWorkflow -Name $workflowName -Description $workflowDescription -ExecutionRoleId $PesterParams_ExecutionRoleId -Dsl $PesterParams_WorkflowDsl

        $NewWorkflow.name | Should -Be $workflowName
        $NewWorkflow.description | Should -Be $workflowDescription

        Invoke-JCApi -Method DELETE -Url "/api/v2/workflows/$($NewWorkflow.id)"
    }
}
