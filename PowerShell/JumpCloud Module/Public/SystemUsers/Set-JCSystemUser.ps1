Function Set-JCSystemUser () {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0,
            HelpMessage = 'The Username of the JumpCloud User whose system permissions will be modified')]
        [String]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID',
            HelpMessage = 'The _id of the JumpCloud User whose system permissions will be modified')]
        [string]
        $UserID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1,
            HelpMessage = 'The _id of the JumpCloud System which you want to modify the permissions on')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID',
            HelpMessage = 'The _id of the JumpCloud System which you want to modify the permissions on')]

        [string]
        [alias("_id")]
        $SystemID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 2,
            HelpMessage = 'A boolean $true/$false value to add or remove Administrator permissions on a target JumpCloud system')]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID',
            HelpMessage = 'A boolean $true/$false value to add or remove Administrator permissions on a target JumpCloud system')]

        [bool]
        $Administrator

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
            Write-Verbose 'Populating UserNameHash'
            $UserNameHash = Get-DynamicHash -Object User -returnProperties username
        }

        Write-Verbose $PSCmdlet.ParameterSetName
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            if (!$HostNameHash.containsKey($SystemID)) {
                Throw "SystemID does not exist. Run 'Get-JCsystem | select Hostname, _id' to see a list of all your JumpCloud systems and the associated _id."
            }

            if ($UserNameHash.Values.username -notcontains ($Username)) {
                Throw "Username does not exist. Run 'Get-JCUser | select username' to see a list of all your JumpCloud users."
            }

            $UserID = $UserNameHash.GetEnumerator().Where({ $_.Value.username -contains ($Username) }).Name
            $HostName = $HostNameHash.Get_Item($SystemID).hostname

            if ($Administrator -eq $true) {

                $body = @{

                    op         = "update"
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

            elseif ($Administrator -eq $false) {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $false
                            withoutPassword = $false

                        }
                    }

                }


            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/associations"

            Write-Verbose $URL


            try {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $Status = 'Updated'

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
            if ($Administrator -eq $true) {

                $body = @{

                    op         = "update"
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

            elseif ($Administrator -eq $false) {

                $body = @{

                    op         = "update"
                    type       = "user"
                    id         = $UserID
                    attributes = @{
                        sudo = @{
                            enabled         = $false
                            withoutPassword = $false

                        }
                    }

                }


            }

            $jsonbody = $body | ConvertTo-Json
            Write-Verbose $jsonbody

            $URL = "$JCUrlBasePath/api/v2/systems/$SystemID/associations"
            Write-Verbose $URL

            try {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $Status = 'Updated'

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