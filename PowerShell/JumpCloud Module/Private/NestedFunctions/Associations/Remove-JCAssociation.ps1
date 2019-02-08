Function Remove-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 0)][switch]$ById,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 0)][switch]$ByName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()][string]$SourceType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 3)][ValidateNotNullOrEmpty()][string]$SourceId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 4)][ValidateNotNullOrEmpty()][string]$TargetId,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 3)][ValidateNotNullOrEmpty()][string]$SourceName,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName', Position = 4)][ValidateNotNullOrEmpty()][string]$TargetName
    )
    DynamicParam
    {
        # Set the dynamic parameters' name
        $ParameterName = 'TargetType'
        # Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 2
        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)
        # Generate and set the ValidateSet
        $arrSet = Switch ($SourceType)
        {
            'activedirectories' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')}
            'applications' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')}
            'commands' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')}
            'gsuites' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')}
            'ldapservers' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')}
            'office365s' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')}
            'policies' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')}
            'radiusservers' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')}
            'systemgroups' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'user', 'user_group')}
            'systems' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'user', 'user_group')}
            'usergroups' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group')}
            'users' {@('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group')}
            Default {Write-Error 'Unknown $SourceType specified.'};
        }
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)
        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Bind the parameter to a friendly variable
        $TargetTypeOption = $PsBoundParameters[$ParameterName]
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
        $URL_Template_Associations = '{0}/api/v2/{1}/{2}/associations?targets={3}'
        $Method = 'POST'
        $Action = 'remove'
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
        $SourceObject_CommandType = Get-CommandType -Type:($SourceType) -SearchBy:($SearchBy) -SearchByValue:($SourceSearchByValue)
        $SourceObject_Command = $SourceObject_CommandType.Command
        $SourceObject_ByName = $SourceObject_CommandType.ByName
        $SourceObject_ById = $SourceObject_CommandType.ById
        Write-Verbose ('Running command: ' + $SourceObject_Command)
        $SourceObject = Invoke-Expression -Command:($SourceObject_Command)
        $SourceObjectId = $SourceObject.$SourceObject_ById
        $SourceObjectName = $SourceObject.$SourceObject_ByName
        # Get Target object.
        $TargetObject_CommandType = Get-CommandType -Type:($TargetType) -SearchBy:($SearchBy) -SearchByValue:($TargetSearchByValue)
        $TargetObject_Command = $TargetObject_CommandType.Command
        $TargetObject_ByName = $TargetObject_CommandType.ByName
        $TargetObject_ById = $TargetObject_CommandType.ById
        Write-Verbose ('Running command: ' + $TargetObject_Command)
        $TargetObject = Invoke-Expression -Command:($TargetObject_Command)
        $TargetObjectId = $TargetObject.$TargetObject_ById
        $TargetObjectName = $TargetObject.$TargetObject_ByName
        # Build body to be sent to endpoint.
        $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetType + '","id":"' + $TargetObjectId + '","attributes":null}'
        # Send body to endpoint.
        $Uri_Associations = $URL_Template_Associations -f $JCUrlBasePath, $SourceType, $SourceObjectId, $TargetTypeOption
        Write-Verbose ('Connecting to: ' + $Uri_Associations)
        Write-Verbose ('Sending JsonBody: ' + $JsonBody)
        Write-Host ("$Action association from '$SourceObjectName' to '$TargetObjectName'")
        $Results_Associations = Invoke-RestMethod -Method:($Method) -Uri:($Uri_Associations) -Headers:($hdrs) -Body:($JsonBody)
    }
    End
    {
        Return $Results_Associations
    }
}