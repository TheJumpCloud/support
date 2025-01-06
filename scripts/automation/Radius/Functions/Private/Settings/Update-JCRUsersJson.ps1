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
        $i = 0
        foreach ($user in $Global:JCRRadiusMembers) {
            $i++
            Write-Progress -activity "Getting User Certificate Info" -status "$($user.username): $i of $($Global:JCRRadiusMembers.Count)" -percentComplete (($i / $Global:JCRRadiusMembers.Count) * 100)
            $MatchedUser = $GLOBAL:JCRUsers[$user.userID]
            $userArrayObject, $userIndex = Get-UserFromTable -userID $user.userID
            try {
                $InstalledCerts = $Global:JCRCertHash["$($userArrayObject.certInfo.sha1)"]

            } catch {

                $InstalledCerts = $null
            }

            if ($userIndex -ge 0) {
                # $userArrayObject
                # write-host "$($userArrayObject.username) | $($userArrayObject.userId)"
                $currentSystemObject = $userArrayObject.systemAssociations | Select-Object systemId, hostname, osFamily
                $incomingSystemObject = $Global:JCRAssociations[$userArrayObject.userId].systemAssociations
                $incomingList = New-Object System.Collections.ArrayList
                foreach ($system in $Global:JCRAssociations[$userArrayObject.userId].systemAssociations) {
                    $incomingList.Add(
                        [pscustomobject]@{
                            systemId = $system.systemId
                            hostname = $system.hostname
                            osFamily = $system.osFamily
                        }) | Out-Null
                }

                # determine if there's some difference that needs to be recorded:
                try {
                    if ($currentSystemObject -eq $null) {
                        $difference = $incomingList
                        Set-UserTable -index $userIndex -username $MatchedUser.username -localUsername $MatchedUser.systemUsername -systemAssociationsObject ($incomingList) -deploymentObject $InstalledCerts
                    } else {
                        # write-host "test for differences"
                        if ($currentSystemObject -eq $incomingList) {
                            # write-host "nothing to do"
                        } else {
                            # write-host "writing user to do"
                            Set-UserTable -index $userIndex -username $MatchedUser.username -localUsername $MatchedUser.systemUsername -systemAssociationsObject ($incomingList) -deploymentObject $InstalledCerts
                        }
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
        # validate users that should no longer be recorded:
        $userArray = Get-UserJsonData
        foreach ($user in $userArray) {
            # If userID from users.json is no longer in RadiusMembers.keys, then:
            If (($user.userId -notin $Global:JCRRadiusMembers.userID) ) {
                # Get User From Table
                $userObject, $userIndex = Get-UserFromTable -userID $user.userId
                # Remove the User From Table
                $userArray = $userArray | Where-Object { $_.userID -ne $user.userId }
            }
        }
    }
    end {
        # Clear-Host
        Set-UserJsonData -userArray $userArray
    }
}