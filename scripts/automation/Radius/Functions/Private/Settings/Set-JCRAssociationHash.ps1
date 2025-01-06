function Set-JCRAssociationHash {
    [CmdletBinding()]
    param (
        [Parameter()]
        [system.string]
        $userId
    )
    begin {
        # get the data
        $associationFile = "$JCScriptRoot/data/associationHash.json"
        $associationContent = Get-Content -Path $associationFile | ConvertFrom-Json -depth 6 -AsHashtable
    }
    process {
        $systemMembership = Get-JcSdkUserTraverseSystem -UserId $userId
        $systemList = New-Object System.Collections.ArrayList
        foreach ($systemMember in $systemMembership) {
            $systemDetails = Get-JCsdksystem -id $systemMember.id -fields 'osFamily hostname'
            $systemList.Add(
                [PSCustomObject]@{
                    systemId = $systemDetails.id
                    osFamily = if ($systemDetails.osFamily -eq "darwin") {
                        "macOS"
                    } elseif ($systemDetails.osFamily -eq "windows") {
                        "windows"
                    }
                    hostname = $systemDetails.hostname
                }
            ) | Out-Null
        }
        $matchedUser = $JCRUsers[$userid]
        # if the userID is not there add it
        if ($userID -notin $associationContent.keys) {
            # add the content)
            $associationContent.add(
                $userId, @{
                    'systemAssociations' = $systemList
                    'userData'           = @($matchedUser | Select-Object -Property email, username)
                }) | Out-Null
        } else {
            $associationContent[$userid].systemAssociations = $systemList
        }
    }
    end {
        # write out the file
        $associationContent | ConvertTo-Json -Depth 6 | Set-Content -Path "$associationFile"
        $Global:JCRAssociations = Get-Content -path "$associationFile" | ConvertFrom-Json -AsHashtable

    }
}