Function Remove-JCRadiusServer ()
{
    # This endpoint allows you to update RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 0)][switch]$ById,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0)][switch]$ByName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(ParameterSetName = 'force')][Switch]$force
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
        $Method = 'DELETE'
        $Url_Template_RadiusServers = '{0}/api/radiusservers'
    }
    Process
    {
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                $Uri_RadiusServers = $Url_Template_RadiusServers -f $JCUrlBasePath
                $JCRadiusServers = Get-JCRadiusServer -ById -RadiusServerId:($RadiusServerId)
            }
            'ByName'
            {
                $Uri_RadiusServers = $Url_Template_RadiusServers -f $JCUrlBasePath
                $JCRadiusServers = Get-JCRadiusServer -ByName -RadiusServerName:($RadiusServerName)
            }
        }
        If ($JCRadiusServers)
        {
            # Build body to be sent to RadiusServers endpoint.
            $JsonBody = '{"isSelectAll":false,"models":[{"_id":"' + $JCRadiusServers._id + '"}]}'
            # Send body to RadiusServers endpoint.
            Write-Verbose ('Connecting to: ' + $Uri_RadiusServers)
            Write-Verbose ('Sending JsonBody: ' + $JsonBody)
            If ($force) {Write-Warning "Are you sure you wish to delete object: $result ?" -WarningAction Inquire}
            $Results_RadiusServers = Invoke-RestMethod -Method:($Method) -Uri:($Uri_RadiusServers) -Header:($hdrs) -Body:($JsonBody)
        }
        Else
        {
            Write-Error ('Unable to find radius server "' + $RadiusServerName + '". Run Get-JCRadiusServers to get a list of all radius servers.')
        }
    }
    End
    {
        Return $Results_RadiusServers
    }
}