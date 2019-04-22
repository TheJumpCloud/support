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
                    $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ParameterSets' = @('ById'); 'DefaultValue' = $JCObject.($JCObject.ById) }
                    $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ParameterSets' = @('ByName'); 'DefaultValue' = $JCObject.($JCObject.ByName) }
                }
                Else
                {
                    # Do populate validate set with list of items
                    $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ValidateSet' = @($JCObject.($JCObject.ById | Select-Object -Unique)); 'ParameterSets' = @('ById'); }
                    $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ValidateSet' = @($JCObject.($JCObject.ByName | Select-Object -Unique)); 'ParameterSets' = @('ByName'); }
                }
            }
            Else
            {
                # Don't populate validate set
                $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ParameterSets' = @('ById'); }
                $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ParameterSets' = @('ByName'); }
            }
            $Params += @{'Name' = 'TargetType'; 'Type' = [System.String[]]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ('TargetSingular'); 'ValidateSet' = $JCTypes.Targets.TargetSingular; }
        }
        Else
        {
            $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ParameterSets' = @('ByName'); }
            $Params += @{'Name' = 'TargetType'; 'Type' = [System.String[]]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ('TargetSingular'); 'ValidateSet' = $JCTypes.Targets.TargetSingular; }
        }
        If ($Action -in ('add', 'remove'))
        {
            $Params += @{'Name' = 'TargetId'; 'Type' = [System.String]; 'Position' = 5; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'TargetName'; 'Type' = [System.String]; 'Position' = 6; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); }
        }
        # Create new parameters
        $NewParams = $Params | ForEach-Object { New-Object PSObject -Property:($_) } | New-DynamicParameter
        # Return new parameters
        Return $NewParams
    }
    Begin
    {
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False') }) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') { Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName) }
    }
    Process
    {
        # For parameters with a default value set that value
        $NewParams.Values | Where-Object { $_.IsSet -and $_.Attributes.ParameterSetName -eq $PSCmdlet.ParameterSetName } | ForEach-Object { $PSBoundParameters[$_.Name] = $_.Value }
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object { Set-Variable -Name:($_.Key) -Value:($_.Value) -Force }
        # Associate the action to a http method
        $Method = Switch ($Action)
        {
            'get' { 'GET' }
            'add' { 'POST' }
            'remove' { 'POST' }
        }
        $Results = @()
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
                    Write-Debug ('UrlTemplate:' + $URL_Template_Associations_MemberOf + ';SourcePlural:"' + $SourceItemTypeNamePlural + '";SourceTargetPlural:"' + $SourceItemTargetPlural + '"')
                    $Uri_Associations = $URL_Template_Associations_MemberOf -f $SourceItemTypeNamePlural, $SourceItemId
                }
                ElseIf (($SourceItemTypeNamePlural -eq 'systemgroups' -and $SourceItemTargetPlural -eq 'systems') -or ($SourceItemTypeNamePlural -eq 'usergroups' -and $SourceItemTargetPlural -eq 'users'))
                {
                    $Uri_Associations = $URL_Template_Associations_Membership -f $SourceItemTypeNamePlural, $SourceItemId
                }
                ElseIf (($SourceItemTypeNamePlural -eq 'activedirectories' -and $SourceItemTargetPlural -eq 'users') -or ($SourceItemTypeNamePlural -eq 'users' -and $SourceItemTargetPlural -eq 'activedirectories'))
                {
                    $Uri_Associations = $URL_Template_Associations_Targets -f $SourceItemTypeNamePlural, $SourceItemId, $SourceItemTargetSingular
                }
                Else
                {
                    $Uri_Associations = $URL_Template_Associations_TargetType -f $SourceItemTypeNamePlural, $SourceItemId, $SourceItemTargetPlural
                }
                # Call endpoint
                If ($Action -eq 'get')
                {
                    Write-Debug ('UrlTemplate:' + $Uri_Associations)
                    $Associations = Invoke-JCApi -Method:($Method) -Paginate:($true) -Url:($Uri_Associations)
                    $Results += $Associations
                }
                Else
                {
                    # Get Target object.
                    $Target = Get-JCObject -Type:($SourceItemTargetSingular) -SearchBy:($SearchBy) -SearchByValue:($TargetSearchByValue)
                    $TargetId = $Target.($Target.ById)
                    $TargetName = $Target.($Target.ByName)
                    $TargetTypeNameSingular = $Target.TypeName.TypeNameSingular
                    $TargetTypeNamePlural = $Target.TypeName.TypeNamePlural
                    # Exceptions for specific combinations
                    If (($SourceItemTypeNamePlural -eq 'systems' -and $TargetType -eq 'system_group') -or ($SourceItemTypeNamePlural -eq 'users' -and $TargetType -eq 'user_group'))
                    {
                        $Uri_Associations = $URL_Template_Associations_Members -f $TargetTypeNamePlural, $TargetId
                        $JsonBody = '{"op":"' + $Action + '","type":"' + $SourceItemTypeNameSingular + '","id":"' + $SourceItemId + '","attributes":null}'
                    }
                    Else
                    {
                        $Uri_Associations = $URL_Template_Associations_Targets -f $SourceItemTypeNamePlural, $SourceItemId, $SourceItemTargetSingular
                        $JsonBody = '{"op":"' + $Action + '","type":"' + $TargetTypeNameSingular + '","id":"' + $TargetId + '","attributes":null}'
                    }
                    # Send body to endpoint.
                    Write-Verbose ("$Action association from '$SourceItemName' to '$TargetName'")
                    Write-Debug ('UrlTemplate:' + $Uri_Associations + '; Body:' + $JsonBody)
                    $Results += Invoke-JCApi -Body:($JsonBody) -Method:($Method) -Url:($Uri_Associations)
                }
            }
        }
    }
    End
    {
        Return $Results
    }
}