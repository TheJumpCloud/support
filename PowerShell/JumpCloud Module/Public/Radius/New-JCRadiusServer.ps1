Function New-JCRadiusServer ()
{
    # This endpoint allows you to create new Radius Servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][Alias('Ip')][string]$networkSourceIp,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][ValidateLength(1, 31)][string]$sharedSecret
    )
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
        $Method = 'POST'
        $Uri_RadiusServers = '/api/radiusservers'
    }
    Process
    {
        # Build body to be sent to RadiusServers endpoint.
        $JsonBody = '{"name":"' + $RadiusServerName + '","networkSourceIp":"' + $networkSourceIp + '","sharedSecret":"' + $sharedSecret + '"}'
        # Send body to RadiusServers endpoint.
        $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
    }
    End
    {
        Return $Results
    }
}