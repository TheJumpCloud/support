function Update-JCRUsersJson {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $force
    )
    begin {

    }
    process {
        # validate that the system association data is correct in users.json:
        $userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 6
        foreach ($userid in $Global:JCRRadiusMembers.keys) {

            $MatchedUser = $GLOBAL:JCRUsers[$userid]
            $userArrayObject, $userIndex = Get-UserFromTable -userID $userid -jsonFilePath "$JCScriptRoot/users.json"

            if ($userIndex -ge 0) {
                # $userArrayObject
                $currentSystemObject = $userArrayObject.systemAssociations
                $incomingSystemObject = $Global:JCRAssociations[$userid].systemAssociations
                # determine if there's some difference that needs to be recorded:
                try {
                    $difference = Compare-Object -ReferenceObject $currentSystemObject.systemId -DifferenceObject $incomingSystemObject.systemId
                    if ($difference) {

                        Set-UserTable -index $userIndex -username $MatchedUser.username -localUsername $MatchedUser.systemUsername -systemAssociationsObject ($incomingSystemObject | ConvertFrom-HashTable)
                    }
                } catch {
                    <#Do this if a terminating exception happens#>
                    $difference = $null
                }

            } else {
                # case for new user
                New-UserTable -id $userid -username $MatchedUser.username -localUsername $matchedUser.systemUsername
            }

        }
        # lastly validate users that should no longer be recorded:
        $userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 6
        foreach ($user in $userArray) {
            # If userID from users.json is no longer in RadiusMembers.keys, then:
            If ( -Not ($user.userId -in $Global:JCRRadiusMembers.keys) ) {
                # Get User From Table
                $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $user.userId
                $userArray = $userArray | Where-Object { $_.userID -ne $user.userId }
                # "removing $($user.userid)"
            }
            # Remove the User From Table
        }
    }
    end {
        $userArray | ConvertTo-Json -Depth 6 | Set-Content -Path "$JCScriptRoot/users.json"
    }
}