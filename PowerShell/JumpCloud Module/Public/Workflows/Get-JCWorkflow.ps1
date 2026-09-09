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