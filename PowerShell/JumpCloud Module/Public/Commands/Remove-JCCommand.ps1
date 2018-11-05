Function Remove-JCCommand () #Ready for pester
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
        [String] $CommandID,

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
        $CommandNameHash = Get-Hash_ID_CommandName

    }
    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn')

        {
            $CommandName = $CommandNameHash.Get_Item($CommandID)
            Write-Warning "Are you sure you want to remove command: $CommandName ?" -WarningAction Inquire

            try
            {

                $URI = "$JCUrlBasePath/api/commands/$CommandID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }


            $FormattedResults = [PSCustomObject]@{
                'Name'      = $CommandName 
                'CommandID' = $CommandID
                'Results'   = $Status
            }

            $deletedArray += $FormattedResults

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            try
            {
                $CommandName = $CommandNameHash.Get_Item($CommandID)

                $URI = "$JCUrlBasePath/api/commands/$CommandID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs
                $Status = 'Deleted'
            }
            catch
            {
                $Status = $_.ErrorDetails
            }


            $FormattedResults = [PSCustomObject]@{
                'Name'      = $CommandName 
                'CommandID' = $CommandID
                'Results'   = $Status
            }


            $deletedArray += $FormattedResults

        }
    }

    end
    {

        return $deletedArray

    }


}