Function Remove-JCCommand () #Ready for pester
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(ParameterSetName = 'warn', Mandatory, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'The _id of the JumpCloud Command  you wish to query. To find a JumpCloud CommandID run the command: PS C:\> Get-JCCommand | Select name, _id
The CommandID will be the 24 character string populated for the _id field. CommandID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandID.')]
        [Parameter(ParameterSetName = 'force', Mandatory, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'The _id of the JumpCloud Command  you wish to query. To find a JumpCloud CommandID run the command: PS C:\> Get-JCCommand | Select name, _id
The CommandID will be the 24 character string populated for the _id field. CommandID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandID.')]
        [Alias('_id', 'id')]
        [String] $CommandID,

        [Parameter(ParameterSetName = 'force', HelpMessage = 'A SwitchParameter which removes the warning message when removing a JumpCloud Command.')]
        [Switch]$force
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
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)
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
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)
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