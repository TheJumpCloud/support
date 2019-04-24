Function Invoke-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][string]$Action,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('active_directory', 'command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][string]$Type
    )
    DynamicParam
    {
        # Build dynamic parameters
        Return Invoke-Command -ScriptBlock:($ScriptBlock_DynamicParamAssociation) -ArgumentList:($Action, $Type) -NoNewScope
    }
    Begin
    {
        # Debug message for parameter call
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet, $true, 'White', 'Black') -NoNewScope
        $Results = @()
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        Try
        {
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
            # ScriptBlock used for building get associations results
            $AssociationResults = {
                Param($Action, $Uri, $Method, $SourceId, $SourceType)
                Write-Debug ('[UrlTemplate]:' + $Uri)
                Write-Host ('[UrlTemplate]:' + $Uri) -BackgroundColor:('Cyan') -ForegroundColor:('Black')
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
                        $Association = Invoke-Command -ScriptBlock:($AssociationResults) -ArgumentList:($Action, $Uri_Associations_GET, 'GET', $SourceItemId, $SourceItemTypeNameSingular) -NoNewScope
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
                                $RemoveAssociation = Invoke-Command -ScriptBlock:($AssociationResults) -ArgumentList:($Action, $Uri_Associations_GET, 'GET', $SourceItemId, $SourceItemTypeNameSingular) -NoNewScope | Where-Object {$_.TargetId -eq $TargetItemId}
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
                                Write-Debug ('[UrlTemplate]:' + $Uri_Associations_POST + '; Body:' + $JsonBody + ';')
                                Write-Host ('[UrlTemplate]:' + $Uri_Associations_POST + '; Body:' + $JsonBody + ';') -BackgroundColor:('Green') -ForegroundColor:('Black')
                                If (!($Force))
                                {
                                    Do
                                    {
                                        $HostResponse = Read-Host -Prompt:('Are you sure you want to "' + $Action + '" the association between the "' + $SourceItemTypeNameSingular + '" called "' + $SourceItemName + '" and the "' + $TargetItemTypeNameSingular + '" called "' + $TargetItemName + '"?[Y/N]')
                                    }
                                    Until ($HostResponse -in ('y', 'n'))
                                }
                                If ($HostResponse -eq 'y' -or $Force)
                                {
                                    $Results += Invoke-JCApi -Body:($JsonBody) -Method:('POST') -Url:($Uri_Associations_POST)
                                }
                            }
                            # Get the newly created association
                            If ($Action -eq 'add')
                            {
                                $Results += Invoke-Command -ScriptBlock:($AssociationResults) -ArgumentList:($Action, $Uri_Associations_GET, 'GET', $SourceItemId, $SourceItemTypeNameSingular) -NoNewScope | Where-Object {$_.TargetId -eq $TargetItemId}
                            }
                        }
                    }
                }
            }
        }
        Catch
        {
            Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($_)
        }
    }
    End
    {
        Return $Results #| Select-Object -ExcludeProperty:('associationType')
    }
}