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
        $userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 6
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
        $userArray += $userTable

    }
    end {
        $userArray | ConvertTo-Json -Depth 6 | Set-Content -Path "$JCScriptRoot/users.json"
    }
}
