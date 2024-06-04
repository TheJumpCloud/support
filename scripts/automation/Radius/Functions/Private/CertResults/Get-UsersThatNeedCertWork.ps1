function Get-UsersThatNeedCertWork {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Object[]]
        $userData
    )

    begin {
        $userList = New-Object System.Collections.ArrayList
    }
    process {

        foreach ($user in $userData) {
            $userSystemAssociations = $user.systemAssociations | Where-Object { $_.osFamily -ne "Ubuntu" } | Sort-Object
            $userSystemsCompleted = $user.deploymentInfo.systemId

            if (-not $userSystemAssociations) {
                # if a user does not have a system associated, add them to the list
                $userList.Add($user) | Out-Null
            }
            foreach ($system in $userSystemAssociations) {
                if ($system.systemId -notin $userSystemsCompleted) {
                    # if user has a single system in their association list that's not in the completed list, add to the return list
                    $userList.Add($user) | Out-Null
                    break
                }
            }
        }
    }
    end {
        return $userList
    }
}