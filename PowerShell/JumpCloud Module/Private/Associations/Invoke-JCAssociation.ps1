Function Invoke-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][string]$Action,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('activedirectories', 'active_directory', 'commands', 'command', 'ldapservers', 'ldap_server', 'policies', 'policy', 'applications', 'application', 'radiusservers', 'radius_server', 'systemgroups', 'system_group', 'systems', 'system', 'usergroups', 'user_group', 'users', 'user', 'gsuites', 'g_suite', 'office365s', 'office_365')][string]$InputObjectType
    )
    DynamicParam
    {
        # Get targets list
        $JCAssociationType = Get-JCObjectType -Type:($InputObjectType) | Where-Object {$_.Category -eq 'JumpCloud'};
        # Get count of InputJCObject to determine if script should load dynamic parameters
        $InputJCObjectCount = (Get-JCObject -Type:($InputObjectType) -ReturnCount).totalCount
        # Build parameter array
        $Params = @()
        # Define the new parameters
        If ($InputJCObjectCount -le 500)
        {
            $InputJCObject = Get-JCObject -Type:($InputObjectType);
            $Params += @{'Name' = 'InputObjectId'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); 'Alias' = (@('id', '_id')); 'ValidateSet' = @($InputJCObject.($InputJCObject.ById | Select-Object -Unique)); }
            $Params += @{'Name' = 'InputObjectName'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); 'Alias' = (@('name', 'username', 'groupName')); 'ValidateSet' = @($InputJCObject.($InputJCObject.ByName | Select-Object -Unique)); }
        }
        Else
        {
            $Params += @{'Name' = 'InputObjectId'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = (@('id', '_id')); 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'InputObjectName'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = (@('name', 'username', 'groupName')); 'ParameterSets' = @('ByName'); }
        }
        $Params += @{'Name' = 'TargetObjectType'; 'Type' = [System.String]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ValidateSet' = $JCAssociationType.Targets; }
        If ($Action -eq 'get')
        {
            $Params += @{'Name' = 'HideTargetData'; 'Type' = [Switch]; 'Position' = 5; 'ValueFromPipelineByPropertyName' = $true; }
        }
        If ($Action -in ('add', 'remove'))
        {
            $Params += @{'Name' = 'TargetObjectId'; 'Type' = [System.String]; 'Position' = 5; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'TargetObjectName'; 'Type' = [System.String]; 'Position' = 6; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); }
        }
        # Create new parameters
        Return $Params | ForEach-Object {New-Object PSObject -Property:($_)} | New-DynamicParameter
    }
    Begin
    {
        If (!($PsBoundParameters.HideTargetData)) {$PsBoundParameters.HideTargetData = $false}
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object {New-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False')}) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
        $Method = Switch ($Action)
        {
            'get' {'GET'}
            'add' {'POST'}
            'remove' {'POST'}
        }
        $Results = @()
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
        # Set the $InputObjectType to use the plural version of value
        $InputObjectType = $JCAssociationType.Plural
        # Get InputObject object.
        $InputObject = Get-JCObject -Type:($InputObjectType) -SearchBy:($SearchBy) -SearchByValue:($InputObjectSearchByValue)
        $InputObjectId = $InputObject.($InputObject.ById)
        $InputObjectName = $InputObject.($InputObject.ByName)
        #Build Url
        $URL_Template_Associations = '/api/v2/{0}/{1}/associations?targets={2}'
        $Uri_Associations = $URL_Template_Associations -f $InputObjectType, $InputObjectId, $TargetObjectType
        # Exceptions for specific combinations
        If (($InputObjectType -eq 'usergroups' -and $TargetObjectType -eq 'user') -or ($InputObjectType -eq 'systemgroups' -and $TargetObjectType -eq 'system'))
        {
            $URL_Template_Associations = '/api/v2/{0}/{1}/members'
            $Uri_Associations = $URL_Template_Associations -f $InputObjectType, $InputObjectId
        }
        If ( $Action -eq 'get' -and ($InputObjectType -eq 'systems' -and $TargetObjectType -eq 'system_group') -or ($InputObjectType -eq 'users' -and $TargetObjectType -eq 'user_group'))
        {
            $URL_Template_Associations = '/api/v2/{0}/{1}/memberof'
            $Uri_Associations = $URL_Template_Associations -f $InputObjectType, $InputObjectId
        }

        If ($Action -eq 'get')
        {
            $InputObjectAssociations = Invoke-JCApi -Method:($Method) -Paginate:($true) -Url:($Uri_Associations)
            # If using a member* path then get the paths attribute
            If ($Uri_Associations -match 'memberof')
            {
                $InputObjectAssociations = $InputObjectAssociations.Paths
            }
            # Get the input objects associations type
            $InputObjectAssociationsTypes = $InputObjectAssociations.to.type | Select-Object -Unique
            ForEach ($InputObjectAssociationsType In $InputObjectAssociationsTypes)
            {
                # Get the input objects associations id's that match the specific type
                $InputObjectAssociationsByType = ($InputObjectAssociations | Where-Object {$_.to.Type -eq $InputObjectAssociationsType})
                # Get all target objects of that specific type and then filter them by id
                $TargetObjects = If (!($HideTargetData)) {Get-JCObject -Type:($InputObjectAssociationsType) | Where-Object {$_.($_.ById) -in $InputObjectAssociationsByType.to.id}}
                # Get TargetObject object ids associated with InputObject
                ForEach ($AssociationTargetObject In $InputObjectAssociationsByType)
                {
                    $InputObjectAttributes = $AssociationTargetObject.attributes
                    $AssociationTargetObjectTo = $AssociationTargetObject.to
                    $TargetObjectAttributes = $AssociationTargetObjectTo.attributes
                    $TargetObjectId = $AssociationTargetObjectTo.id
                    $TargetObjectType = $AssociationTargetObjectTo.type
                    $ResultRecord = [PSCustomObject]@{
                        'InputObjectType'       = $InputObjectType;
                        'InputObjectId'         = $InputObjectId;
                        'InputObjectName'       = $InputObjectName;
                        'InputObjectAttributes' = $InputObjectAttributes;
                        'InputObject'           = $InputObject;
                        'TargetObjectType'      = $TargetObjectType;
                        'TargetObjectId'        = $TargetObjectId;
                    }
                    If (!($HideTargetData))
                    {
                        # Find specific target object
                        $TargetObject = $TargetObjects | Where-Object {$_.($_.ById) -eq $TargetObjectId}
                        Add-Member -InputObject:($ResultRecord) -MemberType:('NoteProperty') -Name:('TargetObjectName') -Value:($TargetObject.($TargetObject.ByName))
                    }
                    Add-Member -InputObject:($ResultRecord) -MemberType:('NoteProperty') -Name:('TargetObjectAttributes') -Value:($TargetObjectAttributes)
                    If (!($HideTargetData)) {Add-Member -InputObject:($ResultRecord) -MemberType:('NoteProperty') -Name:('TargetObject') -Value:($TargetObject)}
                    # Output InputObject and TargetObject
                    $Results += $ResultRecord
                }
            }
            If ($Results)
            {
                # Update results
                $HiddenProperties = @('InputObject', 'InputObjectAttributes', 'InputObjectId', 'InputObjectName', 'InputObjectType')
                $Results |  ForEach-Object {
                    # Create the default property display set
                    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]($_.PSObject.Properties.Name | Where-Object {$_ -notin $HiddenProperties}))
                    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                    # Add the list of standard members
                    Add-Member -InputObject:($_) -MemberType:('MemberSet') -Name:('PSStandardMembers') -Value:($PSStandardMembers)
                }
            }
            Else
            {
                Write-Verbose ('No results found.')
            }
        }
        Else
        {
            # Get TargetObject object.
            $TargetObject = Get-JCObject -Type:($TargetObjectType) -SearchBy:($SearchBy) -SearchByValue:($TargetObjectSearchByValue)
            $TargetObjectId = $TargetObject.($TargetObject.ById)
            $TargetObjectName = $TargetObject.($TargetObject.ByName)
            # Exceptions for specific combinations
            If (($InputObjectType -eq 'systems' -and $TargetObjectType -eq 'system_group') -or ($InputObjectType -eq 'users' -and $TargetObjectType -eq 'user_group'))
            {
                $URL_Template_Associations = '/api/v2/{0}/{1}/members'
                $Uri_Associations = $URL_Template_Associations -f $TargetObject.Plural, $TargetObjectId
                $JsonBody = '{"op":"' + $Action + '","type":"' + $InputObject.Singular + '","id":"' + $InputObjectId + '","attributes":null}'
            }
            Else
            {
                # Build body to be sent to endpoint.
                $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetObject.Singular + '","id":"' + $TargetObjectId + '","attributes":null}'
            }
            # Send body to endpoint.
            Write-Verbose ("$Action association from '$InputObjectName' to '$TargetObjectName'")
            $Results += Invoke-JCApi -Body:($JsonBody) -Method:($Method) -Url:($Uri_Associations)
        }
    }
    End
    {
        Return $Results
    }
}