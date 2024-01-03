function Get-UserFromTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $jsonFilePath,
        [Parameter()]
        [System.String]
        $userid
    )
    begin {
        # Import User.Json/ create list if it does not exist
        if (Test-Path -Path $jsonFilePath -PathType Leaf) {
            $userArray = Get-Content -Raw -Path $jsonFilePath | ConvertFrom-Json -Depth 6
            # If the json is a single item, explicitly make it a list so we can add to it
            If ($userArray.count -eq 1) {
                $array = New-Object System.Collections.ArrayList
                $array.add($userArray)
                $userArray = $array
            }

        } else {
            New-Item -Path $jsonFilePath
            $userArray = @()
        }
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
                throw
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
