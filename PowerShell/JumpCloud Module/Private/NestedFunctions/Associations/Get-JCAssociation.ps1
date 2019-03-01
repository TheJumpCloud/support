Function Get-JCAssociationReport
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()]$SourceType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 1)][ValidateNotNullOrEmpty()][string]$SourceId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 1)][ValidateNotNullOrEmpty()][string]$SourceName
    )
    DynamicParam
    {
        # Set the dynamic parameters' name
        $ParameterName = 'TargetType'
        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        # Create the parameters attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        # Set the parameters attributes
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.ValueFromPipelineByPropertyName = $true
        $ParameterAttribute.Position = 2
        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)
        # Set the ValidateNotNullOrEmpty
        $ValidateNotNullOrEmptyAttribute = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute
        # Add the ValidateNotNullOrEmpty to the attributes collection
        $AttributeCollection.Add($ValidateNotNullOrEmptyAttribute)
        # Generate the ValidateSet
        $arrSet = (Get-JCAssociationType -Source:($SourceType)).Targets
        # Set the ValidateSet
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)
        # Create the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        # Create the parameter dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # Return the dynamic parameter to the parameter dictionary
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
        # Bind the parameter to a friendly variable
        $TargetType = $PsBoundParameters[$ParameterName]
        $URL_Template_Associations = '/api/v2/{0}/{1}/associations?targets={2}'
        $Method = 'GET'
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
        # Get Source object
        $SourceObject = Get-JCObject -Type:($SourceType) -SearchBy:($SearchBy) -SearchByValue:($SourceSearchByValue)
        $SourceObjectId = $SourceObject.($SourceObject.ById)
        $SourceObjectName = $SourceObject.($SourceObject.ByName)
        # Get target object ids associated with source object
        $AssociationTargets = Invoke-JCApi -Url:($URL_Template_Associations -f $SourceType, $SourceObjectId, $TargetType) -Method:($Method) -Paginate:($true)
        ForEach ($AssociationTarget In $AssociationTargets)
        {
            $AssociationTargetAttributes = $AssociationTarget.attributes
            $AssociationTargetTo = $AssociationTarget.to
            $AssociationTargetToAttributes = $AssociationTargetTo.attributes
            $TargetSearchByValue = $AssociationTargetTo.id
            $TargetType = $AssociationTargetTo.type
            $SearchBy = 'ById'
            # Get Target object
            $TargetObject = Get-JCObject -Type:($TargetType) -SearchBy:($SearchBy) -SearchByValue:($TargetSearchByValue)
            $TargetObjectId = $TargetObject.($TargetObject.ById)
            $TargetObjectName = $TargetObject.($TargetObject.ByName)
            # Output SourceObject and TargetObject
            $OutputObject += [PSCustomObject]@{
                'SourceType'   = $SourceType;
                'SourceId'     = $SourceObjectId;
                'SourceName'   = $SourceObjectName;
                'TargetType'   = $TargetType;
                'TargetId'     = $TargetObjectId;
                'TargetName'   = $TargetObjectName;
                'SourceObject' = $SourceObject;
                'TargetObject' = $TargetObject;
            }
        }
    }
    End
    {
        Return $OutputObject
    }
}