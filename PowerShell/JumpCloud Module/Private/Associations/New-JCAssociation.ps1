Function New-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][string]$InputObjectType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][string]$InputObjectId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][string]$InputObjectName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][string]$TargetObjectType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 3)][ValidateNotNullOrEmpty()][string]$TargetObjectId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 3)][ValidateNotNullOrEmpty()][string]$TargetObjectName
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
                Invoke-JCAssociation -Action:('add') -InputObjectType:($InputObjectType) -InputObjectId:($InputObjectId) -TargetObjectType:($TargetObjectType) -TargetObjectId:($TargetObjectId);
            }
            'ByName'
            {
                Invoke-JCAssociation -Action:('add') -InputObjectType:($InputObjectType) -InputObjectName:($InputObjectName) -TargetObjectType:($TargetObjectType) -TargetObjectName:($TargetObjectName);
            }
        }
    }
    End
    {
        Return $Results
    }
}   