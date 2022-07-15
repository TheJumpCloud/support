Function Add-JCSystemUser () {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0, HelpMessage = 'The Username of the JumpCloud user you wish to add to the JumpCloud system.')]
        [String]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID', HelpMessage = 'The _id of the User which you want to add to the JumpCloud system.
To find a JumpCloud UserID run the command:
PS C:\> Get-JCUser | Select username, _id
The UserID will be the 24 character string populated for the _id field.
UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud UserID. This is shown in EXAMPLES 2, 3, and 4.
')]
        [string]
        $UserID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1, HelpMessage = 'The _id of the System which you want to bind the JumpCloud user to.
To find a JumpCloud SystemID run the command:
PS C:\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field.
SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID.')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID', HelpMessage = 'The _id of the System which you want to bind the JumpCloud user to.
To find a JumpCloud SystemID run the command:
PS C:\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field.
SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID.')]

        [string]
        [alias("_id")]
        $SystemID,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 2, HelpMessage = 'A boolean $true/$false value to set Administrator permissions on the target JumpCloud system')]

        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID', HelpMessage = 'A boolean $true/$false value to set Administrator permissions on the target JumpCloud system')]
        [bool]
        $Administrator = $false

    )

    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JConline
        }

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Verbose 'Initilizing SystemUpdateArray'
        $SystemUpdateArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            Write-Verbose $PSCmdlet.ParameterSetName

            Write-Verbose 'Populating HostNameHash'
            $HostNameHash = Get-DynamicHash -Object System -returnProperties hostname
        }

        Write-Verbose 'Populating UserHash'
        $UserHash = Get-DynamicHash -Object User -returnProperties sudo, username

        Write-Verbose $PSCmdlet.ParameterSetName
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            if (!$HostNameHash.containsKey($SystemID)) {
                Throw "SystemID does not exist. Run 'Get-JCsystem | select Hostname, _id' to see a list of all your JumpCloud systems and the associated _id."
            }

            if ($UserHash.Values.username -notcontains ($Username)) {
                Throw "Username does not exist. Run 'Get-JCUser | select username' to see a list of all your JumpCloud users."
            }

            $UserID = $UserHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name

            $HostName = $HostNameHash.Get_Item($SystemID).hostname

            $GlobalAdmin = $UserHash.Get_Item($UserID).sudo

            if ($GlobalAdmin -eq $true) {
                $Administrator = $true
            }

            if ($Administrator -eq $true) {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $true
                            withoutPassword = $false

                        }
                    }
                }

            }

            else {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = $null

                }

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/associations"
            Write-Verbose $URL


            try {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $Status = 'Added'

            } catch {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'System'        = $HostName
                'SystemID'      = $SystemID
                'Username'      = $Username
                'Status'        = $Status
                'Administrator' = $Administrator
            }


            $SystemUpdateArray += $FormattedResults

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID') {

            $GlobalAdmin = $UserHash.Get_Item($UserID).sudo

            if ($GlobalAdmin -eq $true) {
                $Administrator = $true
            }

            if ($Administrator -eq $true) {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $true
                            withoutPassword = $false

                        }
                    }
                }

            }

            else {

                $body = @{

                    op         = "add"
                    type       = "user"
                    id         = $UserID
                    attributes = $null

                }

            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/associations"
            Write-Verbose $URL

            try {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $Status = 'Added'

            } catch {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{

                'SystemID'      = $SystemID
                'UserID'        = $UserID
                'Status'        = $Status
                'Administrator' = $Administrator
            }

            $SystemUpdateArray += $FormattedResults
        }
    }

    end {
        return $SystemUpdateArray
    }

}