Function Remove-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 0)][switch]$ById,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0)][switch]$ByName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][string]$SourceType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()][string]$TargetType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 3)][ValidateNotNullOrEmpty()][string]$SourceId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 4)][ValidateNotNullOrEmpty()][string]$TargetId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 3)][ValidateNotNullOrEmpty()][string]$SourceName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 4)][ValidateNotNullOrEmpty()][string]$TargetName
    )
    Begin
    {
        $Action = 'remove'
    }
    Process
    {
        $SearchBy = $PSCmdlet.ParameterSetName
        Switch ($SearchBy)
        {
            'ById'
            {
                $Results_Associations = Invoke-JCAssociation -Action:($Action) -ById -SourceType:($SourceType) -SourceId:($SourceId) -TargetType:($TargetType) -TargetId:($TargetId)
            }
            'ByName'
            {
                $Results_Associations = Invoke-JCAssociation -Action:($Action) -ByName -SourceType:($SourceType) -SourceName:($SourceName) -TargetType:($TargetType) -TargetName:($TargetName)
            }
        }
    }
    End
    {
        Return $Results_Associations
    }
}