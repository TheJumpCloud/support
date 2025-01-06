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
        $certInfoObject,
        [Parameter()]
        [System.Object]
        $deploymentObject
    )
    begin {
        # Get User Array:
        $userArray = Get-UserJsonData
        if ($PSBoundParameters.ContainsKey('index')) {
            $userIndex = $index
            $userObject = $userArray[$index]
        }
        if (($PSBoundParameters.ContainsKey('lookup'))) {
            # Get User From Table
            $userObject, $userIndex = Get-UserFromTable -userID $id
        }

        # TODO: if index is not correct make a stink about it
        if ($userIndex -lt 0) {
            throw "user not in user table exiting"
        }

        # determine if there's data to update from parameter input, else just
        # use the existing data
        if ($systemAssociationsObject) {
            $systemAssociationsInfo = $systemAssociationsObject
        } else {
            $systemAssociationsInfo = $userObject.systemAssociations
        }
        if ($commandAssociationsObject) {
            $commandAssociationsInfo = $commandAssociationsObject
        } else {
            $commandAssociationsInfo = $userObject.commandAssociations
        }
        if ($certInfoObject) {
            $certInfo = $certInfoObject
        } else {
            $certInfo = $userObject.certInfo
        }
        if ($deploymentObject) {
            $deploymentInfo = $deploymentObject
        } else {
            $deploymentInfo = $null
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
            deploymentInfo      = $deploymentInfo
        }
        # set the user table to new object
        $userArray[$userIndex] = $userTable

    }
    end {
        # update the userTable
        Set-UserJsonData -userArray $userArray
    }
}
