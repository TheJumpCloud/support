BeforeAll {
    Remove-Module JumpCloud -ErrorAction SilentlyContinue
    Remove-Item Function:\global:Invoke-JCApi -ErrorAction SilentlyContinue
    Remove-Item Function:\global:Connect-JCOnline -ErrorAction SilentlyContinue

    $env:JCApiKey = 'pester-test-api-key'
    $env:JCOrgId = 'pester-test-org-id'

    Import-Module "$PSScriptRoot/../../../JumpCloud.psd1" -Force

    Mock -ModuleName 'JumpCloud' Connect-JCOnline { } -ParameterFilter { $Force -eq $true }
}

Describe 'Get-JCWorkflow' -Tag 'JCWorkflow' {
    Context 'Validating Acceptance Criteria' {

        It 'Should return all workflows in a given org with no parameters specified' {
            Mock -ModuleName 'JumpCloud' Invoke-JCApi {
                return @(
                    @{ id = '123'; name = 'Workflow Alpha' },
                    @{ id = '456'; name = 'Workflow Beta' }
                )
            }

            $result = Get-JCWorkflow
            $result.Count | Should -Be 2
        }

        It 'Should return workflow by ID' {
            Mock -ModuleName 'JumpCloud' Invoke-JCApi {
                return @(
                    @{ id = '123'; name = 'Workflow Alpha' },
                    @{ id = '456'; name = 'Workflow Beta' }
                )
            }

            $result = Get-JCWorkflow -Id '123'
            $result.id | Should -Be '123'
        }

        It 'Should return workflow by Name' {
            Mock -ModuleName 'JumpCloud' Invoke-JCApi {
                return @(
                    @{ id = '123'; name = 'Workflow Alpha' },
                    @{ id = '456'; name = 'Workflow Beta' }
                )
            }

            $result = Get-JCWorkflow -Name 'Workflow Beta'
            $result.name | Should -Be 'Workflow Beta'
        }

        It 'Should return $null when no workflows exist' {
            Mock -ModuleName 'JumpCloud' Invoke-JCApi { return $null }

            $result = Get-JCWorkflow
            $result | Should -BeNullOrEmpty
        }

        It 'Should return $null when ID or Name does not exist' {
            Mock -ModuleName 'JumpCloud' Invoke-JCApi {
                return @( @{ id = '123'; name = 'Workflow Alpha' } )
            }

            (Get-JCWorkflow -Id '999') | Should -BeNullOrEmpty
            (Get-JCWorkflow -Name 'NonExistent') | Should -BeNullOrEmpty
        }
    }
}
