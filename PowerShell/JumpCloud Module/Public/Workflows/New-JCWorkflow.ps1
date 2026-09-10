<#
.SYNOPSIS
Creates a new JumpCloud workflow.
.DESCRIPTION
New-JCWorkflow creates a workflow in the connected organization using the JumpCloud Workflows API.
.EXAMPLE
PS C:\> New-JCWorkflow -Name 'Onboarding Workflow' -ExecutionRoleId 'role-id' -Dsl $workflowDsl

Creates a workflow with the specified name, execution role, and DSL.
.EXAMPLE
PS C:\> New-JCWorkflow -Name 'Onboarding Workflow' -Description 'Automates onboarding tasks' -ExecutionRoleId 'role-id' -Dsl $workflowDsl

Creates a workflow with the specified name, description, execution role, and DSL.
.PARAMETER Dsl
The workflow DSL object required by the JumpCloud Workflows API.
.PARAMETER ExecutionRoleId
The role id that the workflow should run as.
.PARAMETER Status
The workflow status. Valid values are active and inactive.
#>
function New-JCWorkflow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'The name of the workflow.')]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, HelpMessage = 'The role id that the workflow should run as.')]
        [System.String]
        $ExecutionRoleId,

        [Parameter(Mandatory = $true, HelpMessage = 'The workflow DSL object required by the JumpCloud Workflows API.')]
        [System.Object]
        $Dsl,

        [Parameter(Mandatory = $false, HelpMessage = 'The description of the workflow.')]
        [System.String]
        $Description,

        [Parameter(Mandatory = $false, HelpMessage = 'The workflow status.')]
        [ValidateSet('active', 'inactive')]
        [System.String]
        $Status = 'active'
    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline -Force | Out-Null
        }

        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        $URI = "$JCUrlBasePath/api/v2/workflows"
    }

    process {
        try {
            $body = @{
                name                = $Name
                dsl                 = $Dsl
                execution_role_id   = $ExecutionRoleId
                status              = $Status
            }

            if ($PSBoundParameters.ContainsKey('Description')) {
                $body.description = $Description
            }

            $jsonbody = $body | ConvertTo-Json -Depth 20 -Compress
            $result = Invoke-RestMethod -Method POST -Uri $URI -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

            return $result
        }
        catch {
            Write-Error $_
        }
    }
}
