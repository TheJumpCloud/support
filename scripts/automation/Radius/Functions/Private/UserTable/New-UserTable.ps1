function New-UserTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $id,
        [Parameter()]
        [System.String]
        $username,
        [Parameter()]
        [System.String]
        $localUsername
    )
    begin {
        $userArray = Get-UserJsonData
        If ($userArray.count -eq 1) {
            $array = New-Object System.Collections.ArrayList
            $array.add($userArray) | Out-Null
            $userArray = $array
        }

        $systemAssociations = New-SystemTable -userID $id
        # for new users, just set the commandAssociation to $null as they have
        # not yet been issued a command
        $commandAssociations = $null
        if (-not $localUsername) {
            $localUsername = $username
        }
        $certInfo = Get-CertInfo -UserCerts -username $username
    }
    process {
        $userTable = [PSCustomObject]@{
            userId              = $id
            userName            = $username
            localUsername       = $localUsername
            systemAssociations  = $systemAssociations
            commandAssociations = $commandAssociations
            certInfo            = $certInfo
        }
        $userArray += ($userTable)

    }
    end {
        Set-UserJsonData -userArray $userArray
    }
}
