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
        # $userArray = Get-UserJsonData
        foreach ($user in $Global:JCRRadiusMembers) {
            $MatchedUser = $GLOBAL:JCRUsers[$user.userID]
            $userArrayObject, $userIndex = Get-UserFromTable -userID $user.userID -jsonFilePath "$JCScriptRoot/users.json"

            if ($userIndex -ge 0) {
                # $userArrayObject
                $currentSystemObject = $userArrayObject.systemAssociations
                $incomingSystemObject = $Global:JCRAssociations[$user.userID].systemAssociations

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
                New-UserTable -id $user.userID -username $MatchedUser.username -localUsername $matchedUser.systemUsername
            }

        }
        # lastly validate users that should no longer be recorded:
        $userArray = Get-UserJsonData
        foreach ($user in $userArray) {
            # If userID from users.json is no longer in RadiusMembers.keys, then:
            If (($user.userId -notin $Global:JCRRadiusMembers.userID) ) {
                # Get User From Table
                $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $user.userId
                # Remove the User From Table
                $userArray = $userArray | Where-Object { $_.userID -ne $user.userId }
            }
        }
    }
    end {
        Set-UserJsonData -userArray $userArray
    }
}