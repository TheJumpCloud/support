Function Set-JCRadiusServer ()
{
    # This endpoint allows you to update RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 0)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][string]$NewRadiusServerName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][string]$NewNetworkSourceIp,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, Position = 3)][ValidateNotNullOrEmpty()][ValidateLength(1, 31)][string]$NewSharedSecret
    )
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
        $Method = 'PUT'
        $Url_Template_RadiusServers = '/api/radiusservers/{0}'
    }
    Process
    {
        $RadiusServerObject = Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                Get-JCObject -Type:('radiusservers') -SearchBy:('ById') -SearchByValue:($RadiusServerId);
            }
            'ByName'
            {
                Get-JCObject -Type:('radiusservers') -SearchBy:('ByName') -SearchByValue:($RadiusServerName);
            }
        }
        If ($RadiusServerObject)
        {
            # Build Url
            $Uri_RadiusServers = $Url_Template_RadiusServers -f $RadiusServerObject.($RadiusServerObject.ById)
            # Build Json body
            If (!($NewRadiusServerName)) {$NewRadiusServerName = $RadiusServerObject.($RadiusServerObject.ByName)}
            If (!($NewNetworkSourceIp)) {$NewNetworkSourceIp = $RadiusServerObject.networkSourceIp}
            If (!($NewSharedSecret)) {$NewSharedSecret = $RadiusServerObject.sharedSecret}
            $JsonBody = '{"name":"' + $NewRadiusServerName + '","networkSourceIp":"' + $NewNetworkSourceIp + '","sharedSecret":"' + $NewSharedSecret + '"}'
            # Send body to RadiusServers endpoint.
            $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
        }
        Else
        {
            Write-Error ('Unable to find radius server "' + $RadiusServerName + '". Run Get-JCRadiusServer to get a list of all radius servers.')
        }
    }
    End
    {
        Return $Results
    }
}