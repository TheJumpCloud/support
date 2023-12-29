function Update-JCRGlobalVars {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $force
    )
    begin {
        # ensure the data directory exists to cache the json files:
        if (Test-Path "$JCScriptRoot/data") {
            Write-Host "[status] Data Directory Exists"
        } else {
            Write-Host "[status] Creating Data Directory"
            New-Item -ItemType Directory -Path "$JCScriptRoot/data"
        }

        # get settings file
        $lastUpdateTimespan = New-TimeSpan -Start $global:JCRConfig.globalvars.lastupdate -end (Get-Date)
        if ($lastUpdateTimespan.TotalHours -gt 24) {
            $update = $true
        } else {
            $update = $false
        }
        if ($force) {
            $update = $true
        }
    }
    process {
        switch ($update) {
            $true {
                # update the global variables
                $systems = Get-DynamicHash -Object System -returnProperties hostname, os, osFamily, version, fde, lastContact
                $users = Get-DynamicHash -Object User -returnProperties email, employeeIdentifier, department, suspended, location, Addresses, manager, sudo, Displayname, username, systemUsername
                $users | ForEach-Object { $_ | Add-Member -name "userId" -value $_ -Type NoteProperty -force }
                # Get Radius membership list:
                $radiusMembers = Get-JcSdkUserGroupMember -GroupId $Global:JCUSERGROUP
                # Get Report Hash:
                $headers = @{
                    "accept"    = "application/json";
                    "x-api-key" = $Env:JCApiKey;
                    "x-org-id"  = $Env:JCOrgId
                }
                # request new user to device report:
                $reportRequest = Invoke-RestMethod -Uri 'https://api.jumpcloud.com/insights/directory/v1/reports/users-to-devices' -Method POST -Headers $headers
                # now fetch available reports:
                do {
                    $reportList = Invoke-RestMethod -Uri 'https://api.jumpcloud.com/insights/directory/v1/reports?sort=CREATED_AT' -Method GET -Headers $headers
                    $lastReport = $reportList | Where-Object { $_.id -eq $reportRequest.id }
                    if ($lastReport.status -eq 'PENDING') {
                        Write-Warning "[status] waiting 20s for jumpcloud report to complete"
                        start-sleep -Seconds 20
                    }
                } until ($lastReport.status -eq 'COMPLETED')
                # download json
                $artifactID = ($lastReport.artifacts | Where-Object { $_.format -eq 'json' }).id
                $reportID = $lastReport.id
                $reportContent = Invoke-RestMethod -Uri "https://api.jumpcloud.com/insights/directory/v1/reports/$reportID/artifacts/$artifactID/content" -Method GET -Headers $headers
                # create the hashtable:
                $userAssociationList = New-Object System.Collections.Hashtable
                foreach ($item in $reportContent) {
                    if ($item.user_object_id -And $item.resource_object_id) {
                        if (-not $userAssociationList[$item.user_object_id]) {
                            $userAssociationList.add(
                                $item.user_object_id, @{
                                    'systemAssociations' = @($item | Select-Object -Property @{Name = 'systemId'; Expression = { $_.resource_object_id } }, hostname, device_os);
                                    'userData'           = @($item | Select-Object -Property email, username)
                                })
                        } else {
                            $userAssociationList[$item.user_object_id].systemAssociations += @($item | Select-Object -Property @{Name = 'systemId'; Expression = { $_.resource_object_id } }, hostname, device_os)
                        }
                    }
                }
            }
            $false {
                Write-Warning "It's been $($lastUpdateTimespan.hours) hours since we last pulled user, system and association data, no need to update"
                $userAssociationList = Get-Content -Raw -Path "$JCScriptRoot/data/associationHash.json" | ConvertFrom-Json -Depth 6 -AsHashtable
            }
        }

        # # validate that the system association data is correct in users.json:
        $userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 6
        foreach ($userid in $Global:JCRRadiusMembers.keys) {
            $MatchedUser = $GLOBAL:JCRUsers[$userid]
            Write-Host "checking out $($MatchedUser.username) userid: $userid"
            $userArrayObject, $userIndex = Get-UserFromTable -userID $userid -jsonFilePath "$JCScriptRoot/users.json"

            if ($userIndex -ge 0) {
                # $userArrayObject
                $currentSystemObject = $userArrayObject.systemAssociations
                $incomingSystemObject = $userAssociationList[$userid].systemAssociations
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
                # if ($difference) {
                #     # if there's a difference in systemIDS, update table with the incomingSystemObject
                #     # $userTable = New-UserTable -id $userid -username $MatchedUser.username -localUsername $matchedUser.systemUsername
                #     # Update-JsonData -jsonFilePath "$JCScriptRoot/users.json" -userID $userID -updatedUserTable $userTable
                # }
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
        $userArray | ConvertTo-Json -Depth 6 | Set-Content -Path "$JCScriptRoot/users.json"
    }
    end {
        switch ($update) {
            $true {
                # write hash cache
                $users | ConvertTo-Json -Depth 10 |  Out-File "$JCScriptRoot/data/userHash.json"
                $systems | ConvertTo-Json -Depth 10 |  Out-File "$JCScriptRoot/data/systemHash.json"
                $userAssociationList | ConvertTo-Json -Depth 10 |  Out-File "$JCScriptRoot/data/associationHash.json"
                # add the username to the membership hash
                $radiusMemberList = New-Object System.Collections.Hashtable
                foreach ($member in $radiusMembers) {
                    $radiusMemberList.Add(
                        $member.toID, @{
                            'userID'   = $member.toID
                            'username' = $users[$member.toID].username
                        })
                }
                # $radiusMemberList = ($radiusMembers | select @{name = 'userID'; expression = { $_.toID } }, @{name = 'username'; expression = { $users[$_.toID].username } })
                $radiusMemberList | ConvertTo-Json |  Out-File "$JCScriptRoot/data/radiusMembers.json"
                # set global vars
                $Global:JCRUsers = $users
                $Global:JCRSystems = $systems
                $Global:JCRAssociations = $userAssociationList
                $Global:JCRRadiusMembers = $radiusMemberList
                # update the settings date
                Set-JCRSettingsFile -globalVarslastUpdate (Get-Date)
            }
            $false {
                Write-Warning "pulling saved data from data file:"
                # set global vars from local cache
                $Global:JCRUsers = Get-Content -path "$JCScriptRoot/data/userHash.json" | ConvertFrom-Json -AsHashtable
                $Global:JCRSystems = Get-Content -path "$JCScriptRoot/data/systemHash.json" | ConvertFrom-Json -AsHashtable
                $Global:JCRAssociations = Get-Content -path "$JCScriptRoot/data/associationHash.json" | ConvertFrom-Json -AsHashtable
                $Global:JCRRadiusMembers = Get-Content -path "$JCScriptRoot/data/radiusMembers.json" | ConvertFrom-Json -AsHashtable
            }
        }
    }
}