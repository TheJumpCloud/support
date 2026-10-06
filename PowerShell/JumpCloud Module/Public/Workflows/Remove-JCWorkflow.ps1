<#
.SYNOPSIS
Removes an existing JumpCloud workflow.
.DESCRIPTION
Remove-JCWorkflow deletes a specified workflow using its ID or Name.
.EXAMPLE
PS C:\> Remove-JCWorkflow -Id '673dd658ac4a0658c780f9ff' -Force
.EXAMPLE
PS C:\> Remove-JCWorkflow -Name 'Deprecated Sync Workflow'
.PARAMETER Id
The ID of the workflow to remove.
.PARAMETER Name
The Name of the workflow to remove.
.PARAMETER Force
Forces the removal of the workflow without asking for user confirmation.
#>
function Remove-JCWorkflow {
    [CmdletBinding(DefaultParameterSetName = 'ById', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById', ValueFromPipelineByPropertyName = $true)]
        [Alias('workflow_id')]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName', ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]
        $Force
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
            $URL = "$JCUrlBasePath/api/v2/workflows/$Id"
            Write-Debug $URL

            if ($Force -and -not $WhatIfPreference) { $ConfirmPreference = 'None' }
            if ($PSCmdlet.ShouldProcess("Workflow ID: $Id", "Remove Workflow")) {
                return Invoke-JCApi -Method 'DELETE' -Url $URL
            }
        }
        catch {
            $errorMessage = $_.Exception.Message
            throw "Failed to remove workflow '$Id'. Details: $errorMessage"
        }
    }
}