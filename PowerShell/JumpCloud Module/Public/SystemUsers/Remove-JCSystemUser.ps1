Function Remove-JCSystemUser () {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0,
            HelpMessage = 'The Username of the JumpCloud user you wish to remove from the JumpCloud system.')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Force',
            Position = 0,
            HelpMessage = 'The Username of the JumpCloud user you wish to remove from the JumpCloud system.')]

        [String]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1,
            HelpMessage = 'The _id of the System which you want to bind the JumpCloud user to. To find a JumpCloud SystemID run the command: PS C:\> Get-JCSystem | Select hostname, _id The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID. This is shown in EXAMPLES 3 and 4.')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Force',
            Position = 1,
            HelpMessage = 'The _id of the System which you want to bind the JumpCloud user to. To find a JumpCloud SystemID run the command: PS C:\> Get-JCSystem | Select hostname, _id The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID. This is shown in EXAMPLES 3 and 4.')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID',
            HelpMessage = 'The _id of the System which you want to bind the JumpCloud user to. To find a JumpCloud SystemID run the command: PS C:\> Get-JCSystem | Select hostname, _id The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID. This is shown in EXAMPLES 3 and 4.')]

        [string]
        [alias("_id")]
        $SystemID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID',
            HelpMessage = 'The _id of the User which you want to remove from the JumpCloud system. To find a JumpCloud UserID run the command: PS C:\> Get-JCUser | Select username, _id The UserID will be the 24 character string populated for the _id field. UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud UserID. This is shown in EXAMPLES 3 and 4.')]
        [string]
        $UserID,

        [Parameter(
            ParameterSetName = 'Force',
            HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud user from a JumpCloud system.')]
        [Switch]
        $force

    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JConline
        }

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Debug 'Initilizing SystemUpdateArray'
        $SystemUpdateArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName' -or $PSCmdlet.ParameterSetName -eq 'Force') {
            Write-Debug $PSCmdlet.ParameterSetName
            Write-Debug 'Populating HostNameHash'
            $HostNameHash = Get-DynamicHash -Object System -returnProperties hostname
            Write-Debug 'Populating UserNameHash'
            $UserNameHash = Get-DynamicHash -Object User -returnProperties username
        }

        Write-Debug $PSCmdlet.ParameterSetName
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            if (!$HostNameHash.containsKey($SystemID)) {
                Throw "SystemID does not exist. Run 'Get-JCsystem | Select-Object Hostname, _id' to see a list of all your JumpCloud systems and the associated _id."
            }

            if ($UserNameHash.Values.username -notcontains ($Username)) {
                Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."
            }

            $UserID = $UserNameHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
            $HostName = $HostNameHash.Get_Item($SystemID).hostname

            $body = @{

                op         = "remove"
                type       = "user"
                id         = $UserID
                attributes = $null

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/associations"
            Write-Debug $URL

            Write-Warning "Are you sure you want to remove user: $Username from system: $HostName id: $SystemID ?" -WarningAction Inquire

            try {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $Status = 'Removed'

            } catch {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'System'   = $HostName
                'SystemID' = $SystemID
                'Username' = $Username
                'Status'   = $Status
            }


            $SystemUpdateArray += $FormattedResults

        }

        if ($PSCmdlet.ParameterSetName -eq 'Force') {
            $UserID = $UserNameHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
            $HostName = $HostNameHash.Get_Item($SystemID).hostname

            $body = @{

                op         = "remove"
                type       = "user"
                id         = $UserID
                attributes = $null

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/associations"
            Write-Debug $URL

            try {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $Status = 'Removed'

            } catch {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'System'   = $HostName
                'SystemID' = $SystemID
                'Username' = $Username
                'Status'   = $Status
            }


            $SystemUpdateArray += $FormattedResults

        } elseif ($PSCmdlet.ParameterSetName -eq 'ByID') {
            $body = @{

                op         = "remove"
                type       = "user"
                id         = $UserID
                attributes = $null

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Debug $jsonbody

            $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/associations"
            Write-Debug $URL

            try {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $Status = 'Removed'

            } catch {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'SystemID' = $SystemID
                'UserID'   = $UserID
                'Status'   = $Status
            }

            $SystemUpdateArray += $FormattedResults
        }
    }

    end {
        return $SystemUpdateArray
    }

}