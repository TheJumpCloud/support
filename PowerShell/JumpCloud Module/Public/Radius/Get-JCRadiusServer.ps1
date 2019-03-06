Function Get-JCRadiusServer ()
{
    # This endpoint allows you to get a list of all Radius Servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 0)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName
    )
    Begin
    {
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
    }
    Process
    {
        $Results = Switch ($PSCmdlet.ParameterSetName)
        {
            'ReturnAll'
            {
                Invoke-JCRadiusServer -Action:('GET');
            }
            'ById'
            {
                Invoke-JCRadiusServer -Action:('GET') -RadiusServerId:($RadiusServerId)
            }
            'ByName'
            {
                Invoke-JCRadiusServer -Action:('GET') -RadiusServerName:($RadiusServerName)
            }
        }
    }
    End
    {
        Return $Results
    }
}