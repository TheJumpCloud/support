<#
.SYNOPSIS
Creates a new JumpCloud workflow.
.DESCRIPTION
New-JCWorkflow creates a workflow in the connected organization using the JumpCloud Workflows API.
.EXAMPLE
PS C:\> New-JCWorkflow -Name 'Onboarding Workflow'

Creates a workflow with the specified name.
.EXAMPLE
PS C:\> New-JCWorkflow -Name 'Onboarding Workflow' -Description 'Automates onboarding tasks'

Creates a workflow with the specified name and description.
#>
function New-JCWorkflow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'The name of the workflow.')]
        [System.String]
        $Name,

        [Parameter(Mandatory = $false, HelpMessage = 'The description of the workflow.')]
        [System.String]
        $Description
    )

    begin {
        Connect-JCOnline -Force | Out-Null
    }

    process {
        try {
            # Construct request body payload
            $body = @{
                name = $Name
            }

            if ($PSBoundParameters.ContainsKey('Description')) {
                $body.description = $Description
            }

            # Send POST request to JumpCloud API
            $result = Invoke-JCApi -Method POST -Url '/api/v2/workflows' -Body ($body | ConvertTo-Json -Compress)

            return $result
        }
        catch {
            Write-Error $_
        }
    }
}