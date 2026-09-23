Describe -Tag('JCWorkflow') 'Invoke-JCWorkflow 1.0' {
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

        # Create test workflow to invoke
        $script:testName = "Pester_Invoke_$(Get-Random)"
        $script:testWorkflow = New-JCWorkflow -Name $script:testName -ExecutionRoleId $script:roleId -Dsl $script:dsl
    }

    AfterAll {
        if ($script:testWorkflow.id) {
            try {
                InModuleScope 'JumpCloud' {
                    Invoke-JCApi -Method DELETE -Url "$JCUrlBasePath/api/v2/workflows/$($script:testWorkflow.id)"
                }
            } catch {
                # Ignore cleanup errors
            }
        }
    }

    It "Invokes a workflow by ID" {
        $result = Invoke-JCWorkflow -Id $script:testWorkflow.id
        $result | Should -Not -BeNullOrEmpty
    }

    It "Invokes a workflow by Name" {
        $result = Invoke-JCWorkflow -Name $script:testName
        $result | Should -Not -BeNullOrEmpty
    }

    It "Throws when workflow ID or Name is invalid" {
        { Invoke-JCWorkflow -Id "invalid-id-99999" } | Should -Throw "*Failed to invoke workflow*"
        { Invoke-JCWorkflow -Name "NonExistentWorkflowName_99999" } | Should -Throw "*was not found*"
    }
}