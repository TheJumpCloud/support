Function Get-JCRadiusServer ()
{
    # This endpoint allows you to get a list of all RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 0)][switch]$ById,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0)][switch]$ByName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ByIp', Position = 0)][switch]$ByIp,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ByIp', Position = 1)][ValidateNotNullOrEmpty()][Alias('Ip')][string]$RadiusServerIp
    )
    Begin
    {
        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"
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
        $Url_Template_RadiusServers = '{0}/api/radiusservers{1}'
        $SearchQuery_Template = '?filter={0}:eq:{1}'
    }
    Process
    {
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ReturnAll' {$SearchQuery = ''}
            'ById' {$SearchQuery = $SearchQuery_Template -f '_id', $RadiusServerId}
            'ByName' {$SearchQuery = $SearchQuery_Template -f 'name', $RadiusServerName}
            'ByIp' {$SearchQuery = $SearchQuery_Template -f 'networkSourceIp', $RadiusServerIp}
        }
        # Get RadiusServer endpoint.
        $Uri_RadiusServers = $Url_Template_RadiusServers -f $JCUrlBasePath, $SearchQuery
        Write-Verbose ('Connecting to: ' + $Uri_RadiusServers)
        $Results_RadiusServers = Invoke-JCApiGet -Url:($Uri_RadiusServers)
    }
    End
    {
        Return $Results_RadiusServers.results
    }
}