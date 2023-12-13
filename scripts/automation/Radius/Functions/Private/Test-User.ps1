function Test-User {
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
        # TODO: update if data is older than 30 mins
        if ( -not $GLOBAL:RadiusUserMembership ) {
            $GLOBAL:RadiusUserMembership = Get-JCUserGroupMember -ByID $JCUSERGROUP
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'userid' {
                $matchedUser = $Global:RadiusUserMembership | Where-Object { $userID -in $_.UserId }
                $inputText = $userID
            }
            'username' {
                $matchedUser = $Global:RadiusUserMembership | Where-Object { $username -in $_.Username }
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