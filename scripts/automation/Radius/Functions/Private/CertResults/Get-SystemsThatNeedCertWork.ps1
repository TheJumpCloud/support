function Get-SystemsThatNeedCertWork {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Object[]]
        $userData,
        [Parameter()]
        [System.String]
        $osType
    )

    begin {
        $systemIDList = New-Object System.Collections.ArrayList
    }
    process {

        foreach ($user in $userData) {
            $userSystemAssociations = $user.systemAssociations | Where-Object { $_.osFamily -eq $osType }
            $userSystemsCompleted = ($user.deploymentInfo).SystemId
            foreach ($system in $userSystemAssociations) {
                if ($system.systemId -notin $userSystemsCompleted) {
                    $systemIDList.Add($system) | Out-Null
                }
            }
        }
    }
    end {
        return $systemIDList
    }
}