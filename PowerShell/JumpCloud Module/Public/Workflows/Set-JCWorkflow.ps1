<#
.SYNOPSIS
Updates an existing JumpCloud workflow.
.DESCRIPTION
Set-JCWorkflow updates an existing workflow in the connected JumpCloud organization.
If optional parameters (like Dsl or ExecutionRoleId) are omitted, their existing values are preserved.
.EXAMPLE
PS C:\> Set-JCWorkflow -Id '673dd658ac4a0658c780f9ff' -Name "Updated Workflow Name"
.PARAMETER Id
The ID of the workflow to update.
.PARAMETER Name
The new name of the workflow.
.PARAMETER Description
The new description of the workflow.
.PARAMETER ExecutionRoleId
The Role ID used to identify the workflow execution.
.PARAMETER Dsl
JSON definition of the workflow DSL.
.PARAMETER Status
Status of the workflow. Valid values are 'active' or 'inactive'.
#>
function Set-JCWorkflow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('workflow_id')]
        [System.String]
        $Id,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Alias('WorkflowRole', 'role_id')]
        [System.String]
        $ExecutionRoleId,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [System.Object]
        $Dsl,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $Description,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('active', 'inactive')]
        [System.String]
        $Status
    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
    }

    process {
        # Validar se ao menos um campo editável foi fornecido
        $updatableParams = @('Name', 'ExecutionRoleId', 'Dsl', 'Description', 'Status')
        $hasUpdate = $updatableParams | Where-Object { $PSBoundParameters.ContainsKey($_) }
        if (-not $hasUpdate) {
            throw "No update parameters specified. Please specify at least one property to update (e.g., -Name, -Status, -Dsl)."
        }

        try {
            # Read current workflow state to allow partial updates over PUT
            $current = Get-JCWorkflow -Id $Id
            if (-not $current) {
                throw "Workflow with ID '$Id' was not found."
            }

            $URL = "$JCUrlBasePath/api/v2/workflows/$Id"
            Write-Debug $URL

            $body = @{
                name              = if ($PSBoundParameters.ContainsKey('Name')) { $Name } else { $current.name }
                description       = if ($PSBoundParameters.ContainsKey('Description')) { $Description } else { $current.description }
                execution_role_id = if ($PSBoundParameters.ContainsKey('ExecutionRoleId')) { $ExecutionRoleId } else { $current.execution_role_id }
                dsl               = if ($PSBoundParameters.ContainsKey('Dsl')) { $Dsl } else { $current.dsl }
            }

            if ($PSBoundParameters.ContainsKey('Status')) {
                $body.Add('status', $Status)
            } elseif ($null -ne $current.status) {
                $body.Add('status', $current.status)
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10 -Compress

            return Invoke-JCApi -Method 'PUT' -Url $URL -Body $jsonBody
        }
        catch {
            throw "Failed to update workflow '$Id': $_"
        }
    }
}