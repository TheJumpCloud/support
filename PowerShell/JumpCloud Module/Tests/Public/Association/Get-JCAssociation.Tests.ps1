BeforeDiscovery {
    function Get-JCAssociations {
        # Generate possible associations
        $JCAssociationTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' } # | Get-Random -Count 1 # remove when not testing
        $EmptySources = @()
        ForEach ($JCAssociationType In $JCAssociationTypes) {
            $Source = Get-JCObject -Type:($JCAssociationType.TypeName.TypeNameSingular) | Select-Object -First 1 # | Get-Random
            $AssociationDataSet = If ($Source) {
                ForEach ($TargetSingular In $Source.Targets.TargetSingular) {
                    If ( $TargetSingular -notin $EmptySources) {
                        $Target = Get-JCObject -Type:($TargetSingular) | Get-Random -Count 1 # | Select-Object -First 1 # | Get-Random
                        If ($Target) {
                            @{
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
                        } Else {
                            $EmptySources += $TargetSingular
                            @{
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
            } Else {
                $EmptySources += $JCAssociationType.TypeName.TypeNameSingular
                $JCAssociationType.Targets | ForEach-Object {
                    @{
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
        $ValidAssociationItems = $AssociationDataSet | Where-Object { $_.ValidRecord -and $_.SourceId -and $_.TargetId -and $_.TargetName }
        return $ValidAssociationItems
    }
    function Get-JCAssociationTestCases {
        # Generate Test Cases
        $DataSet = Get-JCAssociations
        # Check that target id is set, only test with valid param set
        $JCAssociationTestCases = @()
        # Tests by Name
        $byName = @{
            'ByType'       = "Name"
            'SourceTarget' = "Name"
            'DestTarget'   = "TargetName"
        }
        # Tests by Id
        $byId = @{
            'ByType'       = "Id"
            'SourceTarget' = "Id"
            'DestTarget'   = "TargetId"
        }
        # Loop through both Id and Name hash tables to generate byName and byID tests
        $ByNameOrID = @($byName, $byId)
        $ByNameOrID | ForEach-Object {
            # Scope $ByType loop variable
            $ByType = $_
            # Loop through generated associaion objects from Get-JCAssocitaions
            $DataSet | ForEach-Object {
                # Either assign source and target vars by Name or Id
                if ($ByType.ByType -eq "Name") {
                    $SourceByType = $_.SourceName
                    $TargetByType = $_.TargetName
                }
                if ($ByType.ByType -eq "Id") {
                    $SourceByType = $_.SourceId
                    $TargetByType = $_.TargetId
                }
                $JCAssociationTestCases += @{
                    TestDescription = 'Get/ Remove original Associations By ' + ($ByType.ByType )
                    TestType        = "original"
                    TestParam       = $_
                    Commands        = [ordered]@{
                        '0' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($ByType.SourceTarget):('$($SourceByType)') -Direct";
                    }
                }
                $JCAssociationTestCases += @{
                    TestDescription = 'Add Associations By ' + ($ByType.ByType)
                    TestType        = "add"
                    TestParam       = $_
                    Commands        = [ordered]@{
                        '0' = "Add-JCAssociation -Type:('$($_.SourceType)') -$($ByType.SourceTarget):('$($SourceByType)') -Force -TargetType:('$($_.TargetType)') -$($ByType.DestTarget):('$($TargetByType)')";
                    }
                }
                $JCAssociationTestCases += @{
                    TestDescription = 'Get Associations By ' + ($ByType.ByType)
                    TestType        = "get"
                    TestParam       = $_
                    Commands        = [ordered]@{
                        '0' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($ByType.SourceTarget):('$($SourceByType)') -TargetType:('$($_.TargetType)')";
                        '1' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($ByType.SourceTarget):('$($SourceByType)') -Raw -TargetType:('$($_.TargetType)')";
                        '2' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($ByType.SourceTarget):('$($SourceByType)') -Direct -TargetType:('$($_.TargetType)')";
                        '3' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($ByType.SourceTarget):('$($SourceByType)') -IncludeInfo -TargetType:('$($_.TargetType)')";
                        '4' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($ByType.SourceTarget):('$($SourceByType)') -IncludeNames -TargetType:('$($_.TargetType)')";
                        '5' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($ByType.SourceTarget):('$($SourceByType)') -IncludeVisualPath -TargetType:('$($_.TargetType)')";
                    }
                }
                $JCAssociationTestCases += @{
                    TestDescription = 'Remove Associations By ' + ($ByType.ByType)
                    TestType        = "remove"
                    TestParam       = $_
                    Commands        = [ordered]@{
                        '0' = "Remove-JCAssociation -Type:('$($_.SourceType)') -$($ByType.SourceTarget):('$($SourceByType)') -Force -TargetType:('$($_.TargetType)') -$($ByType.DestTarget):('$($TargetByType)')";
                    }
                }
            }
        }
        return $JCAssociationTestCases
    }
}
Describe -Tag:('JCAssociation') "Association Tests" {

    Context ('ID and Name Case Tests of Application Tests') {
        It '<TestDescription>' -TestCases:(Get-JCAssociationTestCases) {
            # Write-Host("#### Test Name: " + $TestDescription + " ####")
            foreach ($value in $Commands.values) {
                Write-Host("Command: " + $value)
                $Associations_Test = Invoke-Expression -Command:($value)
                if ($TestType -eq "original") {
                    Write-Host("original command: " + $value)
                    if ($Associations_Test) {
                        $Associations_Test = $Associations_Test | Remove-JCAssociation -Force
                        # Write-Host("Test action verb " + $TestType + " should be : " + $Associations_Test.Action)
                        "remove" | Should -Be ($Associations_Test.Action | Select-Object -Unique)
                    } else {
                        Write-Host("No Association Found")
                        $Associations_Test | Should -Be $null
                    }
                } else {
                    Write-Host("Test Object" + $Associations_Test)
                    $Associations_Test | Should -Not -BeNullOrEmpty
                    ($Associations_Test | Measure-Object).Count | Should -BeGreaterThan 0
                    If ($value -match '-Raw') {
                        $TestParam.TargetId | Should -BeIn $Associations_Test.Id
                        $TestParam.TargetType | Should -BeIn $Associations_Test.Type
                    } Else {
                        $TestParam.TargetId | Should -BeIn $Associations_Test.TargetId
                        $TestParam.TargetType | Should -BeIn $Associations_Test.TargetType
                        $TestParam.SourceId | Should -BeIn $Associations_Test.Id
                        $TestParam.SourceType | Should -BeIn $Associations_Test.Type
                        $TestParam.SourceId | Should -Not -Be $TargetId
                        $TestParam.SourceType | Should -Not -Be $TargetType
                        $TestParam.SourceId | Should -Not -BeIn $Associations_Test.TargetId
                        $TestParam.SourceType | Should -Not -BeIn $Associations_Test.TargetType
                        $TestType | Should -Be ($Associations_Test.Action | Select-Object -Unique)
                    }
                }
            }
        }
    }
}