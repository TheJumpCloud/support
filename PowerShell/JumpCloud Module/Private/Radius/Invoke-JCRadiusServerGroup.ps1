Function Invoke-JCRadiusServerGroup ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('GET', 'NEW', 'REMOVE')][string]$Action
    )
    DynamicParam
    {
        # Create the parameter dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # Define the new parameters
        New-DynamicParameter -ParameterName:('RadiusServerId') -ParameterType:('string') -Position:(1) -Mandatory:($true) -ValueFromPipelineByPropertyName:($true) -ParameterSetName:('ById') -ValidateNotNullOrEmpty:($true) -Alias:(@('_id', 'id')) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
        New-DynamicParameter -ParameterName:('RadiusServerName') -ParameterType:('string') -Position:(1) -Mandatory:($true) -ValueFromPipelineByPropertyName:($true) -ParameterSetName:('ByName') -ValidateNotNullOrEmpty:($true) -Alias:(@('Name')) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
        If ($Action -eq 'GET')
        {
        }
        ElseIf ($Action -in ('NEW', 'REMOVE'))
        {
            New-DynamicParameter -ParameterName:('UserGroupId') -ParameterType:('string') -Position:(2) -Mandatory:($true) -ValueFromPipelineByPropertyName:($true) -ParameterSetName:('ById') -ValidateNotNullOrEmpty:($true) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
            New-DynamicParameter -ParameterName:('UserGroupName') -ParameterType:('string') -Position:(2) -Mandatory:($true) -ValueFromPipelineByPropertyName:($true) -ParameterSetName:('ByName') -ValidateNotNullOrEmpty:($true) -RuntimeDefinedParameterDictionary:($RuntimeParameterDictionary)
        }
        # Return functions parameters
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Show all parameters
        # $PsBoundParameters.GetEnumerator()
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
        # Bind the parameter to a friendly variable
        $RadiusServerId = $PsBoundParameters.RadiusServerId
        $RadiusServerName = $PsBoundParameters.RadiusServerName
        $UserGroupId = $PsBoundParameters.UserGroupId
        $UserGroupName = $PsBoundParameters.UserGroupName
    }
    Process
    {
        $InputObjectType = 'radiusservers'
        $TargetObjectType = 'user_group'
        If ($Action -eq 'GET')
        {
            $Results = Switch ($PSCmdlet.ParameterSetName)
            {
                'ById'
                {
                    Get-JCAssociation -InputObjectType:($InputObjectType) -InputObjectId:($RadiusServerId)  -TargetObjectType:($TargetObjectType);
                }
                'ByName'
                {
                    Get-JCAssociation -InputObjectType:($InputObjectType) -InputObjectName:($RadiusServerName)  -TargetObjectType:($TargetObjectType);
                }
            }
            If (!($Results))
            {
                Switch ($PSCmdlet.ParameterSetName)
                {
                    'ById'
                    {
                        Write-Warning ('No associations found between "' + $RadiusServerId + '" and "' + $TargetObjectType + '".')
                    }
                    'ByName'
                    {
                        Write-Warning ('No associations found between "' + $RadiusServerName + '" and "' + $TargetObjectType + '".')
                    }
                }
            }
        }
        ElseIf ($Action -in ('NEW', 'REMOVE'))
        {
            Switch ($PSCmdlet.ParameterSetName)
            {
                'ById'
                {
                    $RadiusServerObject = Get-JCObject -Type:($InputObjectType) -SearchBy:('ById') -SearchByValue:($RadiusServerId);
                    $GroupObject = Get-JCObject -Type:($TargetObjectType) -SearchBy:('ById') -SearchByValue:($UserGroupId);
                }
                'ByName'
                {
                    $RadiusServerObject = Get-JCObject -Type:($InputObjectType) -SearchBy:('ByName') -SearchByValue:($RadiusServerName);
                    $GroupObject = Get-JCObject -Type:($TargetObjectType) -SearchBy:('ByName') -SearchByValue:($UserGroupName);
                }
            }
            $Results = Switch ($Action)
            {
                'NEW'
                {
                    New-JCAssociation -InputObjectType:($InputObjectType) -InputObjectName:($RadiusServerObject.($RadiusServerObject.ByName)) -TargetObjectType:($TargetObjectType) -TargetObjectName:($GroupObject.($GroupObject.ByName));
                }
                'REMOVE'
                {
                    Remove-JCAssociation -InputObjectType:($InputObjectType) -InputObjectName:($RadiusServerObject.($RadiusServerObject.ByName)) -TargetObjectType:($TargetObjectType) -TargetObjectName:($GroupObject.($GroupObject.ByName));
                }
            }
        }
    }
    End
    {
        Return $Results
    }
}