Function Add-JCRadiusServerGroup ()
{
    # This endpoint allows you to associate Radius Servers to User Groups within your organization.
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 0)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][string]$UserGroupId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][string]$UserGroupName
    )
    Begin
    {
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
    }
    Process
    {
        $Results = Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                Invoke-JCRadiusServerGroup -Action:('NEW') -RadiusServerId:($RadiusServerId) -UserGroupId:($UserGroupId);
            }
            'ByName'
            {
                Invoke-JCRadiusServerGroup -Action:('NEW') -RadiusServerName:($RadiusServerName) -UserGroupName:($UserGroupName);
            }
        }
    }
    End
    {
        Return $Results
    }
}