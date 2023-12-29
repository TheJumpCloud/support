function Set-UserTable {
    [CmdletBinding(DefaultParameterSetName = 'lookup')]
    param (
        [Parameter(mandatory, ParameterSetName = 'index')]
        [System.String]
        $index,
        [Parameter(mandatory, ParameterSetName = 'lookup')]
        [System.String]
        $id,
        [Parameter()]
        [System.String]
        $username,
        [Parameter()]
        [System.String]
        $localUsername,
        [Parameter()]
        [System.Object]
        $systemAssociationsObject,
        [Parameter()]
        [System.Object]
        $commandAssociationsObject,
        [Parameter()]
        [System.Object]
        $certInfoObject
    )
    begin {
        # Get User Array:
        $userArray = Get-Content -Raw -Path "$JCScriptRoot/users.json" | ConvertFrom-Json -Depth 6
        if ($PSBoundParameters.ContainsKey('index')) {
            $userIndex = $index
            $userObject = $userArray[$index]
            Write-Warning "this is the old object"
            $userObject
        }
        if (($PSBoundParameters.ContainsKey('lookup'))) {
            # Get User From Table
            $userObject, $userIndex = Get-UserFromTable -jsonFilePath "$JCScriptRoot/users.json" -userID $id
        }

        # determine if there's data to update from parameter input, else just
        # use the existing data
        if ($systemAssociationsObject) {
            $systemAssociationsInfo = $systemAssociationsObject
        } else {
            $systemAssociationsInfo = $userObject.systemAssociations
        }
        if ($commandAssociationsObject) {
            commandAssociationsInfo = $commandAssociationsObject
        } else {
            $commandAssociationsInfo = $userObject.commandAssociations
        }
        if ($certInfoObject) {
            $certInfo = $certInfoObject
        } else {
            $certInfo = $userObject.certInfo
        }
    }
    process {
        # build the userTable object
        $userTable = [PSCustomObject]@{
            userId              = $userObject.userId
            userName            = $userObject.username
            localUsername       = $userObject.localUsername
            systemAssociations  = $systemAssociationsInfo
            commandAssociations = $commandAssociationsInfo
            certInfo            = $certInfo
        }
        Write-Warning "this is the new object"
        $userTable

        # set the user table to new object
        $userArray[$userIndex] = $userTable

    }
    end {
        # update the userTable
        $userArray | ConvertTo-Json -Depth 6 | Set-Content -Path "$JCScriptRoot/users.json"
    }
}
