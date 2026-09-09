BeforeAll {
    Remove-Module JumpCloud -ErrorAction SilentlyContinue
    Remove-Item Function:\global:Invoke-JCApi -ErrorAction SilentlyContinue
    Remove-Item Function:\global:Connect-JCOnline -ErrorAction SilentlyContinue

    $env:JCApiKey = 'pester-test-api-key'
    $env:JCOrgId = 'pester-test-org-id'

    Import-Module "$PSScriptRoot/../../../JumpCloud.psd1" -Force

    Mock -ModuleName 'JumpCloud' Connect-JCOnline { } -ParameterFilter { $Force -eq $true }
}

Describe 'New-JCWorkflow' -Tag 'JCWorkflow' {
    Context 'Validating Acceptance Criteria' {

        It 'Should create a workflow with the specified name' {
            Mock -ModuleName 'JumpCloud' Invoke-JCApi {
                return @{ id = '123'; name = 'Workflow Alpha' }
            }

            $result = New-JCWorkflow -Name 'Workflow Alpha'
            $result.name | Should -Be 'Workflow Alpha'
        }

        It 'Should create a workflow with name and description' {
            Mock -ModuleName 'JumpCloud' Invoke-JCApi {
                return @{ id = '456'; name = 'Workflow Beta'; description = 'Test description' }
            }

            $result = New-JCWorkflow -Name 'Workflow Beta' -Description 'Test description'
            $result.description | Should -Be 'Test description'
        }

        It 'Should call Invoke-JCApi with POST method and workflows URL' {
            Mock -ModuleName 'JumpCloud' Invoke-JCApi {
                return @{ id = '789'; name = 'Workflow Gamma' }
            }

            New-JCWorkflow -Name 'Workflow Gamma' | Out-Null

            Should -Invoke -ModuleName 'JumpCloud' Invoke-JCApi -ParameterFilter {
                $Method -eq 'POST' -and $Url -eq '/api/v2/workflows'
            } -Times 1 -Exactly
        }
    }
}
