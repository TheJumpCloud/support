Function Remove-JCSystem ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(ParameterSetName = 'warn', Mandatory, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'The _id of the System which you want to remove from JumpCloud. To find a JumpCloud SystemID run the command: PS C:\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID. This is shown in EXAMPLES 3 and 4.')]
        [Parameter(ParameterSetName = 'force', Mandatory, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'The _id of the System which you want to remove from JumpCloud. To find a JumpCloud SystemID run the command: PS C:\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field. SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID. This is shown in EXAMPLES 3 and 4.')]
        [Alias('_id', 'id')]
        [String] $SystemID,

        [Parameter(ParameterSetName = 'force', HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud System.')]
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

                $URI = "$JCUrlBasePath/api/systems/$SystemID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)
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

                $URI = "$JCUrlBasePath/api/systems/$SystemID"
                $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)
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