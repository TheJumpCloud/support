Function Get-JCGroup2 ()
{
    # This endpoint allows you to get a list of all RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 0)][switch]$ById,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$GroupId,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0)][switch]$ByName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][Alias('Name')][string]$GroupName
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
        $Url_Template_Groups = '{0}/api/v2/groups{1}'
        $SearchQuery_Template = '?filter={0}:eq:{1}'
    }
    Process
    {
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ReturnAll' {$SearchQuery = ''}
            'ById' {$SearchQuery = $SearchQuery_Template -f 'id', $GroupId}
            'ByName' {$SearchQuery = $SearchQuery_Template -f 'name', $GroupName}
        }
        # Get Group endpoint.
        $Uri_Groups = $Url_Template_Groups -f $JCUrlBasePath, $SearchQuery
        Write-Verbose ('Connecting to: ' + $Uri_Groups)
        $Results_Groups = Invoke-JCApiGet -Url:($Uri_Groups)
    }
    End
    {
        Return $Results_Groups
    }
}