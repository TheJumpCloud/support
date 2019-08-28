Function Remove-JCRadiusServer ()
{
    # This endpoint allows you to delete a Radius Server in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 0)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][bool]$force = $false
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
                Invoke-JCRadiusServer -Action:('DELETE') -RadiusServerId:($RadiusServerId) -force:($force)
            }
            'ByName'
            {
                Invoke-JCRadiusServer -Action:('DELETE') -RadiusServerName:($RadiusServerName) -force:($force)
            }
        }
    }
    End
    {
        Return $Results
    }
}