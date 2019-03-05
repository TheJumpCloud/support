Function Get-JCRadiusServerGroup ()
{
    # This endpoint allows you to get a list of all RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 0)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName
    )
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
    }
    Process
    {
        $Results = Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                Invoke-JCRadiusServerGroup -Action:('GET') -RadiusServerId:($RadiusServerId)
            }
            'ByName'
            {
                Invoke-JCRadiusServerGroup -Action:('GET') -RadiusServerName:($RadiusServerName)
            }
        }
    }
    End
    {
        Return $Results
    }
}