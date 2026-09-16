Describe -Tag('JCWorkflow') 'New-JCWorkflow 1.0' {
    BeforeAll {
        Import-Module "$PSScriptRoot/../../../JumpCloud.psd1" -Force

        # Ensure connection is initialized
        if ([string]::IsNullOrEmpty($global:JCAPIKEY) -and [string]::IsNullOrEmpty($env:JCAPIKEY)) {
            [void](Connect-JCOnline)
        } else {
            [void](Connect-JCOnline -JumpCloudAPIKey ($global:JCAPIKEY ?? $env:JCAPIKEY) -Force)
        }

        # Safely retrieve Role ID for execution
        $script:roleId = InModuleScope 'JumpCloud' {
            $roles = Invoke-JCApi -Method GET -Url "$JCUrlBasePath/api/v2/roles"
            if ($roles.results -and $roles.results.Count -gt 0) {
                return $roles.results[0].id
            } elseif ($roles -and $roles.Count -gt 0) {
                return $roles[0].id
            }
            return $null
        }

        # Valid DSL structure
        $script:dsl = @{
            schedule = @{
                on = @{
                    one = @{
                        with = @{
                            source = "external"
                        }
                    }
                }
            }
            do = @(
                @{
                    getSystemUsers = @{
                        call = "jc_operation"
                        with = @{
                            operationId = "getApiSystemusers"
                            queryParams = @{
                                limit = 10
                            }
                        }
                    }
                }
            )
        }

        # List to track created resources for teardown
        $script:createdWorkflowIds = [System.Collections.Generic.List[string]]::new()
    }

    AfterAll {
        # Hygiene cleanup for all created test workflows
        foreach ($workflowId in $script:createdWorkflowIds) {
            try {
                InModuleScope 'JumpCloud' {
                    Invoke-JCApi -Method DELETE -Url "$JCUrlBasePath/api/v2/workflows/$workflowId"
                }
            } catch {
                # Ignore cleanup errors if already purged
            }
        }
    }

    It "Creates a new workflow when required parameters are specified" {
        $workflowName = "Pester_New_$(Get-Random)"
        $newWorkflow = New-JCWorkflow -Name $workflowName -ExecutionRoleId $script:roleId -Dsl $script:dsl

        $newWorkflow | Should -Not -BeNullOrEmpty
        $newWorkflow.id | Should -Not -BeNullOrEmpty
        $newWorkflow.name | Should -Be $workflowName
        $newWorkflow.execution_role_id | Should -Be $script:roleId

        # Register for teardown
        if ($newWorkflow.id) {
            $script:createdWorkflowIds.Add($newWorkflow.id)
        }
    }

    It "Throws an error when mandatory parameters are invalid" {
        { New-JCWorkflow -Name "Invalid_Test" -ExecutionRoleId "invalid-role-id-999" -Dsl $script:dsl } | Should -Throw
    }
}