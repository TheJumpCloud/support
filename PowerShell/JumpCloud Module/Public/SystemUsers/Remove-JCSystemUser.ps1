Function Remove-JCSystemUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 0)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Force',
            Position = 0)]

        [String]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByName',
            Position = 1)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Force',
            Position = 1)]

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]

        [string]
        [alias("_id")]
        $SystemID,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ByID')]
        [string]
        $UserID,

        [Parameter(
            ParameterSetName = 'Force')]
        [Switch]
        $force

    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Debug 'Initilizing SystemUpdateArray'
        $SystemUpdateArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'ByName' -or $PSCmdlet.ParameterSetName -eq 'Force')
        {
            Write-Debug $PSCmdlet.ParameterSetName
            Write-Debug 'Populating HostNameHash'
            $HostNameHash = Get-Hash_SystemID_HostName
            Write-Debug 'Populating UserNameHash'
            $UserNameHash = Get-Hash_UserName_ID
        }

        Write-Debug $PSCmdlet.ParameterSetName
    }

    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            if ($HostNameHash.containsKey($SystemID)) {}

            else { Throw "SystemID does not exist. Run 'Get-JCsystem | Select-Object Hostname, _id' to see a list of all your JumpCloud systems and the associated _id."}

            if ($UserNameHash.containsKey($Username)) {}

            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}

            $UserID = $UserNameHash.Get_Item($Username)
            $HostName = $HostNameHash.Get_Item($SystemID)

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

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))
                $Status = 'Removed'

            }
            catch
            {
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

        if ($PSCmdlet.ParameterSetName -eq 'Force')
        {
            $UserID = $UserNameHash.Get_Item($Username)
            $HostName = $HostNameHash.Get_Item($SystemID)

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

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))
                $Status = 'Removed'

            }
            catch
            {
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
        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')
        {
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

            try
            {
                $SystemUpdate = Invoke-RestMethod -Method POST -Uri $URL -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))
                $Status = 'Removed'

            }
            catch
            {
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

    end

    {
        return $SystemUpdateArray
    }

}