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
                systemId   = $system.systemId
                subject    = $system.Subject
                commonName = $system.CommonName
                issuer     = $system.Issuer
                sha1       = $($system.sha1).toLower()
                serial     = $system.Serial
                path       = $system.path
            }
            $results.Add($DeploymentTable) | Out-Null
        }

    }
    end {
        return $results
    }
}