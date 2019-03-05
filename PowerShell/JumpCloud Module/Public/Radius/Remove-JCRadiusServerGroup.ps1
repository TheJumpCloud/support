Function Remove-JCRadiusServerGroup ()
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
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
    }
    Process
    {
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                $RadiusServerObject = Get-JCObject -Type:('radiusservers') -SearchBy:('ById') -SearchByValue:($RadiusServerId);
                $GroupObject = Get-JCObject -Type:('user_group') -SearchBy:('ById') -SearchByValue:($UserGroupId);
            }
            'ByName'
            {
                $RadiusServerObject = Get-JCObject -Type:('radiusservers') -SearchBy:('ByName') -SearchByValue:($RadiusServerName);
                $GroupObject = Get-JCObject -Type:('user_group') -SearchBy:('ByName') -SearchByValue:($UserGroupName);
            }
        }
        $Results = Remove-JCAssociation -InputObjectType:('radiusservers') -InputObjectName:($RadiusServerObject.($RadiusServerObject.ByName)) -TargetObjectType:('user_group') -TargetObjectName:($GroupObject.($GroupObject.ByName))
    }
    End
    {
        Return $Results
    }
}