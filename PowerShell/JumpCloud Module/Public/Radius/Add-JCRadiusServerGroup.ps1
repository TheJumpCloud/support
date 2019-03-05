Function Add-JCRadiusServerGroup ()
{
    # This endpoint allows you to associate Radius Servers to User Groups within your organization.
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
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
        $InputObjectType = 'radiusservers'
        $TargetObjectType = 'user_group'
    }
    Process
    {
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                $RadiusServerObject = Get-JCObject -Type:($InputObjectType) -SearchBy:($PSCmdlet.ParameterSetName) -SearchByValue:($RadiusServerId);
                $GroupObject = Get-JCObject -Type:($TargetObjectType) -SearchBy:($PSCmdlet.ParameterSetName) -SearchByValue:($UserGroupId);
            }
            'ByName'
            {
                $RadiusServerObject = Get-JCObject -Type:($InputObjectType) -SearchBy:($PSCmdlet.ParameterSetName) -SearchByValue:($RadiusServerName);
                $GroupObject = Get-JCObject -Type:($TargetObjectType) -SearchBy:($PSCmdlet.ParameterSetName) -SearchByValue:($UserGroupName);
            }
        }
        $Results = New-JCAssociation -InputObjectType:($InputObjectType) -InputObjectName:($RadiusServerObject.($RadiusServerObject.ByName)) -TargetObjectType:($TargetObjectType) -TargetObjectName:($GroupObject.($GroupObject.ByName))
    }
    End
    {
        Return $Results
    }
}