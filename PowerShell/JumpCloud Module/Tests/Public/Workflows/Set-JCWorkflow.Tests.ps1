Describe -Tag('JCWorkflow') 'Set-JCWorkflow 1.0' {
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

        # Create initial workflow for update test
        $script:initialName = "Pester_Set_Initial_$(Get-Random)"
        $script:testWorkflow = New-JCWorkflow -Name $script:initialName -ExecutionRoleId $script:roleId -Dsl $script:dsl
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

    It "Updates an existing workflow when required parameters are specified" {
        $updatedName = "Pester_Set_Updated_$(Get-Random)"
        $result = Set-JCWorkflow -Id $script:testWorkflow.id -Name $updatedName -ExecutionRoleId $script:roleId -Dsl $script:dsl

        $result | Should -Not -BeNullOrEmpty
        $result.id | Should -Be $script:testWorkflow.id
        $result.name | Should -Be $updatedName
    }

    It "Throws an error when parameters or ID are invalid" {
        { Set-JCWorkflow -Id "invalid-id-99999" -Name "Should Fail" } | Should -Throw
    }
}