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
    }
    Process
    {
        # Your code goes here
        $Uri_Associations = $URL_Template_Associations -f $JCUrlBasePath, $SourceType, $SourceId, $TargetTypeOption
        Write-Verbose ('Connecting to: ' + $Uri_Associations)
        $Results_Associations = Invoke-JCApiGet -Url:($Uri_Associations)
    }
    End
    {
        Return $Results_Associations
    }
}