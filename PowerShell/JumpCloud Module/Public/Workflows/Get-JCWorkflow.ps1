<#
.SYNOPSIS
Returns JumpCloud workflows for the connected organization.
.DESCRIPTION
Get-JCWorkflow returns all workflows in the connected organization. Use the -Id parameter to return a single workflow from the GET endpoint. Use the -Name parameter to search workflows returned from the LIST endpoint.
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
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById')]
        [Alias('workflow_id')]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName')]
        [System.String]
        $Name
    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }

        [int]$limit = 100
        Write-Debug "Setting limit to $limit"

        $Parallel = $JCConfig.parallel.Calculated
    }

    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'ById' {
                    # Endpoint GET único por ID via Invoke-JCApi
                    $URL = "$JCUrlBasePath/api/v2/workflows/$Id"
                    Write-Debug $URL
                    return Invoke-JCApi -Method 'GET' -Url $URL
                }
                'ByName' {
                    # Endpoint LIST paginado via Get-JCResults + filtro por Nome
                    $URL = "$JCUrlBasePath/api/v2/workflows"
                    Write-Debug $URL

                    if ($Parallel) {
                        $workflows = Get-JCResults -URL $URL -method 'GET' -limit $limit -parallel $true
                    } else {
                        $workflows = Get-JCResults -URL $URL -method 'GET' -limit $limit
                    }

                    return ($workflows | Where-Object { $_.name -eq $Name })
                }
                default {
                    # Endpoint LIST paginado via Get-JCResults
                    $URL = "$JCUrlBasePath/api/v2/workflows"
                    Write-Debug $URL

                    if ($Parallel) {
                        return Get-JCResults -URL $URL -method 'GET' -limit $limit -parallel $true
                    } else {
                        return Get-JCResults -URL $URL -method 'GET' -limit $limit
                    }
                }
            }
        }
        catch {
            Write-Error $_
        }
    }
}