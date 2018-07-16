function Remove-JCUser ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'warn',
            ValueFromPipelineByPropertyName,
            Position = 0)]

        [Parameter(
            ParameterSetName = 'force',
            ValueFromPipelineByPropertyName,
            Position = 0)]

        [String] $Username,

        [Parameter(
            ParameterSetName = 'warn',
            ValueFromPipelineByPropertyName)]

        [Parameter(
            ParameterSetName = 'force',
            ValueFromPipelineByPropertyName)]

        [Alias('_id')]
        [String] $UserID,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force,

        [Parameter()]
        [Switch]
        $ByID
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

        $deletedArray = @()
            
        if (!$ByID)

        {
            $UserHash = Get-Hash_UserName_ID
            $UserCount = ($UserHash).Count
            Write-Debug "Populated UserHash with $UserCount users"
        }

    }
    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn' -and !$ByID)
        {
            if ($UserHash.ContainsKey($Username))
            {
                $UserID = $UserHash.Get_Item($Username)

                try
                {
                    $URI = "https://console.jumpcloud.com/api/systemusers/$UserID"
                    Write-Warning "Are you sure you wish to delete user: $Username ?" -WarningAction Inquire
                    $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.5.0'
                    $Status = 'Deleted'
                }
                catch
                {
                    $Status = $_.ErrorDetails
                }

                $FormattedResults = [PSCustomObject]@{
                    'Username' = $Username 
                    'Results'  = $Status
                }

                $deletedArray += $FormattedResults
            }
            else { Throw "Username does not exist. Run 'Get-JCUser | Select-Object username' to see a list of all your JumpCloud users."}
        }

        if ($PSCmdlet.ParameterSetName -eq 'force' -and !$ByID)
        {
            $UserID = $UserHash.Get_Item($Username)

            try
            {
                $URI = "https://console.jumpcloud.com/api/systemusers/$UserID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.5.0'
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{
                'Username' = $Username 
                'Results'  = $Status
            }

            $deletedArray += $FormattedResults

        }
            
            
            
        if ($PSCmdlet.ParameterSetName -eq 'warn' -and $ByID)

        {
            try
            {
                $URI = "https://console.jumpcloud.com/api/systemusers/$UserID"
                Write-Warning "Are you sure you wish to delete user: $Username ?" -WarningAction Inquire
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.5.0'
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{
                'UserID'  = $UserID
                'Results' = $Status
            }


        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force' -and $ByID)
        {

            try
            {
                $URI = "https://console.jumpcloud.com/api/systemusers/$UserID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.5.0'
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }

            $FormattedResults = [PSCustomObject]@{
                'UserID'  = $UserID 
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