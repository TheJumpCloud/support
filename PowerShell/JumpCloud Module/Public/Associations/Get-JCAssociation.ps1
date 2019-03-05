Function Get-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][string]$InputObjectType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][string]$InputObjectId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][string]$InputObjectName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][string]$TargetObjectType
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
                Invoke-JCAssociation -Action:('get') -InputObjectType:($InputObjectType) -InputObjectId:($InputObjectId) -TargetObjectType:($TargetObjectType);
            }
            'ByName'
            {
                Invoke-JCAssociation -Action:('get') -InputObjectType:($InputObjectType) -InputObjectName:($InputObjectName) -TargetObjectType:($TargetObjectType);
            }
        }
    }
    End
    {
        Return $Results
    }
}