Function Get-CommandType
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        # Any other parameters can go here
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()]$Type,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()]$SearchBy,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 2)][ValidateNotNullOrEmpty()]$SearchByValue
    )
    $TypeCommand = @()
    $TypeCommand += [PSCustomObject]@{'Type' = @('system', 'systems'); 'JCFunction' = 'Get-JCSystem'; 'ById' = 'SystemID'; 'ByName' = 'DisplayName'; }
    $TypeCommand += [PSCustomObject]@{'Type' = @('user', 'users'); 'JCFunction' = 'Get-JCUser'; 'ById' = 'UserId'; 'ByName' = 'UserName'; }
    # Identify the command type to run to get the object for the specified item
    $TypeCommandItem = $TypeCommand | Where-Object {$Type -in $_.Type}
    $TypeCommandItem.Type = $Type
    $JCFunction = $TypeCommandItem.JCFunction
    $PropertyIdentifier = Switch ($SearchBy)
    {
        'ById' {$TypeCommandItem.ById};
        'ByName' {$TypeCommandItem.ByName};
    }
    $Command_Template = "{0} -{1}:('{2}');"
    $Object_Command = $Command_Template -f $JCFunction, $PropertyIdentifier, $SearchByValue
    Return $TypeCommandItem | Select-Object *, @{Name = 'PropertyIdentifier'; Expression = {$PropertyIdentifier}}, @{Name = 'Command'; Expression = {$Object_Command}}
}


# https://martin77s.wordpress.com/2014/06/09/dynamic-validateset-in-a-dynamic-parameter/
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

Function Get-JCAssociationReport
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        # Any other parameters can go here
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 0)][ValidateNotNullOrEmpty()]$SourceType,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()]$SearchBy,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()]$SearchByValue,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName, Position = 1)][ValidateNotNullOrEmpty()]$TargetType
    )
    $OutputObject = @()
    # Use the source type to identify which command to run to get the source object
    $SourceObject_Command = Get-CommandType -Type:($SourceType) -SearchBy:($SearchBy) -SearchByValue:($SearchByValue)
    $SourceObject_ByName = $SourceObject_Command.ByName
    $SourceObject = Invoke-Expression -Command:($SourceObject_Command.Command)
    $SourceObjectId = $SourceObject._id
    $SourceObjectName = $SourceObject.$SourceObject_ByName
    # Get target object ids associated with source object
    $AssociationTargets = Get-JCAssociation -SourceType:($SourceType) -SourceId:($SourceObjectId) -TargetType:($TargetType)
    ForEach ($AssociationTarget In $AssociationTargets)
    {
        $AssociationTargetAttributes = $AssociationTarget.attributes
        $AssociationTargetTo = $AssociationTarget.to
        $AssociationTargetToAttributes = $AssociationTargetTo.attributes
        $AssociationTargetToId = $AssociationTargetTo.id
        $AssociationTargetToType = $AssociationTargetTo.type
        $SearchBy = 'ById'
        # Use the associated object type to identify which command to run to get the associated target object
        $AssociationTargetObject_Command = Get-CommandType -Type:($AssociationTargetToType) -SearchBy:($SearchBy) -SearchByValue:($AssociationTargetToId)
        $AssociationTargetObject_ByName = $AssociationTargetObject_Command.ByName
        $AssociationTargetObject = Invoke-Expression -Command:($AssociationTargetObject_Command.Command)
        $AssociationTargetObjectId = $AssociationTargetObject._id
        $AssociationTargetObjectName = $AssociationTargetObject.$AssociationTargetObject_ByName
        $OutputObject += [PSCustomObject]@{
            'SourceObjectName'            = $SourceObjectName;
            'AssociationTargetToType'     = $AssociationTargetToType;
            'AssociationTargetObjectName' = $AssociationTargetObjectName;
        }
    }
    Return $OutputObject
}


# ##############################################################################################################################
# ##############################################################################################################################
# Use to test each function.
# ##############################################################################################################################
# Get-CommandType -Type:('systems') -SearchBy:('ByName') -SearchByValue:('Active_AWS Linux')
# Get-CommandType -Type:('users') -SearchBy:('ByName') -SearchByValue:('cool.dude')
# Get-JCAssociation -SourceType:('systems') -SourceId:('5b193f483839366dd7ee3981') -TargetType:('user') -verbose
# Get-JCAssociation -SourceType:('users') -SourceId:('5ab915cf861178491b8fc399') -TargetType:('system')
# ##############################################################################################################################
# ##############################################################################################################################
# Dynamically passing in inputs to generate report.
# ##############################################################################################################################
$InputObject = @()
$InputObject += [PSCustomObject]@{'SourceType' = 'systems'; 'SearchBy' = 'ByName'; 'SourceId' = '8675309'; 'SourceName' = 'Active_AWS Linux'; 'TargetType' = 'user'; }
$InputObject += [PSCustomObject]@{'SourceType' = 'users'; 'SearchBy' = 'ByName'; 'SourceId' = '8675309'; 'SourceName' = 'cool.dude'; 'TargetType' = 'system'; }
$OutputObject = @()
ForEach ($Record In $InputObject)
{
    $SourceType = $Record.SourceType
    $SearchBy = $Record.SearchBy
    $SourceId = $Record.SourceId
    $SourceName = $Record.SourceName
    $TargetType = $Record.TargetType
    $SearchByValue = Switch ($SearchBy)
    {
        'ById' {$SourceId};
        'ByName' {$SourceName};
    }
    $OutputObject += Get-JCAssociationReport -SourceType:($SourceType) -SearchBy:($SearchBy) -SearchByValue:($SearchByValue) -TargetType:($TargetType)

}
$OutputObject | FT

##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
# $Source_activedirectories = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
# $Source_applications = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
# $Source_commands = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
# $Source_gsuites = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
# $Source_ldapservers = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
# $Source_office365s = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
# $Source_policies = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
# $Source_radiusservers = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', 'user', 'user_group')
# $Source_systemgroups = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', '', '', 'user', 'user_group')
# $Source_systems = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', '', '', 'user', 'user_group')
# $Source_usergroups = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', '', '')
# $Source_users = @('active_directory', 'application', 'command', 'g_suite', 'ldap_server', 'office_365', 'policy', 'radius_server', 'system', 'system_group', '', '')
# $Var_Prefix_Source = 'Source_'
# $Var_Sources = Get-Variable | Where {$_.Name -like ($Var_Prefix_Source + '*')}
# ForEach ($Var_Source In $Var_Sources)
# {
# 	$SourceName = ($Var_Source.Name).Replace($Var_Prefix_Source, '')
# 	$TargetValues = $Var_Source.Value
# 	ForEach ($TargetValue In $TargetValues)
# 	{
# 		Write-Host ("Get-JCAssociation -SourceType:('$SourceName') -SourceId:('1234') -TargetType:('$TargetValue')")
# 	}
# }