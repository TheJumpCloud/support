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
        $Method = 'PUT'
        $Url_Template_RadiusServers = '/api/radiusservers/{0}'
    }
    Process
    {
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                $JCRadiusServers = Get-JCRadiusServer -RadiusServerId:($RadiusServerId)
                $Uri_RadiusServers = $Url_Template_RadiusServers -f $JCRadiusServers._id
            }
            'ByName'
            {
                $JCRadiusServers = Get-JCRadiusServer -RadiusServerName:($RadiusServerName)
                $Uri_RadiusServers = $Url_Template_RadiusServers -f $JCRadiusServers._id
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
            $Results = Invoke-JCApi -Method:($Method) -Url:($Uri_RadiusServers) -Body:($JsonBody)
        }
        else
        {
            Write-Error ('Unable to find radius server "' + $RadiusServerName + '". Run Get-JCRadiusServers to get a list of all radius servers.')
        }
    }
    End
    {
        Return $Results
    }
}