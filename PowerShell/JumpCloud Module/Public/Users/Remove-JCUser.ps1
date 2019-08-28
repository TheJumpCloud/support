function Remove-JCUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'Username')]

    param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'Username',
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'The Username of the JumpCloud user you wish to remove.')]
        [String] $Username,

        [Parameter(Mandatory,
            ParameterSetName = 'UserID',
            ValueFromPipelineByPropertyName,
            HelpMessage = 'The _id of the User which you want to delete.
To find a JumpCloud UserID run the command:
PS C:\> Get-JCUser | Select username, _id
The UserID will be the 24 character string populated for the _id field.
UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically.')]

        [Alias('_id')]
        [String] $UserID,

        [Parameter(ParameterSetName = 'UserID',
            HelpMessage = 'Use the -ByID parameter when the UserID is passed over the pipeline to the Remove-JCUser function. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which will increase the function speed and performance.')]
        [Switch]
        $ByID,

        [Parameter(HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud User.')]
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
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)
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
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)
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