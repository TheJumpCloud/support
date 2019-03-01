Function Invoke-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('add', 'remove')][string]$Action,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][string]$SourceType,
        # DynamicParam $TargetType
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 3)][ValidateNotNullOrEmpty()][string]$SourceId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 4)][ValidateNotNullOrEmpty()][string]$TargetId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 3)][ValidateNotNullOrEmpty()][string]$SourceName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 4)][ValidateNotNullOrEmpty()][string]$TargetName
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
        $TargetType = $PsBoundParameters[$ParameterName]
        $URL_Template_Associations = '{0}/api/v2/{1}/{2}/associations?targets={3}'
        $Method = 'POST'
    }
    Process
    {
        $SearchBy = $PSCmdlet.ParameterSetName
        Switch ($SearchBy)
        {
            'ById'
            {
                $SourceSearchByValue = $SourceId
                $TargetSearchByValue = $TargetId
            }
            'ByName'
            {
                $SourceSearchByValue = $SourceName
                $TargetSearchByValue = $TargetName
            }
        }
        # Get Source object.
        $SourceObject = Get-JCObject -Type:($SourceType) -SearchBy:($SearchBy) -SearchByValue:($SourceSearchByValue)
        $SourceObjectId = $SourceObject.($SourceObject.ById)
        $SourceObjectName = $SourceObject.($SourceObject.ByName)
        # Get Target object.
        $TargetObject = Get-JCObject -Type:($TargetType) -SearchBy:($SearchBy) -SearchByValue:($TargetSearchByValue)
        $TargetObjectId = $TargetObject.($TargetObject.ById)
        $TargetObjectName = $TargetObject.($TargetObject.ByName)
        # Build body to be sent to endpoint.
        $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetType + '","id":"' + $TargetObjectId + '","attributes":null}'
        # Send body to endpoint.
        $Uri_Associations = $URL_Template_Associations -f $JCUrlBasePath, $SourceType, $SourceObjectId, $TargetType
        Write-Verbose ("$Action association from '$SourceObjectName' to '$TargetObjectName'")
        $Results_Associations = Invoke-JCApi -Body:($JsonBody) -Method:($Method) -Url:($Uri_Associations)
    }
    End
    {
        Return $Results_Associations
    }
}