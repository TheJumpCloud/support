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
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
    }
    Process
    {
        $RadiusServerObject = Switch ($PSCmdlet.ParameterSetName)
        {
            'ReturnAll'
            {
                Get-JCObject -Type:('radiusservers');
            }
            'ById'
            {
                Get-JCObject -Type:('radiusservers') -SearchBy:('ById') -SearchByValue:($RadiusServerId);
            }
            'ByName'
            {
                Get-JCObject -Type:('radiusservers') -SearchBy:('ByName') -SearchByValue:($RadiusServerName);
            }
        }
        If ($RadiusServerObject)
        {
            $Results = $RadiusServerObject
        }
        Else
        {
            Write-Error ('Unable to find radius server. Run Get-JCRadiusServer to get a list of all radius servers.')
        }
    }
    End
    {
        Return $Results
    }
}