# NOTE TODO Add bespoke tests to validate the "-Indirect" parameter. Remove active_directory exclusion once bug has been fixed.
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
    $MockFilePath = $PSScriptRoot + '/MockCommands.ps1'
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
        # Hash for validating switch statements return the expected properties
        $SwitchColumnHash = [ordered]@{
            ''                  = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'paths');
            'Raw'               = @('id', 'type', 'paths'); # 'compiledAttributes',
            'Direct'            = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'paths');
            # 'Indirect'          = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'paths'); # 'compiledAttributes',
            'IncludeInfo'       = @('action', 'associationType', 'id', 'type', 'info', 'targetId', 'targetType', 'targetInfo', 'paths'); # 'compiledAttributes',
            'IncludeNames'      = @('action', 'associationType', 'id', 'type', 'name', 'targetId', 'targetType', 'targetName', 'paths'); # 'compiledAttributes',
            'IncludeVisualPath' = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'visualPathById', 'visualPathByName', 'visualPathByType', 'paths'); # 'compiledAttributes',
        }
        # Build Get commands to test each switch
        $GetCommands = @()
        If ($Verb -eq 'Get')
        {
            # Build Get commands to test all switches
            $SwitchColumnHash.GetEnumerator() | ForEach-Object {
                $ParameterName = $_.Key
                $ParameterSwitchesString = If ($ParameterName) {'-' + ($ParameterName -join ' -')} Else {$ParameterName}
                If ($ExecutionType -eq 'Full')
                {
                    $GetCommands += ($Template_SourceParameters_TargetType -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString, $TargetType)
                    $GetCommands += ($Template_SourceParameters -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString)
                }
                ElseIf ($ExecutionType -eq 'Pipe')
                {
                    $GetCommands += ($Template_TargetParameters_TargetType -f $TargetType, $ParameterSwitchesString)
                    $GetCommands += (' ' + $ParameterSwitchesString)
                }
                Else
                {
                    Write-Error ('Unknown -ExecutionType:' + $ExecutionType)
                }
            }
        }
        Else
        {
            $ParameterSwitchesString = '-Force'
        }
        # Build command
        If ($ExecutionType -eq 'Full')
        {
            $Associations_Test_Commands = Switch ($Verb)
            {
                'Add' {@(($Template_AllSourceParameters -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString, $TargetType, $TargetSearchByValue))}
                'Get' {$GetCommands}
                'Remove' {@(($Template_AllSourceParameters -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString, $TargetType, $TargetSearchByValue))}
                Default {Write-Error ('Unknown $Verb:' + $Verb)}
            }
            $Associations_Test_Commands = $Associations_Test_Commands | ForEach-Object {$FunctionName + $_}
        }
        ElseIf ($ExecutionType -eq 'Pipe')
        {
            $Associations_Test_Commands = Switch ($Verb)
            {
                'Add' {@(($Template_AllTargetParameters -f $TargetType, $ParameterSwitchesString, $TestMethodIdentifier, $TargetSearchByValue))}
                'Get' {$GetCommands}
                'Remove' {@(($Template_AllTargetParameters -f $TargetType, $ParameterSwitchesString, $TestMethodIdentifier, $TargetSearchByValue))}
                Default {Write-Error ('Unknown $Verb:' + $Verb)}
            }
            $Associations_Test_Commands = $Associations_Test_Commands | ForEach-Object {'$Source | ' + $FunctionName + $_}
        }
        Else
        {
            Write-Error ('Unknown -ExecutionType:' + $ExecutionType)
        }
        # Run command
        ForEach ($Associations_Test_Command In $Associations_Test_Commands)
        {
            $Associations_Test_Command = $Associations_Test_Command.Trim() + ';'
            $PrintCommand = $Associations_Test_Command.Replace('$Source', "Get-JCObject -Type:('$SourceType') -$TestMethodIdentifier`:('$SourceSearchByValue')")
            $ItMessage = $Template_Message -f $Verb, $PrintCommand
            If ($Mock)
            {
                ('$Associations_Test = ' + $PrintCommand + ' # [Mock-Tests]' | Tee-Object -FilePath:($MockFilePath) -Append)
            }
            Else
            {
                $Associations_Test = Invoke-Expression -Command:($Associations_Test_Command)
            }
            # Run tests
            Context ($ItMessage) {
                # Test results of action
                $Associations_Validation_Command = If ($Associations_Test_Command -match '-Direct' -and $Associations_Test_Command -match '-Indirect')
                {
                    '$Associations_Test | Get-JCAssociation -Direct -Indirect'
                }
                ElseIf ($Associations_Test_Command -match '-Direct')
                {
                    '$Associations_Test | Get-JCAssociation -Direct'
                }
                ElseIf ($Associations_Test_Command -match '-Indirect')
                {
                    '$Associations_Test | Get-JCAssociation -Indirect'
                }
                Else
                {
                    '$Associations_Test | Get-JCAssociation'
                }

                If ($Mock)
                {
                    If ($Associations_Test_Command -notmatch '-Raw')
                    {
                        ($Associations_Validation_Command + ' # [Mock-Validation]') | Tee-Object -FilePath:($MockFilePath) -Append
                    }
                }
                Else
                {
                    If ($Verb -eq 'Get')
                    {
                        $AssociationsProperties = ($Associations_Test | ForEach-Object {$_.PSObject.Properties.name} | Where-Object {$_ -ne 'compiledAttributes'} | Select-Object -Unique | Sort-Object)
                        $SwitchColumnHash.GetEnumerator() | ForEach-Object {
                            $ParameterName = $_.Key
                            $ExpectedColumns = $_.Value | Sort-Object
                            If ($Associations_Test_Command -match $ParameterName)
                            {
                                If ($ParameterName)
                                {
                                    If ($ParameterName -in ('Direct')) #, 'Indirect'
                                    {
                                        If ($TestMethod -eq 'ById')
                                        {
                                            It("Where '$($Associations_Test.associationType)' match '$($ParameterName)'") {
                                                $Associations_Test.associationType | Should -Be $ParameterName
                                            }
                                        }
                                        ElseIf ($TestMethod -eq 'ByName')
                                        {
                                            It("Where '$($ParameterName)' match '$($Associations_Test.associationType)'") {
                                                $ParameterName | Should -BeIn $Associations_Test.associationType
                                            }
                                        }
                                        Else
                                        {
                                            Write-Error ('Unknown')
                                        }
                                    }
                                    It("Where '$($ExpectedColumns -join ", ")' should be '$($AssociationsProperties -join ", ")'") {
                                        $ExpectedColumns | Should -Be $AssociationsProperties
                                    }
                                }
                            }
                        }
                    }
                    It("Where results should be not NullOrEmpty") {$Associations_Test | Should -Not -BeNullOrEmpty}
                    It("Where results count should BeGreaterThan 0") {$Associations_Test.Count | Should -BeGreaterThan 0}
                    If ($Associations_Test_Command -match '-Raw')
                    {
                        It("Where results TargetId '$($TargetId)' should be in '$($Associations_Test.Id -join ', ')'") {$TargetId | Should -BeIn $Associations_Test.Id}
                        It("Where results TargetType '$($TargetType)' should be in '$($Associations_Test.Type -join ', ')'") {$TargetType | Should -BeIn $Associations_Test.Type}
                    }
                    Else
                    {
                        It("Where results action property '$($Verb)' should be '$($Associations_Test.Action | Select-Object -Unique)'") {$Verb | Should -Be ($Associations_Test.Action | Select-Object -Unique)}
                        It("Where results SourceId '$($SourceId)' should be in '$($Associations_Test.Id -join ', ')'") {$SourceId | Should -BeIn $Associations_Test.Id}
                        It("Where results SourceType '$($SourceType)' should be in '$($Associations_Test.Type -join ', ')'") {$SourceType | Should -BeIn $Associations_Test.Type}
                        It("Where results TargetId '$($TargetId)' should be in '$($Associations_Test.TargetId -join ', ')'") {$TargetId | Should -BeIn $Associations_Test.TargetId}
                        It("Where results TargetType '$($TargetType)' should be in '$($Associations_Test.TargetType -join ', ')'") {$TargetType | Should -BeIn $Associations_Test.TargetType}
                        If ($Verb -in ('Add', 'Remove'))
                        {
                            # Get the associations
                            $Associations_Validation = Invoke-Expression -Command:($Associations_Validation_Command)
                            # Test that the change was applied
                            If ($Verb -eq 'Remove')
                            {
                                It("Where results validation should be NullOrEmpty") {$Associations_Validation | Should -BeNullOrEmpty}
                                It("Where results validation Id '$($Associations_Validation.Id -join ', ')' should be NullOrEmpty") {$Associations_Validation.Id | Should -BeNullOrEmpty $SourceId}
                                It("Where results validation Type '$($Associations_Validation.Type -join ', ')' should be NullOrEmpty") {$Associations_Validation.Type | Should -BeNullOrEmpty $SourceType}
                                It("Where results validation TargetId '$($Associations_Validation.TargetId -join ', ')' should be NullOrEmpty") {$Associations_Validation.TargetId | Should -BeNullOrEmpty $TargetId}
                                It("Where results validation TargetType '$($Associations_Validation.TargetType -join ', ')' should be NullOrEmpty") {$Associations_Validation.TargetType | Should -BeNullOrEmpty $TargetType}
                                It("Where results validation count should be 0") {$Associations_Validation.Count | Should -Be 0}
                            }
                            Else
                            {
                                It("Where results validation should be not NullOrEmpty") {$Associations_Validation | Should -Not -BeNullOrEmpty}
                                It("Where results validation count should BeGreaterThan 0") {$Associations_Validation.Count | Should -BeGreaterThan 0}
                                It("Where results validation count should be '$($Associations_Test.Count)'") {$Associations_Validation.Count | Should -Be $Associations_Test.Count}
                                If ($TestMethod -eq 'ById')
                                {
                                    It("Where results validation SourceId '$($Associations_Validation.Id -join ', ')' should be '$($SourceId)'") {$Associations_Validation.Id | Should -Be $SourceId}
                                    It("Where results validation SourceType '$($Associations_Validation.Type -join ', ')' should be '$($SourceType)'") {$Associations_Validation.Type | Should -Be $SourceType}
                                    It("Where results validation TargetId '$($Associations_Validation.TargetId -join ', ')' should be '$($TargetId)'") {$Associations_Validation.TargetId | Should -Be $TargetId}
                                    It("Where results validation TargetType '$($Associations_Validation.TargetType -join ', ')' should be '$($TargetType)'") {$Associations_Validation.TargetType | Should -Be $TargetType}
                                }
                                ElseIf ($TestMethod -eq 'ByName')
                                {
                                    It("Where results validation SourceId '$($SourceId)' should be in '$($Associations_Validation.Id -join ', ')'") {$SourceId | Should -BeIn $Associations_Validation.Id}
                                    It("Where results validation SourceType '$($SourceType)' should be in '$($Associations_Validation.Type -join ', ')'") {$SourceType| Should -BeIn $Associations_Validation.Type }
                                    It("Where results validation TargetId '$($TargetId)' should be in '$($Associations_Validation.TargetId -join ', ')'") {$TargetId | Should -BeIn $Associations_Validation.TargetId}
                                    It("Where results validation TargetType '$($TargetType)' should be in '$($Associations_Validation.TargetType -join ', ')'") {$TargetType | Should -BeIn $Associations_Validation.TargetType}
                                }
                                Else
                                {
                                    Write-Error ('Unknown')
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    # Remove mock file if exists
    If ($Mock) {If (Test-Path -Path:($MockFilePath)) {Remove-Item -Path:($MockFilePath) -Force}}
    # Generate $AssociationDataSet object records by looping through each association type and its target types
    Context ("Get each type of JC object association possible and build list of source and targets to test with.") {
        $AssociationDataSet = @()
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
                            $AssociationDataSet += [PSCustomObject]@{
                                'SourceType'  = $Source.TypeNameSingular;
                                'SourceId'    = $Source.($Source.ById);
                                'SourceName'  = $Source.($Source.ByName);
                                'Source'      = $Source;
                                'TargetType'  = $Target.TypeNameSingular;
                                'TargetId'    = $Target.($Target.ById);
                                'TargetName'  = $Target.($Target.ByName);
                                'Target'      = $Target;
                                'ValidRecord' = $true;
                            }
                        }
                        Else
                        {
                            $EmptySources += $TargetSingular
                            $AssociationDataSet += [PSCustomObject]@{
                                'SourceType'  = $Source.TypeNameSingular;
                                'SourceId'    = $Source.($Source.ById);
                                'SourceName'  = $Source.($Source.ByName);
                                'Source'      = $Source;
                                'TargetType'  = $TargetSingular;
                                'TargetId'    = $null;
                                'TargetName'  = $null;
                                'Target'      = $null;
                                'ValidRecord' = $false;
                            }
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
        # ($AssociationDataSet | ConvertTo-JSON -Depth:(100)) | Out-File -Path:($PSScriptRoot + '/Get-JCAssociation.Tests.BigOrg.json') -Force
        # Import data for testing manually
        # $AssociationDataSetContent = Get-Content -Raw -Path:($PSScriptRoot + '/Get-JCAssociation.Tests.BigOrg.json')
        # $AssociationDataSet = $AssociationDataSetContent | ConvertFrom-Json
        ####################################################################################################
        # Get valid association items
        $ValidAssociationItems = $AssociationDataSet | Where-Object {$_.ValidRecord -and $_.SourceId -and $_.TargetId}
        ################################################################################
        ################################## HACKS/TODO ########################################
        $ValidAssociationItems = $ValidAssociationItems | Where-Object {$_.SourceType -ne 'active_directory' -and $_.TargetType -ne 'active_directory'}
        ################################################################################
        ################################################################################
        # Get invalid association items
        $InvalidAssociationItems = $AssociationDataSet | Where-Object {-not $_.ValidRecord -and -not $_.SourceId -and -not $_.TargetId} |
            Select-Object @{Name = 'Status'; Expression = {'No "' + $_.SourceType + '" found within org. Please create a "' + $_.SourceType + '"'}} -Unique
        # Validate that org has been fully populated
        It("Validate that all object types exist within the specified test environment.") {
            $InvalidAssociationItems | Should -BeNullOrEmpty
        }
        If ($InvalidAssociationItems) { Write-Error ($InvalidAssociationItems.Status -join ', '); }
        $ValidAssociationItemsCounter = 0
        $ValidAssociationItemsCount = $ValidAssociationItems.Count * $TestMethods.Count
        # Using dataset run tests
        ForEach ($AssociationItem In $ValidAssociationItems)
        {
            $Source = $AssociationItem.Source
            $SourceType = $AssociationItem.SourceType
            $SourceId = $AssociationItem.SourceId
            $SourceName = $AssociationItem.SourceName
            $Target = $AssociationItem.Target
            $TargetType = $AssociationItem.TargetType
            $TargetId = $AssociationItem.TargetId
            $TargetName = $AssociationItem.TargetName
            # Start test for each test method
            ForEach ($TestMethod In $TestMethods)
            {
                $ValidAssociationItemsCounter += 1
                Context ("$ValidAssociationItemsCounter of $ValidAssociationItemsCount; When Association functions are called with parameterSet: '$TestMethod';SourceType:'$SourceType';SourceId:'$SourceId';SourceName:$SourceName';TargetType:$TargetType';TargetId:$TargetId';TargetName:$TargetName';") {
                    $TestMethodIdentifier = $TestMethod.Replace('By', '')
                    $SourceSearchByValue = Switch ($TestMethod) { 'ById' { $SourceId }'ByName' { $SourceName } }
                    $TargetSearchByValue = Switch ($TestMethod) { 'ById' { $TargetId }'ByName' { $TargetName } }
                    Try
                    {
                        # Get current associations and save them to be reapplied later
                        $Associations_Original_Command = "Get-JCAssociation -Type:('$SourceType') -$TestMethodIdentifier`:('$SourceSearchByValue') -Direct"
                        If ($Mock)
                        {
                            ('$Associations_Original = ' + $Associations_Original_Command + ' # [Mock-Backup]') | Tee-Object -FilePath:($MockFilePath) -Append
                        }
                        Else
                        {
                            Write-Host ('Backing up Source associations: ' + $Associations_Original_Command)
                            $Associations_Original = Invoke-Expression -Command:($Associations_Original_Command)
                        }
                        # Remove current associations
                        $ChangedOriginal = $false
                        If ($Associations_Original -or $Mock)
                        {
                            $Associations_RemoveOriginal_Command = '$Associations_Original | Remove-JCAssociation -Force;'
                            If ($Mock)
                            {
                                ($Associations_RemoveOriginal_Command + ' # [Mock-Backup]') | Tee-Object -FilePath:($MockFilePath) -Append
                                $ChangedOriginal = $true
                            }
                            Else
                            {
                                Write-Host ('Removing Source associations: ' + $Associations_RemoveOriginal_Command)
                                $Associations_RemoveOriginal = Invoke-Expression -Command:($Associations_RemoveOriginal_Command) | Out-Null
                                If ($Associations_RemoveOriginal)
                                {
                                    $ChangedOriginal = $true
                                }
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
                            $Associations_Current_Command = "Get-JCAssociation -Type:('$SourceType') -$TestMethodIdentifier`:('$SourceSearchByValue') -Direct"
                            If ($Mock)
                            {
                                ('$Associations_Current = ' + $Associations_Current_Command + ' # [Mock-Restore]') | Tee-Object -FilePath:($MockFilePath) -Append
                            }
                            Else
                            {
                                Write-Host ('Getting current Source associations: ' + $Associations_Current_Command)
                                $Associations_Current = Invoke-Expression -Command:($Associations_Current_Command)
                            }
                            # Remove all existing associations
                            If ($Associations_Current -or $Mock)
                            {
                                $Associations_RemoveCurrent_Command = '$Associations_Current | Remove-JCAssociation -Force;'
                                If ($Mock)
                                {
                                    ($Associations_RemoveCurrent_Command + ' # [Mock-Restore]') | Tee-Object -FilePath:($MockFilePath) -Append
                                }
                                Else
                                {
                                    Write-Host ('Removing current Source associations: ' + $Associations_RemoveCurrent_Command)
                                    $Associations_RemoveCurrent = Invoke-Expression -Command:($Associations_RemoveCurrent_Command)
                                }
                            }
                            # Add the original associations back
                            If ($Associations_Original -or $Mock)
                            {
                                $Associations_AddOriginal_Command = '$Associations_Original | Add-JCAssociation -Force;'
                                If ($Mock)
                                {
                                    ($Associations_AddOriginal_Command + ' # [Mock-Restore]') | Tee-Object -FilePath:($MockFilePath) -Append
                                }
                                Else
                                {
                                    Write-Host ('Adding back original Source associations: ' + $Associations_AddOriginal_Command)
                                    $Associations_AddOriginal = Invoke-Expression -Command:($Associations_AddOriginal_Command)
                                }
                            }
                            # Add separating line for output
                            If ($Mock)
                            {
                                ('#########################################################################################') | Tee-Object -FilePath:($MockFilePath) -Append
                            }
                        }
                    }
                }
            }
        }
    }
}