Function New-JCRadiusServer ()
{
    # This endpoint allows you to create RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][Alias('Ip')][string]$networkSourceIp,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][string]$sharedSecret
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
        $Method = 'POST'
        $Url_Template_RadiusServers = '{0}/api/radiusservers'
        $Uri_RadiusServers = $Url_Template_RadiusServers -f $JCUrlBasePath
    }
    Process
    {
        # Build body to be sent to RadiusServers endpoint.
        $BodyObject = New-Object -TypeName PSObject
        If ($RadiusServerName) {$BodyObject | Add-Member -MemberType:('NoteProperty') -Name:('name') -Value:($RadiusServerName)}
        If ($networkSourceIp) {$BodyObject | Add-Member -MemberType:('NoteProperty') -Name:('networkSourceIp') -Value:($networkSourceIp)}
        If ($sharedSecret) {$BodyObject | Add-Member -MemberType:('NoteProperty') -Name:('sharedSecret') -Value:($sharedSecret)}
        # Convert body to json.
        $JsonBody = $BodyObject | ConvertTo-Json -Depth 10
        # Send body to RadiusServers endpoint.
        Write-Verbose ('Connecting to: ' + $Uri_RadiusServers)
        $Results_RadiusServers = Invoke-RestMethod -Method:($Method) -Uri:($Uri_RadiusServers) -Header:($hdrs) -Body:($JsonBody)
    }
    End
    {
        Return $Results_RadiusServers
    }
}