<#
.SYNOPSIS
Updates an existing JumpCloud workflow.
.DESCRIPTION
Set-JCWorkflow updates an existing workflow in the connected JumpCloud organization.
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
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
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
        try {
            $URL = "$JCUrlBasePath/api/v2/workflows/$Id"
            Write-Debug $URL

            $body = @{}
            if ($PSBoundParameters.ContainsKey('Name')) { $body.Add('name', $Name) }
            if ($PSBoundParameters.ContainsKey('ExecutionRoleId')) { $body.Add('execution_role_id', $ExecutionRoleId) }
            if ($PSBoundParameters.ContainsKey('Dsl')) { $body.Add('dsl', $Dsl) }
            if ($PSBoundParameters.ContainsKey('Description')) { $body.Add('description', $Description) }
            if ($PSBoundParameters.ContainsKey('Status')) { $body.Add('status', $Status) }

            $jsonBody = $body | ConvertTo-Json -Depth 10 -Compress

            return Invoke-JCApi -Method 'PUT' -Url $URL -Body $jsonBody
        }
        catch {
            throw $_
        }
    }
}