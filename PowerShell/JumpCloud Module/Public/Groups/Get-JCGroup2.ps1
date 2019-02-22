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
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
        $Url_Template_Groups = '{0}/api/v2/groups{1}'
        $SearchQuery_Template = '?filter={0}:eq:{1}'
        $Method = 'GET'
    }
    Process
    {
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ReturnAll' {$SearchQuery = ''}
            'ById' {$SearchQuery = $SearchQuery_Template -f 'id', $GroupId}
            'ByName' {$SearchQuery = $SearchQuery_Template -f 'name', $GroupName}
        }
        $Results_Groups = Invoke-JCApi -Url:($Url_Template_Groups -f $JCUrlBasePath, $SearchQuery) -Method:($Method) -Paginate
    }
    End
    {
        Return $Results_Groups
    }
}