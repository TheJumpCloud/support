Function Invoke-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The verb of the command calling it. Different verbs will make different parameters required.')][ValidateSet('add', 'get', 'new', 'remove', 'set')][System.String]$Action
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365', 'active_directory')][Alias('TypeNameSingular')][System.String]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Bypass user prompts and dynamic ValidateSet.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    DynamicParam
    {
        # Build dynamic parameters
        $RuntimeParameterDictionary = Get-DynamicParamAssociation -Action:($Action) -Type:($Type) -Force:($true)
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
        $Results = @()
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        Try
        {
            # All the bindings, recursive , both direct and indirect
            $URL_Template_Associations_MemberOf = 'JumpCloud.SDK.V2\Get-JcSdk{0}Member -{0}Id:("{1}")'
            $URL_Template_Associations_Membership = 'JumpCloud.SDK.V2\Get-JcSdk{0}Membership -GroupId:("{1}")'
            $URL_Template_Associations_TargetType = 'JumpCloud.SDK.V2\Get-JcSdk{0}Traverse{2} -{0}Id:("{1}")'
            # Only direct bindings and don’t traverse through groups
            $URL_Template_Associations_Targets_Get = 'JumpCloud.SDK.V2\Get-JcSdk{0}Association -{0}Id:("{1}") -Targets:("{2}")'
            $URL_Template_Associations_Targets_Post = 'JumpCloud.SDK.V2\Set-JcSdk{0}Association -{0}Id:("{1}") -Id:("{2}") -Op:("{3}") -Type:("{4}") -Attributes:("{5}")'
            $URL_Template_Associations_Members = 'JumpCloud.SDK.V2\Set-JcSdk{0}Member -GroupId:("{1}") -Id:("{2}") -Op:("{3}")'



            # Determine to search by id or name but always prefer id
            If ($Id)
            {
                $SourceItemSearchByValue = $Id
                $SourceSearchBy = 'ById'
            }
            ElseIf ($Name)
            {
                $SourceItemSearchByValue = $Name
                $SourceSearchBy = 'ByName'
            }
            Else
            {
                Write-Error ('-Id or -Name parameter must be populated.') -ErrorAction:('Stop')
            }
            # Get SourceInfo
            $Source = Get-JCObject -Type:($Type) -SearchBy:($SourceSearchBy) -SearchByValue:($SourceItemSearchByValue)
            If ($Source)
            {
                ForEach ($SourceItem In $Source)
                {
                    $SourceItemId = $SourceItem.($SourceItem.ById)
                    $SourceItemName = $SourceItem.($SourceItem.ByName)
                    $SourceItemTypeName = $SourceItem.TypeName
                    $SourceItemTypeNameSingular = $SourceItemTypeName.TypeNameSingular
                    $SourceItemTargets = $SourceItem.Targets |
                    Where-Object { $_.TargetSingular -in $TargetType -or $_.TargetPlural -in $TargetType }
                    ForEach ($SourceItemTarget In $SourceItemTargets)
                    {
                        $SourceItemTargetSingular = $SourceItemTarget.TargetSingular
                        # Build Url based upon source and target combinations
                        If (($SourceItemTypeNameSingular -eq 'system' -and $SourceItemTargetSingular -eq 'system_group') -or ($SourceItemTypeNameSingular -eq 'user' -and $SourceItemTargetSingular -eq 'user_group'))
                        {
                            $Uri_Associations_GET = $URL_Template_Associations_MemberOf -f $SourceItemTypeNameSingular.Replace('_', ''), $SourceItemId
                        }
                        ElseIf (($SourceItemTypeNameSingular -eq 'system_group' -and $SourceItemTargetSingular -eq 'system') -or ($SourceItemTypeNameSingular -eq 'user_group' -and $SourceItemTargetSingular -eq 'user'))
                        {
                            $Uri_Associations_GET = $URL_Template_Associations_Membership -f $SourceItemTypeNameSingular.Replace('_', ''), $SourceItemId
                        }
                        ElseIf (($SourceItemTypeNameSingular -eq 'activedirectory' -and $SourceItemTargetSingular -eq 'user') -or ($SourceItemTypeNameSingular -eq 'user' -and $SourceItemTargetSingular -eq 'activedirectory'))
                        {
                            $Uri_Associations_GET = $URL_Template_Associations_Targets_Get -f $SourceItemTypeNameSingular.Replace('_', ''), $SourceItemId, $SourceItemTargetSingular.Replace('_', '')
                        }
                        Else
                        {
                            $Uri_Associations_GET = $URL_Template_Associations_TargetType -f $SourceItemTypeNameSingular.Replace('_', ''), $SourceItemId, $SourceItemTargetSingular.Replace('_', '')
                        }
                        $Uri_Associations_GET = $Uri_Associations_GET.Replace('usergroupId', 'GroupId').Replace('systemgroupId', 'GroupId')
                        # Call endpoint
                        If ($Action -eq 'get')
                        {
                            $AssociationOut = @()
                            # If switches are not passed in set them to be false so they can be used with Format-JCAssociation
                            If (!($IncludeInfo)) { $IncludeInfo = $false; }
                            If (!($IncludeNames)) { $IncludeNames = $false; }
                            If (!($IncludeVisualPath)) { $IncludeVisualPath = $false; }
                            If (!($Raw)) { $Raw = $false; }
                            # Get associations and format the output
                            $Association = Format-JCAssociation -Uri:($Uri_Associations_GET) -Method:('GET') -Source:($SourceItem) -IncludeInfo:($IncludeInfo) -IncludeNames:($IncludeNames) -IncludeVisualPath:($IncludeVisualPath) -Raw:($Raw)
                            If ($Direct -eq $true)
                            {
                                $AssociationOut += $Association | Where-Object { $_.associationType -eq 'direct' -or $_.associationType -eq "direct`/indirect" }
                            }
                            If ($Indirect -eq $true)
                            {
                                $AssociationOut += $Association | Where-Object { $_.associationType -eq 'indirect' -or $_.associationType -eq "direct`/indirect" }
                            }
                            If (!($Direct) -and !($Indirect))
                            {
                                $AssociationOut += $Association
                            }
                            If ($Raw)
                            {
                                $Result = $AssociationOut | Select-Object -Property:('*') -ExcludeProperty:('associationType', 'httpMetaData')
                                $Results += $Result
                            }
                            Else
                            {
                                $Result = $AssociationOut
                                $Results += $Result | Select-Object * `
                                    , @{Name = 'action'; Expression = { $Action } } `
                                    , @{Name = 'IsSuccessStatusCode'; Expression = { $Association.httpMetaData.BaseResponse.IsSuccessStatusCode | Select-Object -Unique } } `
                                    , @{Name = 'error'; Expression = { $null } }
                            }
                        }
                        Else
                        {
                            # For target determine to search by id or name but always prefer id
                            If ($TargetId)
                            {
                                $TargetSearchByValue = $TargetId
                                $TargetSearchBy = 'ById'
                            }
                            ElseIf ($TargetName)
                            {
                                $TargetSearchByValue = $TargetName
                                $TargetSearchBy = 'ByName'
                            }
                            Else
                            {
                                Write-Error ('-TargetId or -TargetName parameter must be populated.') -ErrorAction:('Stop')
                            }
                            If ($associationType -ne 'indirect')
                            {
                                # Get Target object
                                $Target = Get-JCObject -Type:($SourceItemTargetSingular) -SearchBy:($TargetSearchBy) -SearchByValue:($TargetSearchByValue)
                                If ($Target)
                                {
                                    ForEach ($TargetItem In $Target)
                                    {
                                        $TargetItemId = $TargetItem.($TargetItem.ById)
                                        $TargetItemName = $TargetItem.($TargetItem.ByName)
                                        $TargetItemTypeNameSingular = $TargetItem.TypeName.TypeNameSingular
                                        # Build the attributes for the json body string
                                        $AttributesValue = If ($Action -eq 'add' -and $Attributes)
                                        {
                                            $Attributes | ConvertTo-Json -Depth:(100) -Compress
                                        }
                                        Else
                                        {
                                            'null'
                                        }
                                        # Validate that the association exists
                                        $TestAssociation = Format-JCAssociation -Uri:($Uri_Associations_GET) -Method:('GET') -Source:($SourceItem) -TargetId:($TargetItemId) -IncludeNames:($true)
                                        $IndirectAssociations = $TestAssociation | Where-Object { $_.associationType -eq 'indirect' }
                                        $DirectAssociations = $TestAssociation | Where-Object { $_.associationType -eq 'direct' -or $_.associationType -eq "direct`/indirect" }
                                        If ($DirectAssociations.associationType -eq "direct`/indirect") { $DirectAssociations.associationType = 'direct' }
                                        # If the target is not only an indirect association
                                        If ($TargetItemId -in $DirectAssociations.targetId -or $Action -eq 'add')
                                        {
                                            If (($SourceItemTypeNameSingular -eq 'system' -and $SourceItemTargetSingular -eq 'system_group') -or ($SourceItemTypeNameSingular -eq 'user' -and $SourceItemTargetSingular -eq 'user_group'))
                                            {
                                                $Uri_Associations_POST = $URL_Template_Associations_Members -f $TargetItemTypeNameSingular.Replace('_', ''), $TargetItemId, $SourceItemId, $Action
                                            }
                                            ElseIf (($SourceItemTypeNameSingular -eq 'system_group' -and $SourceItemTargetSingular -eq 'system') -or ($SourceItemTypeNameSingular -eq 'user_group' -and $SourceItemTargetSingular -eq 'user'))
                                            {
                                                $Uri_Associations_POST = $URL_Template_Associations_Members -f $SourceItemTypeNameSingular.Replace('_', ''), $SourceItemId, $TargetItemId, $Action
                                            }
                                            Else
                                            {
                                                $Uri_Associations_POST = $URL_Template_Associations_Targets_Post -f $SourceItemTypeNameSingular.Replace('_', ''), $SourceItemId, $TargetItemId, $Action, $TargetItemTypeNameSingular, $AttributesValue
                                            }
                                            $Uri_Associations_POST = $Uri_Associations_POST.Replace('usergroupId', 'GroupId').Replace('systemgroupId', 'GroupId').Replace(' -Attributes:("null")', '')
                                            # Send body to endpoint.
                                            Write-Verbose ('"' + $Action + '" the association between the "' + $SourceItemTypeNameSingular + '" "' + $SourceItemName + '" and the "' + $TargetItemTypeNameSingular + '" "' + $TargetItemName + '"')
                                            Write-Debug ('[UrlTemplate]:' + $Uri_Associations_POST + ';')
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
                                                Try
                                                {
                                                    $JCApi = Invoke-Expression -Command:($Uri_Associations_POST)
                                                    $ActionResult = $JCApi | Select-Object * `
                                                        , @{Name = 'IsSuccessStatusCode'; Expression = { $JCApi.httpMetaData.BaseResponse.IsSuccessStatusCode | Select-Object -Unique } } `
                                                        , @{Name = 'error'; Expression = { $null } }
                                                }
                                                Catch
                                                {
                                                    $ActionResult = [PSCustomObject]@{
                                                        'IsSuccessStatusCode' = $_.Exception.Response.IsSuccessStatusCode | Select-Object -Unique;
                                                        'error'               = $_;
                                                    }
                                                    Write-Error ($_)
                                                }
                                                # Validate that the new association has been created
                                                If ($Action -in ('add', 'new'))
                                                {
                                                    $AddAssociationValidation = Format-JCAssociation -Uri:($Uri_Associations_GET) -Method:('GET') -Source:($SourceItem) -TargetId:($TargetItemId) -IncludeNames:($true) | Where-Object { $_.TargetId -eq $TargetItemId }
                                                    If ($AddAssociationValidation)
                                                    {
                                                        $Result = $AddAssociationValidation
                                                    }
                                                    Else
                                                    {
                                                        Write-Error ('Association not found. Unable to validate that the association between "' + $SourceItemTypeNameSingular + '" "' + $SourceItemSearchByValue + '" and "' + $TargetItemTypeNameSingular + '" "' + $TargetSearchByValue + '" was created.')
                                                    }
                                                }
                                                # Validate that the old association has been removed
                                                If ($Action -eq 'remove')
                                                {
                                                    $RemoveAssociationValidation = Format-JCAssociation -Uri:($Uri_Associations_GET) -Method:('GET') -Source:($SourceItem) -TargetId:($TargetItemId) -IncludeNames:($true)
                                                    If (!($RemoveAssociationValidation) -or $RemoveAssociationValidation.associationType -eq 'indirect')
                                                    {
                                                        $Result = $DirectAssociations
                                                    }
                                                    Else
                                                    {
                                                        Write-Error ('Association found. Unable to validate that the association between "' + $SourceItemTypeNameSingular + '" "' + $SourceItemSearchByValue + '" and "' + $TargetItemTypeNameSingular + '" "' + $TargetSearchByValue + '" has been removed.')
                                                    }
                                                }
                                                # Append record status
                                                $Results += If ($Result)
                                                {
                                                    $Result | Select-Object * `
                                                        , @{Name = 'action'; Expression = { $Action } } `
                                                        , @{Name = 'IsSuccessStatusCode'; Expression = { $ActionResult.IsSuccessStatusCode | Select-Object -Unique } } `
                                                        , @{Name = 'error'; Expression = { $ActionResult.error } }
                                                }
                                            }
                                        }
                                    }
                                }
                                Else
                                {
                                    Write-Error ('Unable to find the target "' + $SourceItemTargetSingular + '" called "' + $TargetSearchByValue + '".')
                                }
                            }
                            Else
                            {
                                Write-Verbose ('Association is ' + $associationType + ' between "' + $SourceItemTypeNameSingular + '" "' + $SourceItemSearchByValue + '" and "' + $TargetItemTypeNameSingular + '" "' + $TargetSearchByValue + '".')
                            }
                        }
                    }
                }
            }
            Else
            {
                Write-Error ('Unable to find the "' + $Type + '" called "' + $SourceItemSearchByValue + '".')
            }
        }
        Catch
        {
            Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($_, $true) -NoNewScope
        }
    }
    End
    {
        If ($Results)
        {
            # List values to hide in results
            $HiddenProperties = @('httpMetaData')
            Return Hide-ObjectProperty -Object:($Results) -HiddenProperties:($HiddenProperties)
        }
    }
}
