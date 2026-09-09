BeforeAll {
    # Loads the main function in the test
    . "$PSScriptRoot/../../../Public/Workflows/Get-JCWorkflow.ps1"

    # Defines the helper command in the session to enable Pester to perform the mock.
    if (-not (Get-Command -Name 'Invoke-JCApi' -ErrorAction SilentlyContinue)) {
        function global:Invoke-JCApi {}
    }
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