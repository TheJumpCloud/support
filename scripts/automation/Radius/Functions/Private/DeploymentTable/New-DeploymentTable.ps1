function New-DeploymentTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.object[]]
        $resultList
    )
    begin {
        $results = New-Object System.Collections.ArrayList
    }
    process {
        # Get User to System Associations:
        foreach ($system in $resultList) {
            $DeploymentTable = [PSCustomObject]@{
                systemId = $system.systemId
                path     = $system.path
            }
            $results.Add($DeploymentTable) | Out-Null
        }

    }
    end {
        return $results
    }
}