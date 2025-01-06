function Get-UserFromTable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String]
        $userId
    )
    begin {
        $userArray = Get-UserJsonData
        # Get the user from the jsonData
        $userObject = $Global:JCRUsers[$userid]

    }
    process {
        try {
            $userIndex = $userArray.userid.IndexOf($userid)
            if ($userIndex -ge 0) {
                $userArrayObject = $userArray[$userIndex]
                # Write-Host "[status] $($userObject.username) found in users.json at index: $userIndex "
            } else {
                throw "userId: $($userId) was not found in users.json"
            }
        } catch {
            # otherwise plan to append
            $userIndex = $null
            # Write-Host "[status] $($userObject.username) not found in users.json"
        }
    }
    end {
        if ($userArrayObject) {
            return $userArrayObject, $userIndex
        } else {
            return $null, $null
        }
    }
}
