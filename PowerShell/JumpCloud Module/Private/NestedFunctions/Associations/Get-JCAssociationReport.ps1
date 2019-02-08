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
        #Set JC headers
        Write-Verbose "Paramter Set: $($PSCmdlet.ParameterSetName)"
        Write-Verbose 'Verifying JCAPI Key'
        If ($JCAPIKEY.length -ne 40) {Connect-JCOnline}
        Write-Verbose 'Populating API headers'
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }
        If ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }
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
        $SourceObject_CommandType = Get-CommandType -Type:($SourceType) -SearchBy:($SearchBy) -SearchByValue:($SourceSearchByValue)
        $SourceObject_Command = $SourceObject_CommandType.Command
        $SourceObject_ByName = $SourceObject_CommandType.ByName
        $SourceObject_ById = $SourceObject_CommandType.ById
        Write-Verbose ('Running command: ' + $SourceObject_Command)
        $SourceObject = Invoke-Expression -Command:($SourceObject_Command)
        $SourceObjectId = $SourceObject.$SourceObject_ById
        $SourceObjectName = $SourceObject.$SourceObject_ByName
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
            $TargetObject_CommandType = Get-CommandType -Type:($TargetType) -SearchBy:($SearchBy) -SearchByValue:($TargetSearchByValue)
            $TargetObject_Command = $TargetObject_CommandType.Command
            $TargetObject_ByName = $TargetObject_CommandType.ByName
            $TargetObject_ById = $TargetObject_CommandType.ById
            Write-Verbose ('Running command: ' + $TargetObject_Command)
            $TargetObject = Invoke-Expression -Command:($TargetObject_Command)
            $TargetObjectId = $TargetObject.$TargetObject_ById
            $TargetObjectName = $TargetObject.$TargetObject_ByName
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