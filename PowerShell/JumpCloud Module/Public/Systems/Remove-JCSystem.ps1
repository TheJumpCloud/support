Function Remove-JCSystem ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(
            ParameterSetName = 'warn',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]

        [Parameter(
            ParameterSetName = 'force',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]
        [Alias('_id', 'id')]
        [String] $SystemID,

        [Parameter(
            ParameterSetName = 'force')]
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
        $HostNameHash = Get-Hash_SystemID_HostName

    }
    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn')

        {
            $Hostname = $HostnameHash.Get_Item($SystemID)
            Write-Warning "Are you sure you wish to delete system: $Hostname ?" -WarningAction Inquire

            try
            {

                $URI = "https://console.jumpcloud.com/api/systems/$SystemID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.7.0'
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }


            $FormattedResults = [PSCustomObject]@{
                'HostName' = $Hostname
                'SystemID' = $SystemID
                'Results'  = $Status
            }

            $deletedArray += $FormattedResults

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            try
            {

                $URI = "https://console.jumpcloud.com/api/systems/$SystemID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.7.0'
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }


            $FormattedResults = [PSCustomObject]@{
                'HostName' = $Hostname
                'SystemID' = $SystemID
                'Results'  = $Status
            }

            $deletedArray += $FormattedResults

        }
    }

    end
    {

        return $deletedArray

    }


}