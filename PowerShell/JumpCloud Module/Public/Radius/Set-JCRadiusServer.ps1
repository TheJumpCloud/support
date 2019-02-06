Function Set-JCRadiusServer ()
{
    # This endpoint allows you to update RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 0)][switch]$ById,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0)][switch]$ByName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][string]$NewRadiusServerName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, Position = 3)][ValidateNotNullOrEmpty()][string]$NewNetworkSourceIp,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, Position = 4)][ValidateNotNullOrEmpty()][string]$NewSharedSecret
    )
    Begin
    {
        Write-Verbose "Paramter Set: $($PSCmdlet.ParameterSetName)"
        Write-Verbose 'Verifying JCAPI Key'
        If ($JCAPIKEY.length -ne 40) {Connect-JCOnline}
        Write-Verbose 'Populating API headers'
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }
        If ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }
        $Method = 'PUT'
        $Url_Template_RadiusServers = '{0}/api/radiusservers/{1}'
    }
    Process
    {
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                $Uri_RadiusServers = $Url_Template_RadiusServers -f $JCUrlBasePath, $NewNetworkSourceIp
            }
            'ByName'
            {
                $JCRadiusServers = Get-JCRadiusServers -ByName -RadiusServerName:($RadiusServerName)
                $Uri_RadiusServers = $Url_Template_RadiusServers -f $JCUrlBasePath, $JCRadiusServers.results._id
            }
        }
        If ($JCRadiusServers)
        {
            # Build body to be sent to RadiusServers endpoint.
            $BodyObject = New-Object -TypeName PSObject
            If ($NewRadiusServerName) {$BodyObject | Add-Member -MemberType:('NoteProperty') -Name:('name') -Value:($NewRadiusServerName)}
            If ($NewNetworkSourceIp) {$BodyObject | Add-Member -MemberType:('NoteProperty') -Name:('networkSourceIp') -Value:($NewNetworkSourceIp)}
            If ($NewSharedSecret) {$BodyObject | Add-Member -MemberType:('NoteProperty') -Name:('sharedSecret') -Value:($NewSharedSecret)}
            # Convert body to json.
            $JsonBody = $BodyObject | ConvertTo-Json -Depth 10
            # Send body to RadiusServers endpoint.
            Write-Verbose ('Connecting to: ' + $Uri_RadiusServers)
            $Results_RadiusServers = Invoke-RestMethod -Method:($Method) -Uri:($Uri_RadiusServers) -Header:($hdrs) -Body:($JsonBody)
        }
        else
        {
            Write-Error ('Unable to find radius server "' + $RadiusServerName + '". Run Get-JCRadiusServers to get a list of all radius servers.')
        }
    }
    End
    {
        Return $Results_RadiusServers
    }
}