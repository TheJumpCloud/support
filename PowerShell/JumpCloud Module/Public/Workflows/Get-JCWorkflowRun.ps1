<#
.SYNOPSIS
Gets execution runs for JumpCloud workflows.
.DESCRIPTION
Get-JCWorkflowRun retrieves execution run history and status for all workflows or for a specific workflow filtered by ID or Name.
.EXAMPLE
PS C:\> Get-JCWorkflowRun
.EXAMPLE
PS C:\> Get-JCWorkflowRun -Id '673dd658ac4a0658c780f9ff'
.EXAMPLE
PS C:\> Get-JCWorkflowRun -Name 'Daily User Sync'
.PARAMETER Id
The Workflow ID or Workflow Run ID to retrieve.
.PARAMETER Name
The Name of the workflow to retrieve runs for.
#>
function Get-JCWorkflowRun {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('workflow_id', 'run_id')]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
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
        # Lookup Name outside of the main API try-catch block
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $workflow = Get-JCWorkflow -Name $Name
            if (-not $workflow) {
                throw "Workflow with Name '$Name' was not found."
            }
            if ((@($workflow).Count) -gt 1) {
                throw "Multiple workflows found with Name '$Name'. Use -Id instead."
            }
            $Id = $workflow.id
        }

        try {
            if ($PSCmdlet.ParameterSetName -eq 'All') {
                $URL = "$JCUrlBasePath/api/v2/workflows/runs"
                Write-Debug $URL
                $response = Invoke-JCApi -Method 'GET' -Url $URL

                if ($null -ne $response.results) {
                    return $response.results
                }
                return $response
            } else {
                # Query API filtering by workflow_id query parameter
                $URL = "$JCUrlBasePath/api/v2/workflows/runs?workflow_id=$Id"
                Write-Debug $URL
                $response = Invoke-JCApi -Method 'GET' -Url $URL

                $runs = if ($null -ne $response.results) { $response.results } else { $response }

                # Fallback check: If empty, try getting run directly by Run ID (/runs/{runId})
                if ($null -eq $runs -or (@($runs).Count) -eq 0) {
                    try {
                        $runUrl = "$JCUrlBasePath/api/v2/workflows/runs/$Id"
                        Write-Debug $runUrl
                        $singleRun = Invoke-JCApi -Method 'GET' -Url $runUrl
                        if ($singleRun) {
                            return $singleRun
                        }
                    } catch {
                        # Fall through if not found by Run ID
                    }
                }

                return $runs
            }
        }
        catch {
            $errorMessage = $_.Exception.Message
            if ($PSCmdlet.ParameterSetName -ne 'All') {
                throw "Failed to get workflow runs for '$Id'. Details: $errorMessage"
            } else {
                throw "Failed to get workflow runs. Details: $errorMessage"
            }
        }
    }
}