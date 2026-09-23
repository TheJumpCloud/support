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

        # Create initial workflow for update tests
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

    It "Updates full workflow when all required parameters are specified" {
        $updatedName = "Pester_Set_Full_$(Get-Random)"
        $result = Set-JCWorkflow -Id $script:testWorkflow.id -Name $updatedName -ExecutionRoleId $script:roleId -Dsl $script:dsl

        $result | Should -Not -BeNullOrEmpty
        $result.id | Should -Be $script:testWorkflow.id
        $result.name | Should -Be $updatedName
    }

    It "Updates only the name and preserves dsl (partial update)" {
        $partialName = "Pester_Partial_$(Get-Random)"
        $result = Set-JCWorkflow -Id $script:testWorkflow.id -Name $partialName

        $result | Should -Not -BeNullOrEmpty
        $result.name | Should -Be $partialName

        # Confirm state preservation on the remote workflow
        $after = Get-JCWorkflow -Id $script:testWorkflow.id
        $after.name | Should -Be $partialName
        $after.dsl | Should -Not -BeNullOrEmpty
    }

    It "Throws when no update parameters are provided" {
        { Set-JCWorkflow -Id $script:testWorkflow.id } | Should -Throw "*No update parameters specified*"
    }

    It "Throws an error when ID is invalid" {
        { Set-JCWorkflow -Id "invalid-id-99999" -Name "Should Fail" } | Should -Throw "*Failed to update workflow*"
    }
}