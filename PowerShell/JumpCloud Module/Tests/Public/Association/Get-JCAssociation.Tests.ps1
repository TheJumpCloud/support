Describe "Association Tests" {
    BeforeAll {
        # $DebugPreference = 'Continue' # SilentlyContinue (Default), Continue, Inquire, Stop
        # $VerbosePreference = 'Continue' # SilentlyContinue (Default), Continue, Inquire, Stop
        $ErrorActionPreference = 'Stop' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend
    }
    AfterAll {
        # $DebugPreference = 'SilentlyContinue' # SilentlyContinue (Default), Continue, Inquire, Stop
        # $VerbosePreference = 'SilentlyContinue' # SilentlyContinue (Default), Continue, Inquire, Stop
        $ErrorActionPreference = 'Continue' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend
    }
    # BeforeEach {}
    # AfterEach {}
    # Define misc. variables
    $TestMethods = ('ById', 'ByName')
    $Mock = $false
    # Internal Functions
    Function Test-AssociationCommand
    {
        Param(
            [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('Full', 'Pipe')][string]$ExecutionType
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][string]$Verb
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][object]$Source
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 3)][ValidateNotNullOrEmpty()][string]$SourceId
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 4)][ValidateNotNullOrEmpty()][string]$SourceType
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 5)][ValidateNotNullOrEmpty()][string]$SourceSearchByValue
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 6)][ValidateNotNullOrEmpty()][object]$Target
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 7)][ValidateNotNullOrEmpty()][string]$TargetId
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 8)][ValidateNotNullOrEmpty()][string]$TargetType
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 9)][ValidateNotNullOrEmpty()][string]$TargetSearchByValue
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 10)][ValidateNotNullOrEmpty()][string]$TestMethod
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 11)][ValidateNotNullOrEmpty()][string]$TestMethodIdentifier
        )
        $CommandNoun = "JCAssociation"
        $Template_FunctionName = "{0}-$CommandNoun"
        $Template_SourceParameters = " -Type:('{0}') -{1}:('{2}') {3}"
        $Template_SourceParameters_TargetType = "$Template_SourceParameters -TargetType:('{4}')"
        $Template_AllSourceParameters = "$Template_SourceParameters_TargetType -Target{1}:('{5}')"
        $Template_TargetParameters_TargetType = " -TargetType:('{0}') {1}"
        $Template_AllTargetParameters = "$Template_TargetParameters_TargetType -Target{2}:('{3}')"
        $Template_Message = "$Template_FunctionName by running: {1}"
        $FunctionName = ($Template_FunctionName -f $Verb)

        $SwitchColumnHash = [ordered]@{
            ''                  = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'paths');
            'Raw'               = @('id', 'type', 'paths'); # 'compiledAttributes',
            'Direct'            = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'paths');
            'Indirect'          = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'paths'); # 'compiledAttributes',
            'IncludeInfo'       = @('action', 'associationType', 'id', 'type', 'info', 'targetId', 'targetType', 'targetInfo', 'paths'); # 'compiledAttributes',
            'IncludeNames'      = @('action', 'associationType', 'id', 'type', 'name', 'targetId', 'targetType', 'targetName', 'paths'); # 'compiledAttributes',
            'IncludeVisualPath' = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'visualPathById', 'visualPathByName', 'visualPathByType', 'paths'); # 'compiledAttributes',
        }
        # Get function switch parameters
        $Parameters = ((Get-Command $FunctionName).Parameters.GetEnumerator()| ForEach-Object {$_.Value.Where( {$_.Name -notin ([System.Management.Automation.PSCmdlet]::CommonParameters)})} ) | Select-Object *, @{Name = 'ParameterSetsName'; Expression = {$_.ParameterSets.Keys}}
        $ParameterSwitches = $Parameters.Where( {($_.SwitchParameter -and $_.Name -ne 'Raw')})
        $ParameterSwitchesString = If ($ParameterSwitches.Name) {'-' + ($ParameterSwitches.Name -join ' -')} {$ParameterSwitches.Name}
        # Build command
        If ($ExecutionType -eq 'Full')
        {
            $Command = Switch ($Verb)
            {
                'Add' {@(($Template_AllSourceParameters -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString, $TargetType, $TargetSearchByValue))}
                'Get' {@(($Template_SourceParameters_TargetType -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString, $TargetType), ($Template_SourceParameters -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString))}
                'Remove' {@(($Template_AllSourceParameters -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString, $TargetType, $TargetSearchByValue))}
                Default {Write-Error ('Unknown $Verb:' + $Verb)}
            }
            $Commands = $Command | ForEach-Object {$FunctionName + $_}
        }
        ElseIf ($ExecutionType -eq 'Pipe')
        {
            $Command = Switch ($Verb)
            {
                'Add' {@(($Template_AllTargetParameters -f $TargetType, $ParameterSwitchesString, $TestMethodIdentifier, $TargetSearchByValue))}
                'Get' {@(($Template_TargetParameters_TargetType -f $TargetType, $ParameterSwitchesString), '')}
                'Remove' {@(($Template_AllTargetParameters -f $TargetType, $ParameterSwitchesString, $TestMethodIdentifier, $TargetSearchByValue))}
                Default {Write-Error ('Unknown $Verb:' + $Verb)}
            }
            $Commands = $Command | ForEach-Object {'$Source | ' + $FunctionName + $_}
        }
        Else
        {
            Write-Error ('Unknown -ExecutionType:' + $ExecutionType)
        }
        # Run command
        ForEach ($Command In $Commands)
        {
            $ItMessage = $Template_Message -f $Verb, $Command.Replace('$Source', "Get-JCObject -Type:('$SourceType') -Id:('$SourceId')")
            If ($Mock)
            {
                Write-Host ('[Mock]' + $Command.Replace('$Source', "Get-JCObject -Type:('$SourceType') -Id:('$SourceId')"))
            }
            Else
            {
                $Associations = Invoke-Expression -Command:($Command)
            }
            # Run tests
            Context ($ItMessage) {
                # Test results of action
                If (!($Mock))
                {
                    It("Where action property should be $Verb") {$Associations.Action | Should -Be $Verb}
                    It("Where results should be not NullOrEmpty") {$Associations | Should -Not -BeNullOrEmpty}
                    It("Where results $($Associations.Id) should be $SourceId") {$Associations.Id | Should -Be $SourceId}
                    It("Where results $($Associations.Type) should be $SourceType") {$Associations.Type | Should -Be $SourceType}
                    It("Where results $($Associations.TargetId) should be $TargetId") {$Associations.TargetId | Should -Be $TargetId}
                    It("Where results $($Associations.TargetType) should be $TargetType") {$Associations.TargetType | Should -Be $TargetType}
                    It("Where results count should BeGreaterThan 0") {$Associations.Count | Should -BeGreaterThan 0}
                    If ($Verb -eq 'Get')
                    {
                        $AssociationsProperties = ($Associations | ForEach-Object {$_.PSObject.Properties.name} | Select-Object -Unique)
                        $SwitchColumnHash.GetEnumerator() | ForEach-Object {
                            $ParameterName = $_.Key
                            $ExpectedColumns = $_.Value
                            # $Command_Get_Switch = $FunctionName + ($Template_SourceParameters -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $TargetType)
                            If ($Command -match $ParameterName)
                            {
                                ForEach ($ExpectedColumn In $ExpectedColumns)
                                {
                                    # It("Where '$ExpectedColumn' is a property in '$($AssociationsProperties -join ', ')'") {
                                    It("Where '$ExpectedColumn' is a property in the output from the command") {
                                        $ExpectedColumn | Should -BeIn $AssociationsProperties
                                    }
                                }
                            }
                        }
                    }
                    # Get the associations
                    $Associations_Validation = $Associations | Get-JCAssociation -Direct
                    # Test that the change was applied
                    If ($Verb -eq 'Remove')
                    {
                        It("Where results validation should be NullOrEmpty") {$Associations_Validation | Should -BeNullOrEmpty}
                        It("Where results validation $($Associations_Validation.Id) should be $SourceId") {$Associations_Validation.Id | Should -BeNullOrEmpty $SourceId}
                        It("Where results validation $($Associations_Validation.Type) should be $SourceType") {$Associations_Validation.Type | Should -BeNullOrEmpty $SourceType}
                        It("Where results validation $($Associations_Validation.TargetId) should be $TargetId") {$Associations_Validation.TargetId | Should -BeNullOrEmpty $TargetId}
                        It("Where results validation $($Associations_Validation.TargetType) should be $TargetType") {$Associations_Validation.TargetType | Should -BeNullOrEmpty $TargetType}
                        It("Where results validation count should be 0") {$Associations_Validation.Count | Should -Be 0}
                    }
                    Else
                    {
                        It("Where results validation should be not NullOrEmpty") {$Associations_Validation | Should -Not -BeNullOrEmpty}
                        It("Where results validation $($Associations_Validation.Id) should be $SourceId") {$Associations_Validation.Id | Should -Be $SourceId}
                        It("Where results validation $($Associations_Validation.Type) should be $SourceType") {$Associations_Validation.Type | Should -Be $SourceType}
                        It("Where results validation $($Associations_Validation.TargetId) should be $TargetId") {$Associations_Validation.TargetId | Should -Be $TargetId}
                        It("Where results validation $($Associations_Validation.TargetType) should be $TargetType") {$Associations_Validation.TargetType | Should -Be $TargetType}
                        It("Where results validation count should BeGreaterThan 0") {$Associations_Validation.Count | Should -BeGreaterThan 0}
                        It("Where results validation count should be $($Associations.Count)") {$Associations_Validation.Count | Should -Be $Associations.Count}
                    }
                }
            }
        }
    }
    # Generate $AssociationDataSet object records by looping through each association type and its target types
    Context ("Get each type of JC object association possible and build list of source and targets to test with.") {
        $AssociationDataSet = @()
        class AssociationItem
        {
            [System.String]$SourceType; [System.String]$SourceId; [System.String]$SourceName; [object]$Source; [System.String]$TargetType; [System.String]$TargetId; [System.String]$TargetName; [object]$Target; [bool]$ValidRecord;
            AssociationItem([System.String]$ST, [System.String]$SI, [System.String]$SN, [object]$S, [System.String]$TT, [System.String]$TI, [System.String]$TN, [object]$T, [bool]$VR)
            {$this.SourceType = $ST; $this.SourceId = $SI; $this.SourceName = $SN; $this.Source = $S; $this.TargetType = $TT; $this.TargetId = $TI; $this.TargetName = $TN; $this.Target = $T; $this.ValidRecord = $VR; }
        }
        $JCAssociationTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' }
        $EmptySources = @()
        ForEach ($JCAssociationType In $JCAssociationTypes)
        {
            $Source = Get-JCObject -Type:($JCAssociationType.TypeName.TypeNameSingular) | Select-Object -First 1 # | Get-Random
            If ($Source)
            {
                ForEach ($TargetSingular In $Source.TargetSingular)
                {
                    If ( $TargetSingular -notin $EmptySources)
                    {
                        $Target = Get-JCObject -Type:($TargetSingular) | Select-Object -First 1 # | Get-Random
                        If ($Target)
                        {
                            $AssociationDataSet += [AssociationItem]::new(
                                $Source.TypeNameSingular
                                , $Source.($Source.ById)
                                , $Source.($Source.ByName)
                                , $Source
                                , $Target.TypeNameSingular
                                , $Target.($Target.ById)
                                , $Target.($Target.ByName)
                                , $Target
                                , $true
                            )
                        }
                        Else
                        {
                            $EmptySources += $TargetSingular
                            $AssociationDataSet += [AssociationItem]::new($Source.TypeNameSingular, $Source.($Source.ById), $Source.($Source.ByName), $Source, $TargetSingular, $null, $null, $null, $false)
                        }
                    }
                }
            }
            Else
            {
                $EmptySources += $JCAssociationType.TypeName.TypeNameSingular
                $JCAssociationType.Targets | ForEach-Object {
                    $AssociationDataSet += [AssociationItem]::new($JCAssociationType.TypeName.TypeNameSingular, $null, $null, $null, $_.TargetSingular, $null, $null, $null, $false)
                }
            }
        }
        ####################################################################################################
        # # Export data to file
        # ($AssociationDataSet | ConvertTo-JSON) | Out-File -Path:($PSScriptRoot + '/Get-JCAssociation.Tests.BigOrg.json')
        # # Import data for testing manually
        # $AssociationDataSetContent = Get-Content -Raw -Path:($PSScriptRoot + '/Get-JCAssociation.Tests.BigOrg.json')
        # $AssociationDataSet = $AssociationDataSetContent | ConvertFrom-Json -Depth:(100)
        ####################################################################################################
        # Get valid association items
        $ValidAssociationItems = $AssociationDataSet.Where( {$_.ValidRecord -and $_.SourceId -and $_.TargetId -and $_.SourceType -eq 'user' -and $_.TargetType -eq 'system'})
        # Get invalid association items
        $InvalidAssociationItems = $AssociationDataSet.Where( {-not $_.ValidRecord -and -not $_.SourceId -and -not $_.TargetId}) |
            Select-Object @{Name = 'Status'; Expression = {'No "' + $_.SourceType + '" found within org. Please create a "' + $_.SourceType + '"'}} -Unique
        # Validate that org has been fully populated
        # It("Validate that all object types exist within the specified test environment.") {
        #     $InvalidAssociationItems | Should -BeNullOrEmpty
        # }
        # If ($InvalidAssociationItems) { Write-Error ($InvalidAssociationItems.Status -join ', '); }
        # Using dataset run tests
        ForEach ($AssociationItem In $ValidAssociationItems)
        {
            $SourceType = $AssociationItem.SourceType
            $SourceId = $AssociationItem.SourceId
            $SourceName = $AssociationItem.SourceName
            $Source = $AssociationItem.Source
            $TargetType = $AssociationItem.TargetType
            $TargetId = $AssociationItem.TargetId
            $TargetName = $AssociationItem.TargetName
            $Target = $AssociationItem.Target

            # # Define source and target variables
            # $SourceType = $Source.TypeNameSingular
            # $SourceId = $Source.($Source.ById)
            # $SourceName = $Source.($Source.ByName)
            # $TargetType = $Target.TypeNameSingular
            # $TargetId = $Target.($Target.ById)
            # $TargetName = $Target.($Target.ByName)

            # Start test for each test method
            ForEach ($TestMethod In $TestMethods)
            {
                Context ("When Association functions are called with parameterSet: '$TestMethod';SourceType:'$SourceType';SourceId:'$SourceId';SourceName:$SourceName';TargetType:$TargetType';TargetId:$TargetId';TargetName:$TargetName';") {
                    $TestMethodIdentifier = $TestMethod.Replace('By', '')
                    $SourceSearchByValue = Switch ($TestMethod) { 'ById' { $SourceId }'ByName' { $SourceName } }
                    $TargetSearchByValue = Switch ($TestMethod) { 'ById' { $TargetId }'ByName' { $TargetName } }
                    Try
                    {
                        # Get current associations and save them to be reapplied later
                        $AssociationsOriginalCommand = "Get-JCAssociation -Type:('$SourceType') -$TestMethodIdentifier`:('$SourceSearchByValue') -Direct; "
                        Write-Host ('Backing up Source associations: ' + $AssociationsOriginalCommand)
                        If ($Mock)
                        {
                            Write-Host ('[Mock]' + $AssociationsOriginalCommand)
                        }
                        Else
                        {
                            $AssociationsOriginal = Invoke-Expression -Command:($AssociationsOriginalCommand)
                        }
                        # Remove current associations
                        $ChangedOriginal = $false
                        If ($AssociationsOriginal)
                        {
                            $CommandResults_RemoveOriginal = $AssociationsOriginal | Remove-JCAssociation -Force
                            If ($CommandResults_RemoveOriginal)
                            {
                                $ChangedOriginal = $true
                            }
                        }
                        Context ("When Association functions are called by populating all parameters.") {
                            Test-AssociationCommand -ExecutionType:('Full') -Verb:('Add') -Source:($Source) -SourceId:($SourceId) -SourceType:($SourceType) -SourceSearchByValue:($SourceSearchByValue) -Target:($Target) -TargetId:($TargetId) -TargetType:($TargetType) -TargetSearchByValue:($TargetSearchByValue) -TestMethod:($TestMethod) -TestMethodIdentifier:($TestMethodIdentifier)
                            Test-AssociationCommand -ExecutionType:('Full') -Verb:('Get') -Source:($Source) -SourceId:($SourceId) -SourceType:($SourceType) -SourceSearchByValue:($SourceSearchByValue) -Target:($Target) -TargetId:($TargetId) -TargetType:($TargetType) -TargetSearchByValue:($TargetSearchByValue) -TestMethod:($TestMethod) -TestMethodIdentifier:($TestMethodIdentifier)
                            Test-AssociationCommand -ExecutionType:('Full') -Verb:('Remove') -Source:($Source) -SourceId:($SourceId) -SourceType:($SourceType) -SourceSearchByValue:($SourceSearchByValue) -Target:($Target) -TargetId:($TargetId) -TargetType:($TargetType) -TargetSearchByValue:($TargetSearchByValue) -TestMethod:($TestMethod) -TestMethodIdentifier:($TestMethodIdentifier)
                        }
                        Context ("When Association functions are called by piping parameters.") {
                            Test-AssociationCommand -ExecutionType:('Pipe') -Verb:('Add') -Source:($Source) -SourceId:($SourceId) -SourceType:($SourceType) -SourceSearchByValue:($SourceSearchByValue) -Target:($Target) -TargetId:($TargetId) -TargetType:($TargetType) -TargetSearchByValue:($TargetSearchByValue) -TestMethod:($TestMethod) -TestMethodIdentifier:($TestMethodIdentifier)
                            Test-AssociationCommand -ExecutionType:('Pipe') -Verb:('Get') -Source:($Source) -SourceId:($SourceId) -SourceType:($SourceType) -SourceSearchByValue:($SourceSearchByValue) -Target:($Target) -TargetId:($TargetId) -TargetType:($TargetType) -TargetSearchByValue:($TargetSearchByValue) -TestMethod:($TestMethod) -TestMethodIdentifier:($TestMethodIdentifier)
                            Test-AssociationCommand -ExecutionType:('Pipe') -Verb:('Remove') -Source:($Source) -SourceId:($SourceId) -SourceType:($SourceType) -SourceSearchByValue:($SourceSearchByValue) -Target:($Target) -TargetId:($TargetId) -TargetType:($TargetType) -TargetSearchByValue:($TargetSearchByValue) -TestMethod:($TestMethod) -TestMethodIdentifier:($TestMethodIdentifier)
                        }
                    }
                    Catch
                    {
                        Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($_) -NoNewScope
                    }
                    Finally
                    {
                        If ($ChangedOriginal)
                        {
                            # Get current associations and save them to be reapplied later
                            $AssociationsCurrentCommand = "Get-JCAssociation -Type:('$SourceType') -$TestMethodIdentifier`:('$SourceSearchByValue') -Direct; "
                            Write-Host ('Getting current Source associations: ' + $AssociationsCurrentCommand)
                            If ($Mock)
                            {
                                Write-Host ('[Mock]' + $AssociationsCurrentCommand)
                            }
                            Else
                            {
                                $Associations_GetCurrent = Invoke-Expression -Command:($AssociationsCurrentCommand)
                            }
                            If ($Associations_GetCurrent)
                            {
                                $AssociationsRemoveCurrentCommand = '$Associations_GetCurrent | Remove-JCAssociation -Force'
                                Write-Host ('Removing current Source associations: ' + $AssociationsRemoveCurrentCommand)
                                If ($Mock)
                                {
                                    Write-Host ('[Mock]' + $AssociationsRemoveCurrentCommand)
                                }
                                Else
                                {
                                    # $Associations_RemoveCurrent =
                                    Invoke-Expression -Command:($AssociationsRemoveCurrentCommand) | Out-Null
                                    # $Associations_RemoveCurrent | Format-Table
                                }
                            }
                            If ($AssociationsOriginal)
                            {
                                $AssociationsAddOriginalCommand = '$AssociationsOriginal | Add-JCAssociation -Force'
                                Write-Host ('Removing current Source associations: ' + $AssociationsAddOriginalCommand)
                                If ($Mock)
                                {
                                    Write-Host ('[Mock]' + $AssociationsAddOriginalCommand)
                                }
                                Else
                                {
                                    # $Associations_AddOriginal =
                                    Invoke-Expression -Command:($AssociationsAddOriginalCommand) | Out-Null
                                    # $CommandResults_AddOriginal | Format-Table
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}