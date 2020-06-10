# NOTE TODO Add bespoke tests to validate the "-Indirect" parameter. Remove active_directory exclusion once bug has been fixed.
BeforeAll {
    # $DebugPreference = 'Continue' # SilentlyContinue (Default), Continue, Inquire, Stop
    # $VerbosePreference = 'Continue' # SilentlyContinue (Default), Continue, Inquire, Stop
    $ErrorActionPreference = 'Stop' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend
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
        $Template_Message = "$Template_FunctionName with '{1}' parameters by running: {2}"
        $FunctionName = ($Template_FunctionName -f $Verb)
        # Hash for validating switch statements return the expected properties
        $SwitchColumnHash = [ordered]@{
            ''                  = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'paths', 'httpMetaData', 'IsSuccessStatusCode', 'error');
            'Raw'               = @('id', 'type', 'paths'); # 'compiledAttributes',
            'Direct'            = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'paths', 'httpMetaData', 'IsSuccessStatusCode', 'error');
            # 'Indirect'          = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'paths', 'httpMetaData', 'IsSuccessStatusCode', 'error'); # 'compiledAttributes',
            'IncludeInfo'       = @('action', 'associationType', 'id', 'type', 'info', 'targetId', 'targetType', 'targetInfo', 'paths', 'httpMetaData', 'IsSuccessStatusCode', 'error'); # 'compiledAttributes',
            'IncludeNames'      = @('action', 'associationType', 'id', 'type', 'name', 'targetId', 'targetType', 'targetName', 'paths', 'httpMetaData', 'IsSuccessStatusCode', 'error'); # 'compiledAttributes',
            'IncludeVisualPath' = @('action', 'associationType', 'id', 'type', 'targetId', 'targetType', 'visualPathById', 'visualPathByName', 'visualPathByType', 'paths', 'httpMetaData', 'IsSuccessStatusCode', 'error'); # 'compiledAttributes',
        }
        # Build Get commands to test each switch
        $GetCommands = @()
        If ($Verb -eq 'Get')
        {
            # Build Get commands to test all switches
            $SwitchColumnHash.GetEnumerator() | ForEach-Object {
                $ParameterName = $_.Key
                $ParameterSwitchesString = If ($ParameterName) { '-' + ($ParameterName -join ' -') } Else { $ParameterName }
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
                'Add' { @(($Template_AllSourceParameters -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString, $TargetType, $TargetSearchByValue)) }
                'Get' { $GetCommands }
                'Remove' { @(($Template_AllSourceParameters -f $SourceType, $TestMethodIdentifier, $SourceSearchByValue, $ParameterSwitchesString, $TargetType, $TargetSearchByValue)) }
                Default { Write-Error ('Unknown $Verb:' + $Verb) }
            }
            $Associations_Test_Commands = $Associations_Test_Commands | ForEach-Object { $FunctionName + $_ }
        }
        ElseIf ($ExecutionType -eq 'Pipe')
        {
            $Associations_Test_Commands = Switch ($Verb)
            {
                'Add' { @(($Template_AllTargetParameters -f $TargetType, $ParameterSwitchesString, $TestMethodIdentifier, $TargetSearchByValue)) }
                'Get' { $GetCommands }
                'Remove' { @(($Template_AllTargetParameters -f $TargetType, $ParameterSwitchesString, $TestMethodIdentifier, $TargetSearchByValue)) }
                Default { Write-Error ('Unknown $Verb:' + $Verb) }
            }
            $Associations_Test_Commands = $Associations_Test_Commands | ForEach-Object { '$Source | ' + $FunctionName + $_ }
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
            $ItMessage = $Template_Message -f $Verb, $ExecutionType, $PrintCommand
            If ($Mock)
            {
                ('$Associations_Test = ' + $PrintCommand + ' # [Mock-Tests]' | Tee-Object -FilePath:($MockFilePath) -Append)
            }
            Else
            {
                $Associations_Test = Invoke-Expression -Command:($Associations_Test_Command)
            }
            # Run tests
            If (!($Mock))
            {
                Context ($ItMessage) {
                    # Test results of action
                    If ($Verb -eq 'Get')
                    {
                        $AssociationsProperties = ($Associations_Test | ForEach-Object { $_.PSObject.Properties.name } | Where-Object { $_ -ne 'compiledAttributes' } | Select-Object -Unique | Sort-Object)
                        $SwitchColumnHash.GetEnumerator() | ForEach-Object {
                            $ParameterName = $_.Key
                            $ExpectedColumns = $_.Value | Sort-Object
                            If ($Associations_Test_Command -match $ParameterName)
                            {
                                If ($ParameterName)
                                {
                                    It("Where properties returned '$($ExpectedColumns -join ", ")' should be '$($AssociationsProperties -join ", ")'") {
                                        $ExpectedColumns | Should -Be $AssociationsProperties
                                    }
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
                                }
                            }
                        }
                    }
                    It("Where results should be not NullOrEmpty") { $Associations_Test | Should -Not -BeNullOrEmpty }
                    It("Where results count should BeGreaterThan 0") { ($Associations_Test | Measure-Object).Count | Should -BeGreaterThan 0 }
                    If ($Associations_Test_Command -match '-Raw')
                    {
                        It("Where results TargetId '$($TargetId)' should be in '$($Associations_Test.Id -join ', ')'") { $TargetId | Should -BeIn $Associations_Test.Id }
                        It("Where results TargetType '$($TargetType)' should be in '$($Associations_Test.Type -join ', ')'") { $TargetType | Should -BeIn $Associations_Test.Type }
                    }
                    Else
                    {
                        It("Where results action property '$($Verb)' should be '$($Associations_Test.Action | Select-Object -Unique)'") { $Verb | Should -Be ($Associations_Test.Action | Select-Object -Unique) }
                        It("Where results SourceId '$($SourceId)' should be in '$($Associations_Test.Id -join ', ')'") { $SourceId | Should -BeIn $Associations_Test.Id }
                        It("Where results SourceType '$($SourceType)' should be in '$($Associations_Test.Type -join ', ')'") { $SourceType | Should -BeIn $Associations_Test.Type }
                        It("Where results TargetId '$($TargetId)' should be in '$($Associations_Test.TargetId -join ', ')'") { $TargetId | Should -BeIn $Associations_Test.TargetId }
                        It("Where results TargetType '$($TargetType)' should be in '$($Associations_Test.TargetType -join ', ')'") { $TargetType | Should -BeIn $Associations_Test.TargetType }
                        It("Where results SourceId '$($SourceId)' should not the same as the TargetId '$($TargetId)'") { $SourceId | Should -Not -Be $TargetId }
                        It("Where results SourceType '$($SourceType)' should not the same as the TargetType '$($TargetType)'") { $SourceType | Should -Not -Be $TargetType }
                        It("Where results SourceId '$($SourceId)' should not be in TargetId '$($Associations_Test.TargetId -join ', ')'") { $SourceId | Should -Not -BeIn $Associations_Test.TargetId }
                        It("Where results SourceType '$($SourceType)' should not be in TargetType '$($Associations_Test.TargetType -join ', ')'") { $SourceType | Should -Not -BeIn $Associations_Test.TargetType }
                    }
                }
            }
        }
    }
}
Describe -Tag:('JCAssociation') "Association Tests" {
    # BeforeEach {}
    # AfterEach {}
    # Define misc. variables
    # Remove mock file if exists
    If ($Mock) { If (Test-Path -Path:($MockFilePath)) { Remove-Item -Path:($MockFilePath) -Force } }
    # Generate $AssociationDataSet object records by looping through each association type and its target types
    Context ("Get each type of JC object association possible and build list of source and targets to test with.") {
        $AssociationDataSet = @()
        $JCAssociationTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' } | Get-Random -Count 1
        $EmptySources = @()
        ForEach ($JCAssociationType In $JCAssociationTypes)
        {
            $Source = Get-JCObject -Type:($JCAssociationType.TypeName.TypeNameSingular) | Select-Object -First 1 # | Get-Random
            If ($Source)
            {
                ForEach ($TargetSingular In $Source.Targets.TargetSingular)
                {
                    If ( $TargetSingular -notin $EmptySources)
                    {
                        $Target = Get-JCObject -Type:($TargetSingular) | Select-Object -First 1 # | Get-Random
                        If ($Target)
                        {
                            $AssociationDataSet += [PSCustomObject]@{
                                'SourceType'  = $Source.TypeName.TypeNameSingular;
                                'SourceId'    = $Source.($Source.ById);
                                'SourceName'  = $Source.($Source.ByName);
                                'Source'      = $Source;
                                'TargetType'  = $Target.TypeName.TypeNameSingular;
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
                                'SourceType'  = $Source.TypeName.TypeNameSingular;
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
                    $AssociationDataSet += [PSCustomObject]@{
                        'SourceType'  = $JCAssociationType.TypeName.TypeNameSingular
                        'SourceId'    = $null
                        'SourceName'  = $null
                        'Source'      = $null
                        'TargetType'  = $_.Targets.TargetSingular
                        'TargetId'    = $null
                        'TargetName'  = $null
                        'Target'      = $null
                        'ValidRecord' = $false
                    }
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
        $ValidAssociationItems = $AssociationDataSet | Where-Object { $_.ValidRecord -and $_.SourceId -and $_.TargetId }
        ################################################################################
        ################################## HACKS/TODO ########################################
        $ValidAssociationItems = $ValidAssociationItems | Where-Object { $_.SourceType -ne 'active_directory' -and $_.TargetType -ne 'active_directory' }
        ################################################################################
        ################################################################################
        # Get invalid association items
        $InvalidAssociationItems = $AssociationDataSet | Where-Object { -not $_.ValidRecord -and -not $_.SourceId -and -not $_.TargetId } |
        Select-Object @{Name = 'Status'; Expression = { 'No "' + $_.SourceType + '" found within org. Please create a "' + $_.SourceType + '"' } } -Unique
        # Validate that org has been fully populated
        It("Validate that all object types exist within the specified test environment.") {
            $InvalidAssociationItems | Should -BeNullOrEmpty
        }
        If ($InvalidAssociationItems) { Write-Error ($InvalidAssociationItems.Status -join ', '); }
        $ValidAssociationItemsCounter = 0
        $ValidAssociationItemsCount = ($ValidAssociationItems | Measure-Object).Count * ($TestMethods | Measure-Object).Count
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
                Context ("$ValidAssociationItemsCounter of $ValidAssociationItemsCount; When Association functions are called with parameterSet: '$TestMethod';SourceType:'$SourceType';SourceId:'$SourceId';SourceName:'$SourceName';TargetType:'$TargetType';TargetId:'$TargetId';TargetName:'$TargetName';") {
                    $TestMethodIdentifier = $TestMethod.Replace('By', '')
                    $SourceSearchByValue = Switch ($TestMethod) { 'ById' { $SourceId }'ByName' { $SourceName } }
                    $TargetSearchByValue = Switch ($TestMethod) { 'ById' { $TargetId }'ByName' { $TargetName } }
                    Try
                    {
                        #Region Backup original associations
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
                        #EndRegion Backup original associations
                        #Region Remove original associations
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
                                $Associations_RemoveOriginal = Invoke-Expression -Command:($Associations_RemoveOriginal_Command)
                                If ($Associations_RemoveOriginal)
                                {
                                    $ChangedOriginal = $true
                                }
                            }
                        }
                        #EndRegion Remove original associations
                        #Region Run associations tests
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
                        #EndRegion Run associations tests
                    }
                    Catch
                    {
                        Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($_, $true) -NoNewScope
                    }
                    Finally
                    {
                        If ($ChangedOriginal)
                        {
                            #Region Get current associations
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
                            #EndRegion Get current associations
                            #Region Remove current associations
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
                            #EndRegion Remove current associations
                            #Region Restore original associations
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
                            #EndRegion Restore original associations
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
# AfterAll {
# # $DebugPreference = 'SilentlyContinue' # SilentlyContinue (Default), Continue, Inquire, Stop
# # $VerbosePreference = 'SilentlyContinue' # SilentlyContinue (Default), Continue, Inquire, Stop
#     $ErrorActionPreference = 'Continue' # Continue (Default), Ignore, Inquire, SilentlyContinue, Stop, Suspend
# }