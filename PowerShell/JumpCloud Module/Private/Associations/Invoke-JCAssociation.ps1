Function Invoke-JCAssociation
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][string]$Action,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('activedirectories', 'active_directory', 'commands', 'command', 'ldapservers', 'ldap_server', 'policies', 'policy', 'applications', 'application', 'radiusservers', 'radius_server', 'systemgroups', 'system_group', 'systems', 'system', 'usergroups', 'user_group', 'users', 'user', 'gsuites', 'g_suite', 'office365s', 'office_365')][string]$InputObjectType
    )
    DynamicParam
    {
        # $InputJCObject = Get-JCObject -Type:($InputObjectType);
        # $InputJCObjectIds = $InputJCObject.($InputJCObject.ById | Select-Object -Unique);
        # $InputJCObjectNames = $InputJCObject.($InputJCObject.ByName | Select-Object -Unique);
        $JCAssociationType = Get-JCAssociationType -InputObject:($InputObjectType);
        # Build parameter array
        $Params = @()
        # Define the new parameters
        $Params += @{'Name' = 'TargetObjectType'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ValidateSet' = $JCAssociationType.Targets; }
        $Params += @{'Name' = 'InputObjectId'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); }# 'ValidateSet' = $InputJCObjectIds; }
        $Params += @{'Name' = 'InputObjectName'; 'Type' = [System.String]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); }#}'ValidateSet' = $InputJCObjectNames; }
        If ($Action -eq 'get')
        {
            # $Params += @{'Name' = 'HideTargetData'; 'Type' = [System.Boolean]; 'Position' = 7; 'ValueFromPipelineByPropertyName' = $true; 'DontShow' = $true; 'ValidateSet' = ($true, $false); }
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
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}

        $URL_Template_Associations = '/api/v2/{0}/{1}/associations?targets={2}'
        $Method = Switch ($Action)
        {
            'get' {'GET'}
            'add' {'POST'}
            'remove' {'POST'}
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
                $InputObjectAssociationsByType = ($InputObjectAssociations | Where-Object {$_.to.Type -eq $InputObjectAssociationsType})
                # Get all target objects of that specific type and then filter them by id
                If ($HideTargetData)
                {
                    # Get TargetObject object ids associated with InputObject
                    ForEach ($AssociationTargetObject In $InputObjectAssociationsByType)
                    {
                        $InputObjectAttributes = $AssociationTargetObject.attributes
                        $AssociationTargetObjectTo = $AssociationTargetObject.to
                        $TargetObjectAttributes = $AssociationTargetObjectTo.attributes
                        $TargetObjectId = $AssociationTargetObjectTo.id
                        $TargetObjectType = $AssociationTargetObjectTo.type
                        # Output InputObject and TargetObject
                        $Results_Associations += [PSCustomObject]@{
                            'InputObjectType'        = $InputObjectType;
                            'InputObjectId'          = $InputObjectId;
                            'InputObjectName'        = $InputObjectName;
                            'InputObjectAttributes'  = $InputObjectAttributes;
                            'TargetObjectType'       = $TargetObjectType;
                            'TargetObjectId'         = $TargetObjectId;
                            'TargetObjectName'       = $null;
                            'TargetObjectAttributes' = $TargetObjectAttributes;
                            'InputObject'            = $InputObject;
                            'TargetObject'           = $null;
                        }
                    }
                }
                Else
                {
                    $TargetObjects = Get-JCObject -Type:($InputObjectAssociationsType) | Where-Object {$_.($_.ById) -in $InputObjectAssociationsByType.to.id}
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
            }
            ##################################################
            ##################################################
            ## Get TargetObject object ids associated with InputObject
            # ForEach ($AssociationTargetObject In $InputObjectAssociations)
            # {
            #     $AssociationTargetObjectAttributes = $AssociationTargetObject.attributes
            #     $AssociationTargetObjectTo = $AssociationTargetObject.to
            #     $AssociationTargetObjectToAttributes = $AssociationTargetObjectTo.attributes
            #     $TargetObjectId = $AssociationTargetObjectTo.id
            #     $TargetObjectType = $AssociationTargetObjectTo.type
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
