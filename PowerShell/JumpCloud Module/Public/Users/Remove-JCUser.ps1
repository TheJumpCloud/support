function Remove-JCUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'Username')]

    param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'Username',
            ValueFromPipelineByPropertyName,
            Position = 0)]
        [String] $Username,

        [Parameter(Mandatory,
            ParameterSetName = 'UserID',
            ValueFromPipelineByPropertyName)]

        [Alias('_id')]
        [String] $UserID,

        [Parameter(ParameterSetName = 'UserID')]
        [Switch]
        $ByID,

        [Parameter()]
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

        $deletedArray = @()

        if ($PSCmdlet.ParameterSetName -eq 'Username' )
        {
            $UserHash = Get-Hash_UserName_ID
            $UserCount = ($UserHash).Count
            Write-Debug "Populated UserHash with $UserCount users"
        }

    }
    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'Username' )
        {
            if ($UserHash.ContainsKey($Username))
            {
                $UserID = $UserHash.Get_Item($Username)
            }
            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}
        }

        if ($PSCmdlet.ParameterSetName -eq 'UserID' )
        {
            $Username = $UserID
        }

        if (!$force)
        {
            try
            {
                $URI = "$JCUrlBasePath/api/systemusers/$UserID"
                Write-Warning "Are you sure you wish to delete user: $Username ?" -WarningAction Inquire
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{
                'User'    = $Username
                'Results' = $Status
            }

            $deletedArray += $FormattedResults

        }

        if ($force)
        {
            try
            {
                $URI = "$JCUrlBasePath/api/systemusers/$UserID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{
                'User'    = $Username
                'Results' = $Status
            }

            $deletedArray += $FormattedResults

        }


    }

    end
    {

        return $deletedArray

    }

}