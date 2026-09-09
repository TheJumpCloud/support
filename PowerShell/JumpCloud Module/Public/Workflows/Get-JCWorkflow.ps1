<#
.SYNOPSIS
Returns JumpCloud workflows for the connected organization.
.DESCRIPTION
Get-JCWorkflow returns all workflows in the connected organization. Use the -Id or -Name parameters to return a specific workflow.
.EXAMPLE
PS C:\> Get-JCWorkflow

Returns all workflows in the connected organization.
.EXAMPLE
PS C:\> Get-JCWorkflow -Id '673dd658ac4a0658c780f9ff'

Returns the workflow with the specified id.
.PARAMETER Id
The id of the workflow to return.
.PARAMETER Name
The name of the workflow to return.
#>
function Get-JCWorkflow {
    [CmdletBinding(DefaultParameterSetName = 'ByAll')]
    param (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [Alias('workflow_id')]
        [System.String]
        $Id,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName')]
        [System.String]
        $Name
    )

    begin {
        Connect-JCOnline -Force | Out-Null
    }

    process {
        try {
            $workflows = Invoke-JCApi -Method GET -Url '/api/v2/workflows'

            if (-not $workflows) {
                return $null
            }

            if ($PSCmdlet.ParameterSetName -eq 'ById' -and $Id) {
                return ($workflows | Where-Object { $_.id -eq $Id })
            }

            if ($PSCmdlet.ParameterSetName -eq 'ByName' -and $Name) {
                return ($workflows | Where-Object { $_.name -eq $Name })
            }

            return $workflows
        }
        catch {
            Write-Error $_
        }
    }
}