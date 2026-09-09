BeforeAll {
    # Dot-source function file into the test session
    . "$PSScriptRoot/../../../Public/Workflows/New-JCWorkflow.ps1"

    # Define dummy helper function with supported API parameters
    if (-not (Get-Command -Name 'Invoke-JCApi' -ErrorAction SilentlyContinue)) {
        function global:Invoke-JCApi {
            param(
                $Method,
                $Endpoint,
                $Body
            )
        }
    }
}

Describe 'New-JCWorkflow' -Tag 'JCWorkflow' {
    Context 'Validating Acceptance Criteria' {

        It 'Should create a new workflow and return the created object' {
            # Mock successful API response
            Mock Invoke-JCApi {
                return @{ id = '789'; name = 'New Workflow'; description = 'My automated workflow' }
            }

            # Execute cmdlet
            $result = New-JCWorkflow -Name 'New Workflow' -Description 'My automated workflow'

            # Validate output object properties
            $result.id | Should -Be '789'
            $result.name | Should -Be 'New Workflow'
        }
    }
}