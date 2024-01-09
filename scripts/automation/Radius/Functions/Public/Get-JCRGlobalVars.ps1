function Get-JCRGlobalVars {
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

        # also validate that the data files are non-null, if they are, force update]
        $requiredHashFiles = @('associationHash.json', 'radiusMembers.json', 'systemHash.json', 'userHash.json')
        foreach ($file in $requiredHashFiles) {
            if (Test-Path -Path "$JCScriptRoot/data/$file") {
                $fileContents = Get-Content "$JCScriptRoot/data/$file"
            } else {
                Write-Host "[status] $JCScriptRoot/data/$file file does not exist, updating global variables"
                $update = $true
                break
            }
            # if the file is null force update
            if ([string]::IsNullOrEmpty($file)) {
                Write-Host "[status] $JCScriptRoot/data/$file file is null, updating global variables"
                $update = $true
                break
            }
        }
    }
    process {
        switch ($update) {
            $true {
                # update the global variables
                $systems = Get-DynamicHash -Object System -returnProperties hostname, os, osFamily, version, fde, lastContact
                $users = Get-DynamicHash -Object User -returnProperties email, employeeIdentifier, department, suspended, location, Addresses, manager, sudo, Displayname, username, systemUsername
                # $users | ForEach-Object { $_ | Add-Member -name "userId" -value $_ -Type NoteProperty -force }
                # Get Radius membership list:
                $radiusMembers = Get-JcSdkUserGroupMember -GroupId $Global:JCUSERGROUP
                # add the username to the membership hash
                $radiusMemberList = New-Object System.Collections.ArrayList
                foreach ($member in $radiusMembers) {
                    $radiusMemberList.Add(
                        [PSCustomObject]@{
                            'userID'   = $member.toID
                            'username' = $users[$member.toID].username
                        }
                    )
                }
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
                                    'systemAssociations' = @($item | Select-Object -Property @{Name = 'systemId'; Expression = { $_.resource_object_id } }, hostname, @{Name = 'osFamily'; Expression = { $_.device_os } });
                                    'userData'           = @($item | Select-Object -Property email, username)
                                })
                        } else {
                            $userAssociationList[$item.user_object_id].systemAssociations += @($item | Select-Object -Property @{Name = 'systemId'; Expression = { $_.resource_object_id } }, hostname, @{Name = 'osFamily'; Expression = { $_.device_os } })
                        }
                    }
                }

                # finally write out the data to file:
                Write-host "writing files"
                $users | ConvertTo-Json -Depth 100 -Compress |  Out-File "$JCScriptRoot/data/userHash.json"
                $systems | ConvertTo-Json -Depth 10 |  Out-File "$JCScriptRoot/data/systemHash.json"
                $userAssociationList | ConvertTo-Json -Depth 10 |  Out-File "$JCScriptRoot/data/associationHash.json"
                $radiusMemberList | ConvertTo-Json |  Out-File "$JCScriptRoot/data/radiusMembers.json"
            }
            $false {
                Write-Warning "It's been $($lastUpdateTimespan.hours) hours since we last pulled user, system and association data, no need to update"
                $userAssociationList = Get-Content -Raw -Path "$JCScriptRoot/data/associationHash.json" | ConvertFrom-Json -Depth 6 -AsHashtable
            }
        }
    }
    end {
        switch ($update) {
            $true {

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