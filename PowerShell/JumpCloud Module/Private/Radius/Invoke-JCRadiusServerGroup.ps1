Function Invoke-JCRadiusServerGroup ()
{
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('GET', 'NEW', 'REMOVE')][string]$Action
    )
    DynamicParam
    {
        # Build parameter array
        $Params = @()
        # Define the new parameters
        $Params += @{'Name' = 'RadiusServerId'; 'Type' = [System.String]; 'Position' = 1; 'Mandatory' = $true; 'ValueFromPipelineByPropertyName' = $true; 'ParameterSets' = @('ById'); 'ValidateNotNullOrEmpty' = $true; 'Alias' = @('_id', 'id'); }
        $Params += @{'Name' = 'RadiusServerName'; 'Type' = [System.String]; 'Position' = 1; 'Mandatory' = $true; 'ValueFromPipelineByPropertyName' = $true; 'ParameterSets' = @('ByName'); 'ValidateNotNullOrEmpty' = $true; 'Alias' = @('Name'); }
        If ($Action -eq 'GET')
        {
        }
        ElseIf ($Action -in ('NEW', 'REMOVE'))
        {
            $Params += @{'Name' = 'UserGroupId'; 'Type' = [System.String]; 'Position' = 2; 'Mandatory' = $true; 'ValueFromPipelineByPropertyName' = $true; 'ParameterSets' = @('ById'); 'ValidateNotNullOrEmpty' = $true; }
            $Params += @{'Name' = 'UserGroupName'; 'Type' = [System.String]; 'Position' = 2; 'Mandatory' = $true; 'ValueFromPipelineByPropertyName' = $true; 'ParameterSets' = @('ByName'); 'ValidateNotNullOrEmpty' = $true; }
        }
        # Create new parameters
        Return $Params | ForEach-Object {
            New-Object PSObject -Property:($_)
        } | New-DynamicParameter
    }
    Begin
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object {New-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
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