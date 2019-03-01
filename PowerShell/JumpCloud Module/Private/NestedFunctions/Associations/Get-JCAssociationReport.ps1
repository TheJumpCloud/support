Function Get-JCAssociationReport
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 0)][switch]$ById,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0)][switch]$ByName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()]$SourceType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 2)][ValidateNotNullOrEmpty()][string]$SourceId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 2)][ValidateNotNullOrEmpty()][string]$SourceName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 3)][ValidateNotNullOrEmpty()][string]$TargetType
    )
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
    }
    Process
    {
        $SearchBy = $PSCmdlet.ParameterSetName
        Switch ($SearchBy)
        {
            'ById'
            {
                $SourceSearchByValue = $SourceId
            }
            'ByName'
            {
                $SourceSearchByValue = $SourceName
            }
        }
        $OutputObject = @()
        # Get Source object.
        $SourceObject = Get-JCObject -Type:($SourceType) -SearchBy:($SearchBy) -SearchByValue:($SourceSearchByValue)
        $SourceObjectId = $SourceObject.($SourceObject.ById)
        $SourceObjectName = $SourceObject.($SourceObject.ByName)
        # Get target object ids associated with source object
        $AssociationTargets = Get-JCAssociation -SourceType:($SourceType) -SourceId:($SourceObjectId) -TargetType:($TargetType)
        ForEach ($AssociationTarget In $AssociationTargets)
        {
            $AssociationTargetAttributes = $AssociationTarget.attributes
            $AssociationTargetTo = $AssociationTarget.to
            $AssociationTargetToAttributes = $AssociationTargetTo.attributes
            $TargetSearchByValue = $AssociationTargetTo.id
            $TargetType = $AssociationTargetTo.type
            $SearchBy = 'ById'
            # Get Target object.
            $TargetObject = Get-JCObject -Type:($TargetType) -SearchBy:($SearchBy) -SearchByValue:($TargetSearchByValue)
            $TargetObjectId = $TargetObject.($TargetObject.ById)
            $TargetObjectName = $TargetObject.($TargetObject.ByName)
            $OutputObject += [PSCustomObject]@{
                'SourceType' = $SourceType;
                'SourceId'   = $SourceObjectId;
                'SourceName' = $SourceObjectName;
                'TargetType' = $TargetType;
                'TargetId'   = $TargetObjectId;
                'TargetName' = $TargetObjectName;
            }
        }
    }
    End
    {
        Return $OutputObject
    }
}