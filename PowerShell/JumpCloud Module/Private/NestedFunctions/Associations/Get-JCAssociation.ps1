Function Get-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        # Any other parameters can go here
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()]$SourceType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()]$SourceId
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
        # Bind the parameter to a friendly variable
        $TargetTypeOption = $PsBoundParameters[$ParameterName]
        #Set JC headers
        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"
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
        $URL_Template_Associations = '{0}/api/v2/{1}/{2}/associations?targets={3}'
    }
    Process
    {
        $Uri_Associations = $URL_Template_Associations -f $JCUrlBasePath, $SourceType, $SourceId, $TargetTypeOption
        $Results_Associations = Invoke-JCApiGet -Url:($Uri_Associations)
    }
    End
    {
        Return $Results_Associations
    }
}