Function Invoke-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][System.String]$Action
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][System.String]$Type
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
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet) -NoNewScope
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
                    $SourceItemTypeNamePlural = $SourceItemTypeName.TypeNamePlural
                    $SourceItemTargets = $SourceItem.Targets |
                        Where-Object { $_.TargetSingular -in $TargetType -or $_.TargetPlural -in $TargetType }
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
                            $AssociationOut = @()
                            # If switches are not passed in set them to be false so they can be used with Format-JCAssociation
                            If (!($IncludeInfo)) {$IncludeInfo = $false; }
                            If (!($IncludeNames)) {$IncludeNames = $false; }
                            If (!($IncludeVisualPath)) {$IncludeVisualPath = $false; }
                            If (!($Raw)) {$Raw = $false; }
                            # Get associations and format the output
                            $Association = Format-JCAssociation -Uri:($Uri_Associations_GET) -Method:('GET') -Source:($SourceItem) -IncludeInfo:($IncludeInfo) -IncludeNames:($IncludeNames) -IncludeVisualPath:($IncludeVisualPath) -Raw:($Raw)
                            If ($Direct -eq $true)
                            {
                                $AssociationOut += $Association | Where-Object {$_.associationType -eq 'direct' -or $_.associationType -eq "direct`/indirect"}
                            }
                            If ($Indirect -eq $true)
                            {
                                $AssociationOut += $Association | Where-Object {$_.associationType -eq 'indirect' -or $_.associationType -eq "direct`/indirect"}
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
                                    , @{Name = 'action'; Expression = {$Action}} `
                                    , @{Name = 'IsSuccessStatusCode'; Expression = {$Association.httpMetaData.BaseResponse.IsSuccessStatusCode | Select-Object -Unique}} `
                                    , @{Name = 'error'; Expression = {$null}}
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
                                        $TargetItemTypeNamePlural = $TargetItem.TypeName.TypeNamePlural
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
                                        $IndirectAssociations = $TestAssociation  | Where-Object {$_.associationType -eq 'indirect'}
                                        $DirectAssociations = $TestAssociation  | Where-Object {$_.associationType -eq 'direct' -or $_.associationType -eq "direct`/indirect"}
                                        If ($DirectAssociations.associationType -eq "direct`/indirect") {$DirectAssociations.associationType = 'direct'}
                                        # If the target is not only an indirect association
                                        If ($TargetItemId -in $DirectAssociations.targetId -or $Action -eq 'add')
                                        {
                                            # Build uri and body
                                            If (($SourceItemTypeNamePlural -eq 'systems' -and $SourceItemTargetPlural -eq 'systemgroups') -or ($SourceItemTypeNamePlural -eq 'users' -and $SourceItemTargetPlural -eq 'usergroups'))
                                            {
                                                $Uri_Associations_POST = $URL_Template_Associations_Members -f $TargetItemTypeNamePlural, $TargetItemId
                                                $JsonBody = '{"op":"' + $Action + '","type":"' + $SourceItemTypeNameSingular + '","id":"' + $SourceItemId + '","attributes":' + $AttributesValue + '}'
                                            }
                                            ElseIf (($SourceItemTypeNamePlural -eq 'systemgroups' -and $SourceItemTargetPlural -eq 'systems') -or ($SourceItemTypeNamePlural -eq 'usergroups' -and $SourceItemTargetPlural -eq 'users'))
                                            {
                                                $Uri_Associations_POST = $URL_Template_Associations_Members -f $SourceItemTypeNamePlural, $SourceItemId
                                                $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetItemTypeNameSingular + '","id":"' + $TargetItemId + '","attributes":' + $AttributesValue + '}'
                                            }
                                            Else
                                            {
                                                $Uri_Associations_POST = $URL_Template_Associations_Targets -f $SourceItemTypeNamePlural, $SourceItemId, $SourceItemTargetSingular
                                                $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetItemTypeNameSingular + '","id":"' + $TargetItemId + '","attributes":' + $AttributesValue + '}'
                                            }
                                            # Send body to endpoint.
                                            Write-Verbose ('"' + $Action + '" the association between the "' + $SourceItemTypeNameSingular + '" "' + $SourceItemName + '" and the "' + $TargetItemTypeNameSingular + '" "' + $TargetItemName + '"')
                                            Write-Debug ('[UrlTemplate]:' + $Uri_Associations_POST + '; Body:' + $JsonBody + ';')
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
                                                    $JCApi = Invoke-JCApi -Body:($JsonBody) -Method:('POST') -Url:($Uri_Associations_POST)
                                                    $ActionResult = $JCApi | Select-Object * `
                                                        , @{Name = 'IsSuccessStatusCode'; Expression = {$JCApi.httpMetaData.BaseResponse.IsSuccessStatusCode | Select-Object -Unique}} `
                                                        , @{Name = 'error'; Expression = {$null}}
                                                }
                                                Catch
                                                {
                                                    $ActionResult = [PSCustomObject]@{
                                                        'IsSuccessStatusCode' = $_.Exception.Response.IsSuccessStatusCode | Select-Object -Unique;
                                                        'error'               = $_;
                                                    }
                                                    Write-Error ($_)
                                                }
                                            }
                                            # Validate that the new association has been created
                                            If ($Action -eq 'add')
                                            {
                                                $AddAssociationValidation = Format-JCAssociation -Uri:($Uri_Associations_GET) -Method:('GET') -Source:($SourceItem) -TargetId:($TargetItemId) -IncludeNames:($true) | Where-Object {$_.TargetId -eq $TargetItemId}
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
                                                    , @{Name = 'action'; Expression = {$Action}} `
                                                    , @{Name = 'IsSuccessStatusCode'; Expression = {$ActionResult.IsSuccessStatusCode | Select-Object -Unique}} `
                                                    , @{Name = 'error'; Expression = {$ActionResult.error}}
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
            # List values to add to results
            $HiddenProperties = @('httpMetaData')
            # Append meta info to each result record
            Get-Variable -Name:($HiddenProperties) |
                ForEach-Object {
                $Variable = $_
                $Results |
                    ForEach-Object {
                    Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:($Variable.Name) -Value:($Variable.Value)
                }
            }
            Return Hide-ObjectProperty -Object:($Results) -HiddenProperties:($HiddenProperties)
        }
    }
}
