<#
.SYNOPSIS
Manually triggers or invokes an existing JumpCloud workflow.
.DESCRIPTION
Invoke-JCWorkflow triggers an execution run for a specified workflow using its ID or Name.
.EXAMPLE
PS C:\> Invoke-JCWorkflow -Id '673dd658ac4a0658c780f9ff'
.EXAMPLE
PS C:\> Invoke-JCWorkflow -Name 'Daily User Sync'
.PARAMETER Id
The ID of the workflow to invoke.
.PARAMETER Name
The Name of the workflow to invoke.
#>
function Invoke-JCWorkflow {
    [CmdletBinding(DefaultParameterSetName = 'ById', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById', ValueFromPipelineByPropertyName = $true)]
        [Alias('workflow_id')]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName', ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $Name
    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
    }

    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'ByName') {
                $workflow = Get-JCWorkflow -Name $Name
                if (-not $workflow) {
                    throw "Workflow with Name '$Name' was not found."
                }
                $Id = $workflow.id
            }

            $URL = "$JCUrlBasePath/api/v2/workflows/$Id/runs"
            Write-Debug $URL

            if ($PSCmdlet.ShouldProcess("Workflow ID: $Id", "Invoke Workflow")) {
                # The API requires the "data" key in the POST body
                $body = @{ data = @{} } | ConvertTo-Json -Depth 2 -Compress

                return Invoke-JCApi -Method 'POST' -Url $URL -Body $body
            }
        }
        catch {
            $errorMessage = $_.Exception.Message
            throw "Failed to invoke workflow '$Id'. Details: $errorMessage"
        }
    }
}