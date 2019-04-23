Function Invoke-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][string]$Action,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('active_directory', 'command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][string]$Type
    )
    DynamicParam
    {
        # Build parameter array
        $Params = @()
        # Get type list
        $JCTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' };
        If ($Action -and $Type)
        {
            # Determine if help files are being built
            If ((Get-PSCallStack).Command -like '*MarkdownHelp')
            {
                $JCObjectCount = 999999
            }
            Else
            {
                # Get targets list
                $JCTypes = $JCTypes | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
                # Get count of JCObject to determine if script should load dynamic parameters
                $JCObjectCount = (Get-JCObject -Type:($Type) -ReturnCount).totalCount
            }
            # Define the new parameters
            If ($JCObjectCount -ge 1 -and $JCObjectCount -le 300)
            {
                $JCObject = Get-JCObject -Type:($Type);
                If ($JCObjectCount -eq 1)
                {
                    # Don't require Id and Name to be passed through and set a default value
                    $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ParameterSets' = @('ById'); 'DefaultValue' = $JCObject.($JCObject.ById) }
                    $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ParameterSets' = @('ByName'); 'DefaultValue' = $JCObject.($JCObject.ByName) }
                }
                Else
                {
                    # Do populate validate set with list of items
                    $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ValidateSet' = @($JCObject.($JCObject.ById | Select-Object -Unique)); 'ParameterSets' = @('ById'); }
                    $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ValidateSet' = @($JCObject.($JCObject.ByName | Select-Object -Unique)); 'ParameterSets' = @('ByName'); }
                }
            }
            Else
            {
                # Don't populate validate set
                $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ParameterSets' = @('ById'); }
                $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ParameterSets' = @('ByName'); }
            }
            $Params += @{'Name' = 'TargetType'; 'Type' = [System.String[]]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ('TargetSingular'); 'ValidateSet' = $JCTypes.Targets.TargetSingular; }
        }
        Else
        {
            $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ParameterSets' = @('ByName'); }
            $Params += @{'Name' = 'TargetType'; 'Type' = [System.String[]]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ('TargetSingular'); 'ValidateSet' = $JCTypes.Targets.TargetSingular; }
        }
        If ($Action -eq 'get')
        {
            $Params += @{'Name' = 'Direct'; 'Type' = [Switch]; 'Position' = 5; 'ValueFromPipelineByPropertyName' = $true; 'DefaultValue' = $false; }
            $Params += @{'Name' = 'Indirect'; 'Type' = [Switch]; 'Position' = 6; 'ValueFromPipelineByPropertyName' = $true; 'DefaultValue' = $false; }
        }
        If ($Action -in ('add', 'remove'))
        {
            $Params += @{'Name' = 'TargetId'; 'Type' = [System.String]; 'Position' = 5; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'TargetName'; 'Type' = [System.String]; 'Position' = 6; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); }
            $Params += @{'Name' = 'Force'; 'Type' = [Switch]; 'Position' = 8; 'ValueFromPipelineByPropertyName' = $true; 'DefaultValue' = $false; }
        }
        If ($Action -eq 'add')
        {
            $Params += @{'Name' = 'Attributes'; 'Type' = [System.Management.Automation.PSObject]; 'Position' = 7; 'ValueFromPipelineByPropertyName' = $true; 'Alias' = 'compiledAttributes'; }
        }
        # Create new parameters
        $NewParams = $Params | ForEach-Object { New-Object PSObject -Property:($_) } | New-DynamicParameter
        # Return new parameters
        Return $NewParams
    }
    Begin
    {
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False')}) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') { Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName) }
        $Results = @()
    }
    Process
    {
        # For parameters with a default value set that value
        $NewParams.Values | Where-Object { $_.IsSet -and $_.Attributes.ParameterSetName -eq $PSCmdlet.ParameterSetName } | ForEach-Object { $PSBoundParameters[$_.Name] = $_.Value }
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object { Set-Variable -Name:($_.Key) -Value:($_.Value) -Force }
        Try
        {
            # Scriptblock used for building get associations results
            $AssociationResults = {
                Param($Action, $Uri, $Method, $SourceId, $SourceType)
                Write-Debug ('UrlTemplate:' + $Uri)
                Return Invoke-JCApi -Method:($Method) -Paginate:($true) -Url:($Uri) | Select-Object @{Name = 'action'; Expression = {$Action}} `
                    , @{Name = 'associationType'; Expression = {
                        If (($_.paths | ForEach-Object {$_.Count}) -eq 1) {'direct'}
                        ElseIf (($_.paths | ForEach-Object {$_.Count}) -gt 1) {'indirect'}
                        Else {'unknown'}}
                } `
                    , @{Name = 'id'; Expression = {$SourceId}} `
                    , @{Name = 'type'; Expression = {$SourceType}} `
                    , @{Name = 'targetId'; Expression = {$_.id}} `
                    , @{Name = 'targetType'; Expression = {$_.type}} `
                    , compiledAttributes `
                    , paths
            }
            # All the bindings, recursive , both direct and indirect
            $URL_Template_Associations_MemberOf = '/api/v2/{0}/{1}/memberof' # $SourcePlural, $SourceId
            $URL_Template_Associations_Membership = '/api/v2/{0}/{1}/membership' # $SourcePlural (systemgroups,usergroups), $SourceId
            $URL_Template_Associations_TargetType = '/api/v2/{0}/{1}/{2}' # $SourcePlural, $SourceId, $TargetPlural
            # Only direct bindings and don’t traverse through groups
            $URL_Template_Associations_Targets = '/api/v2/{0}/{1}/associations?targets={2}' # $SourcePlural, $SourceId, $TargetSingular
            $URL_Template_Associations_Members = '/api/v2/{0}/{1}/members' # $SourcePlural, $SourceId
            # Determine to search by id or name
            $SearchBy = $PSCmdlet.ParameterSetName
            Switch ($SearchBy)
            {
                'ById'
                {
                    $SourceItemSearchByValue = $Id
                    $TargetSearchByValue = $TargetId
                }
                'ByName'
                {
                    $SourceItemSearchByValue = $Name
                    $TargetSearchByValue = $TargetName
                }
            }
            # Get SourceInfo
            $Source = Get-JCObject -Type:($Type) -SearchBy:($SearchBy) -SearchByValue:($SourceItemSearchByValue)
            If ($Source.Count -gt 1)
            {
                Write-Warning -Message:('Found "' + [string]$Source.Count + '" "' + $Type + '" with the "' + $SearchBy.Replace('By', '').ToLower() + '" of "' + $SourceItemSearchByValue + '"')
            }
            ForEach ($SourceItem In $Source)
            {
                $SourceItemId = $SourceItem.($SourceItem.ById)
                $SourceItemName = $SourceItem.($SourceItem.ByName)
                $SourceItemTypeName = $SourceItem.TypeName
                $SourceItemTypeNameSingular = $SourceItemTypeName.TypeNameSingular
                $SourceItemTypeNamePlural = $SourceItemTypeName.TypeNamePlural
                $SourceItemTargets = $SourceItem.Targets | Where-Object { $_.TargetSingular -in $TargetType -or $_.TargetPlural -in $TargetType }
                ForEach ($SourceItemTarget In $SourceItemTargets)
                {
                    $SourceItemTargetSingular = $SourceItemTarget.TargetSingular
                    $SourceItemTargetPlural = $SourceItemTarget.TargetPlural
                    # Build Url based upon source and target combinations
                    If (($SourceItemTypeNamePlural -eq 'systems' -and $SourceItemTargetPlural -eq 'systemgroups') -or ($SourceItemTypeNamePlural -eq 'users' -and $SourceItemTargetPlural -eq 'usergroups'))
                    {
                        $Uri_Associations_GET = $URL_Template_Associations_MemberOf -f $SourceItemTypeNamePlural, $SourceItemId
                    }
                    ElseIf (($SourceItemTypeNamePlural -eq 'systemgroups' -and $SourceItemTargetPlural -eq 'systems') -or ($SourceItemTypeNamePlural -eq 'usergroups' -and $SourceItemTargetPlural -eq 'users'))
                    {
                        $Uri_Associations_GET = $URL_Template_Associations_Membership -f $SourceItemTypeNamePlural, $SourceItemId
                    }
                    ElseIf (($SourceItemTypeNamePlural -eq 'activedirectories' -and $SourceItemTargetPlural -eq 'users') -or ($SourceItemTypeNamePlural -eq 'users' -and $SourceItemTargetPlural -eq 'activedirectories'))
                    {
                        $Uri_Associations_GET = $URL_Template_Associations_Targets -f $SourceItemTypeNamePlural, $SourceItemId, $SourceItemTargetSingular
                    }
                    Else
                    {
                        $Uri_Associations_GET = $URL_Template_Associations_TargetType -f $SourceItemTypeNamePlural, $SourceItemId, $SourceItemTargetPlural
                    }
                    # Call endpoint
                    If ($Action -eq 'get')
                    {
                        $Association = & $AssociationResults -Action:($Action) -Uri:($Uri_Associations_GET) -Method:('GET') -SourceId:($SourceItemId) -SourceType:($SourceItemTypeNameSingular)
                        If ($Direct -eq $true)
                        {
                            $Results += $Association.Where( {$_.associationType -eq 'direct'} )
                        }
                        If ($Indirect -eq $true)
                        {
                            $Results += $Association.Where( {$_.associationType -eq 'indirect'} )
                        }
                        If (!($Direct) -and !($Indirect))
                        {
                            $Results += $Association
                        }
                    }
                    Else
                    {
                        # Build the attributes for the json body string
                        $AttributesValue = If ($Action -eq 'add' -and $Attributes) {$Attributes | ConvertTo-Json -Depth:(100) -Compress}Else {'null'}
                        # Get Target object
                        $Target = Get-JCObject -Type:($SourceItemTargetSingular) -SearchBy:($SearchBy) -SearchByValue:($TargetSearchByValue)
                        ForEach ($TargetItem In $Target)
                        {
                            $TargetItemId = $TargetItem.($TargetItem.ById)
                            $TargetItemName = $TargetItem.($TargetItem.ByName)
                            $TargetItemTypeNameSingular = $TargetItem.TypeName.TypeNameSingular
                            $TargetItemTypeNamePlural = $TargetItem.TypeName.TypeNamePlural
                            # Get the existing association before removing it
                            If ($Action -eq 'remove')
                            {
                                $RemoveAssociation = & $AssociationResults -Action:($Action) -Uri:($Uri_Associations_GET) -Method:('GET') -SourceId:($SourceItemId) -SourceType:($SourceItemTypeNameSingular) | Where-Object {$_.TargetId -eq $TargetItemId}
                                $IndirectAssociations = $RemoveAssociation.Where( {$_.associationType -ne 'direct'} )
                                $Results += $RemoveAssociation.Where( {$_.associationType -eq 'direct'} )
                            }
                            If ($TargetItemId -ne $IndirectAssociations.targetId)
                            {
                                # Build uri and body
                                If (($SourceItemTypeNamePlural -eq 'systems' -and $SourceItemTargetPlural -eq 'systemgroups') -or ($SourceItemTypeNamePlural -eq 'users' -and $SourceItemTargetPlural -eq 'usergroups'))
                                {
                                    $Uri_Associations_POST = $URL_Template_Associations_Members -f $TargetItemTypeNamePlural, $TargetItemId
                                    $JsonBody = '{"op":"' + $Action + '","type":"' + $SourceItemTypeNameSingular + '","id":"' + $SourceItemId + '","attributes":' + $AttributesValue + '}'
                                }
                                Else
                                {
                                    $Uri_Associations_POST = $URL_Template_Associations_Targets -f $SourceItemTypeNamePlural, $SourceItemId, $SourceItemTargetSingular
                                    $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetItemTypeNameSingular + '","id":"' + $TargetItemId + '","attributes":' + $AttributesValue + '}'
                                }
                                # Send body to endpoint.
                                Write-Verbose ('"' + $Action + '" the association between the "' + $SourceItemTypeNameSingular + '" "' + $SourceItemName + '" and the "' + $TargetItemTypeNameSingular + '" "' + $TargetItemName + '"')
                                Write-Debug ('UrlTemplate:' + $Uri_Associations_POST + '; Body:' + $JsonBody + ';')
                                If (!($Force))
                                {
                                    $HostResponse = (Read-Host -Prompt:('Are you sure you want to "' + $Action + '" the association between the "' + $SourceItemTypeNameSingular + '" called "' + $SourceItemName + '" and the "' + $TargetItemTypeNameSingular + '" called "' + $TargetItemName + '"?[Y/N]')).ToLower()
                                }
                                If ($HostResponse -eq 'y' -or $Force)
                                {
                                    $Results += Invoke-JCApi -Body:($JsonBody) -Method:('POST') -Url:($Uri_Associations_POST)
                                }
                            }
                            # Get the newly created association
                            If ($Action -eq 'add')
                            {
                                $Results += & $AssociationResults -Action:($Action) -Uri:($Uri_Associations_GET) -Method:('GET') -SourceId:($SourceItemId) -SourceType:($SourceItemTypeNameSingular) | Where-Object {$_.TargetId -eq $TargetItemId}
                            }
                        }
                    }
                }
            }
        }
        Catch
        {
            Invoke-Command -ScriptBlock:($TryCatchError) -ArgumentList:($_)
        }
    }
    End
    {
        Return $Results #| Select-Object -ExcludeProperty:('associationType')
    }
}