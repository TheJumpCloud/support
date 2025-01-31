function Test-UserFromHash {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(ParameterSetName = 'username')]
        [System.String]
        $username,
        # Parameter help description
        [Parameter(ParameterSetName = 'userid')]
        [System.String]
        $userID
    )
    begin {
        # Get User Group membership
        if ( -not $Global:JCRUsers ) {
            $Global:JCRUsers = Get-Content -path "$JCScriptRoot/data/userHash.json" | ConvertFrom-Json -AsHashtable
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'userid' {
                # validate that the userID is in the radiusMembership hash:
                if ($Global:JCRRadiusMembers.userID.IndexOf($userID)) {
                    # finally return the $matchedUser object
                    $matchedUser = $Global:JCRUsers[$userID]
                } else {
                    $matchedUser = $null
                }
                $inputText = $userID
            }
            'username' {
                # Get the index of the user within the hashtable
                $matchedIndex = $Global:JCRUsers.values.username.ToLower().IndexOf($username.ToLower())
                if ($matchedIndex -lt 0) {
                    throw "could not find user in cached data: $username"
                }
                # Get the UserID from the keys
                $matchedUserID = $Global:JCRUsers.keys | Select-Object -Index $matchedIndex
                # validate that the userID is in the radiusMembership hash:
                if ($matchedUserID) {
                    # finally return the $matchedUser object
                    $matchedUser = $Global:JCRUsers[$matchedUserID]
                } else {
                    $matchedUser = $null
                }
                $inputText = $username
            }
        }
        if ($matchedUser) {
            Write-Debug "Matched Username Found: $($matchedUser.username)"
        } else {
            Write-Warning "User specified $inputText was not found within the Radius Server Membership Lists"
            return $null
        }
    }
    end {
        return $matchedUser
    }
}