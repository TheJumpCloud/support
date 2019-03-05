Function Invoke-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][string]$Action,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][string]$InputObjectType,
        # DynamicParam $TargetObjectType
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 3)][ValidateNotNullOrEmpty()][string]$InputObjectId,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 4)][ValidateNotNullOrEmpty()][string]$TargetObjectId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 3)][ValidateNotNullOrEmpty()][string]$InputObjectName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 4)][ValidateNotNullOrEmpty()][string]$TargetObjectName
    )
    DynamicParam
    {
        # Set the dynamic parameters' name
        $ParameterName = 'TargetObjectType'
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
        $arrSet = (Get-JCAssociationType -InputObject:($InputObjectType)).Targets
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
        $TargetObjectType = $PsBoundParameters[$ParameterName]
        $URL_Template_Associations = '/api/v2/{0}/{1}/associations?targets={2}'
        If ($Action -eq 'get')
        {
            $Method = 'GET'
        }
        Else
        {
            $Method = 'POST'
        }
        $Results_Associations = @()
    }
    Process
    {
        $SearchBy = $PSCmdlet.ParameterSetName
        Switch ($SearchBy)
        {
            'ById'
            {
                $InputObjectSearchByValue = $InputObjectId
                $TargetObjectSearchByValue = $TargetObjectId
            }
            'ByName'
            {
                $InputObjectSearchByValue = $InputObjectName
                $TargetObjectSearchByValue = $TargetObjectName
            }
        }
        # Get InputObject object.
        $InputObject = Get-JCObject -Type:($InputObjectType) -SearchBy:($SearchBy) -SearchByValue:($InputObjectSearchByValue)
        $InputObjectId = $InputObject.($InputObject.ById)
        $InputObjectName = $InputObject.($InputObject.ByName)
        #Build Url
        $Uri_Associations = $URL_Template_Associations -f $InputObjectType, $InputObjectId, $TargetObjectType
        If ($Action -eq 'get')
        {
            $InputObjectAssociations = Invoke-JCApi -Method:($Method) -Paginate:($true) -Url:($Uri_Associations)
            ##################################################
            ##################################################
            # Get the input objects associations type
            $InputObjectAssociationsTypes = $InputObjectAssociations.to.type | Select-Object -Unique
            ForEach ($InputObjectAssociationsType In $InputObjectAssociationsTypes)
            {
                # Get the input objects associations id's that match the specific type
                $InputObjectAssociationsByType = ($InputObjectAssociations | Where-Object {$_.to.Type -eq $InputObjectAssociationsType}).to.id
                # Get all target objects of that specific type and then filter them by id
                $TargetObjects = Get-JCObject -Type:($InputObjectAssociationsType) | Where-Object {$_.($_.ById) -in $InputObjectAssociationsByType}
                ForEach ($TargetObject In $TargetObjects)
                {
                    $TargetObjectId = $TargetObject.($TargetObject.ById)
                    $TargetObjectName = $TargetObject.($TargetObject.ByName)
                    # Output InputObject and TargetObject
                    $Results_Associations += [PSCustomObject]@{
                        'InputObjectType'  = $InputObjectType;
                        'InputObjectId'    = $InputObjectId;
                        'InputObjectName'  = $InputObjectName;
                        'TargetObjectType' = $TargetObjectType;
                        'TargetObjectId'   = $TargetObjectId;
                        'TargetObjectName' = $TargetObjectName;
                        'InputObject'      = $InputObject;
                        'TargetObject'     = $TargetObject;
                    }
                }
            }
            ##################################################
            ##################################################
            # Get TargetObject object ids associated with InputObject
            # ForEach ($AssociationTargetObject In $InputObjectAssociations)
            # {
            #     $AssociationTargetObjectAttributes = $AssociationTargetObject.attributes
            #     $AssociationTargetObjectTo = $AssociationTargetObject.to
            #     $AssociationTargetObjectToAttributes = $AssociationTargetObjectTo.attributes
            #     $TargetObjectId = $AssociationTargetObjectTo.id
            #     $TargetObjectType = $AssociationTargetObjectTo.type
            #     # # Could potentially recurse to get all associations using this.
            #     # # Update FunctionParameters with TargetObject values
            #     # $FunctionParameters['InputObjectId'] = $TargetObjectId
            #     # $FunctionParameters['InputObjectType'] = $TargetObjectType
            #     # $FunctionParameters.Remove('Action') | Out-Null
            #     # # Get TargetObject object
            #     # Write-Verbose ('Invoke-JCAssociation ' + ($FunctionParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
            #     # $TargetObjectAssociations = Invoke-JCAssociation @FunctionParameters
            #     # $TargetObject = $TargetObjectAssociations.InputObject | Select-Object -Unique
            #     # $TargetObjectId = $TargetObject.($TargetObject.ById)
            #     # $TargetObjectName = $TargetObject.($TargetObject.ByName)
            #     $TargetObject = Get-JCObject -Type:($TargetObjectType) -SearchBy:('ById') -SearchByValue:($TargetObjectId)
            #     $TargetObjectId = $TargetObject.($TargetObject.ById)
            #     $TargetObjectName = $TargetObject.($TargetObject.ByName)
            #     # Output InputObject and TargetObject
            #     $Results_Associations += [PSCustomObject]@{
            #         'InputObjectType'  = $InputObjectType;
            #         'InputObjectId'    = $InputObjectId;
            #         'InputObjectName'  = $InputObjectName;
            #         'TargetObjectType' = $TargetObjectType;
            #         'TargetObjectId'   = $TargetObjectId;
            #         'TargetObjectName' = $TargetObjectName;
            #         'InputObject'      = $InputObject;
            #         'TargetObject'     = $TargetObject;
            #     }
            # }
        }
        Else
        {
            # Get TargetObject object.
            $TargetObject = Get-JCObject -Type:($TargetObjectType) -SearchBy:($SearchBy) -SearchByValue:($TargetObjectSearchByValue)
            $TargetObjectId = $TargetObject.($TargetObject.ById)
            $TargetObjectName = $TargetObject.($TargetObject.ByName)
            # Build body to be sent to endpoint.
            $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetObjectType + '","id":"' + $TargetObjectId + '","attributes":null}'
            # Send body to endpoint.
            Write-Verbose ("$Action association from '$InputObjectName' to '$TargetObjectName'")
            $Results_Associations += Invoke-JCApi -Body:($JsonBody) -Method:($Method) -Url:($Uri_Associations)
        }
    }
    End
    {
        Return $Results_Associations
    }
}
