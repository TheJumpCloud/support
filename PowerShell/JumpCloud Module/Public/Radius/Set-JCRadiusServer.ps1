Function Set-JCRadiusServer ()
{
    # This endpoint allows you to update Radius Servers in your organization.
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
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
        $Method = 'PUT'
        $Url_Template_RadiusServers = '/api/radiusservers/{0}'
    }
    Process
    {
        $Results = Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                Invoke-JCRadiusServer -Action:('PUT') -RadiusServerId:($RadiusServerId) -NewRadiusServerId:($NewRadiusServerId) -NewNetworkSourceIp:($NewNetworkSourceIp) -NewSharedSecret:($NewSharedSecret);
            }
            'ByName'
            {
                Invoke-JCRadiusServer -Action:('PUT') -RadiusServerName:($RadiusServerName) -NewRadiusServerName:($NewRadiusServerName) -NewNetworkSourceIp:($NewNetworkSourceIp) -NewSharedSecret:($NewSharedSecret);
            }
        }
    }
    End
    {
        Return $Results
    }
}