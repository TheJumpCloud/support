<#
.SYNOPSIS
Creates a new JumpCloud workflow.
.DESCRIPTION
New-JCWorkflow creates a new workflow in the connected JumpCloud organization.
.EXAMPLE
PS C:\> $dsl = @{ trigger = @{ type = 'external' }; actions = @( @{ type = 'getApiSystemusers' } ) }
PS C:\> New-JCWorkflow -Name "My Workflow" -ExecutionRoleId "64a2f2...123" -Dsl $dsl

Creates a new active workflow named "My Workflow".
.PARAMETER Name
The name of the workflow.
.PARAMETER Description
The description of the workflow.
.PARAMETER ExecutionRoleId
The Role ID used to identify the workflow execution.
.PARAMETER Dsl
JSON definition of the workflow DSL.
.PARAMETER Status
Status of the workflow. Valid values are 'active' or 'inactive'. Default is 'active'.
#>
function New-JCWorkflow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $ExecutionRoleId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.Object]
        $Dsl,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $Description,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('active', 'inactive')]
        [System.String]
        $Status = 'active'
    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
    }

    process {
        try {
            $URL = "$JCUrlBasePath/api/v2/workflows"
            Write-Debug $URL

            $body = @{
                name              = $Name
                execution_role_id = $ExecutionRoleId
                dsl               = $Dsl
                status            = $Status
            }

            if ($PSBoundParameters.ContainsKey('Description')) {
                $body.Add('description', $Description)
            }

            $jsonBody = $body | ConvertTo-Json -Depth 10 -Compress

            # Use Invoke-JCApi to ensure x-api-key authentication headers are passed correctly
            return Invoke-JCApi -Method 'POST' -Url $URL -Body $jsonBody
        }
        catch {
            throw $_
        }
    }
}