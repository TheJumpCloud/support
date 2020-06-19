Describe -Tag:('JCAssociation') "Association Tests" {
    function Get-JCAssociations {
        # Generate possible variables
        $JCAssociationTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' } | Get-Random -Count 1 # remove when not testing
        $EmptySources = @()
        ForEach ($JCAssociationType In $JCAssociationTypes) {
            $Source = Get-JCObject -Type:($JCAssociationType.TypeName.TypeNameSingular) | Select-Object -First 1 # | Get-Random
            $AssociationDataSet = If ($Source) {
                ForEach ($TargetSingular In $Source.Targets.TargetSingular) {
                    If ( $TargetSingular -notin $EmptySources) {
                        $Target = Get-JCObject -Type:($TargetSingular) | Select-Object -First 1 # | Get-Random
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
                        }
                        Else {
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
            }
            Else {
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
        return $AssociationDataSet
    }
    function Get-JCAssociationTestCases {
        $DataSet = Get-JCAssociations
        $JCAssociationTestCases = @()
        $byName = @{
            'ByType'       = "Name"
            'SourceTarget' = "Name"
            'DestTarget'   = "TargetName"
        }
        $byId = @{
            'ByType'       = "Id"
            'SourceTarget' = "Id"
            'DestTarget'   = "TargetId"
        }
        $byNameOrID = @($byName, $byId)
        for ($i = 0; $i -lt $byNameOrID.Count; $i++) {
            $DataSet | ForEach-Object {
                $sourceParams = @{
                        'SourceType'  = $_.Source.TypeName.TypeNameSingular;
                        'SourceId'    = $_.Source.($_.Source.ById);
                        'SourceName'  = $_.Source.($_.Source.ByName);
                        'Source'      = $_.Source;
                        'TargetType'  = $_.Target.TypeName.TypeNameSingular;
                        'TargetId'    = $_.Target.($_.Target.ById);
                        'TargetName'  = $_.Target.($_.Target.ByName);
                        'Target'      = $_.Target;
                        'ValidRecord' = $true;
                    }
                if ($byNameOrID[$i].ByType -eq "Name"){
                    $SourceByType = $sourceParams.SourceName
                    $TargetByType = $sourceParams.TargetName
                }
                if ($byNameOrID[$i].ByType -eq "Id"){
                    $SourceByType = $sourceParams.SourceId
                    $TargetByType = $sourceParams.TargetId
                }
                $JCAssociationTestCases += @{
                    testDescription = 'Get Origional Associations By ' + ($byNameOrID[$i].ByType)
                    testType = "Get"
                    TestParam = $sourceParams
                    Commands = [ordered]@{
                        '0'    = "Get-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -Direct";
                    }
                }
                $JCAssociationTestCases += @{
                    testDescription = 'Add Some Associations By ' + ($byNameOrID[$i].ByType)
                    testType        = "Add"
                    TestParam       = $sourceParams
                    Commands        = [ordered]@{
                        '0' = "Add-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -Force -TargetType:('$($_.TargetType)') -$($byNameOrID[$i].DestTarget):('$($TargetByType)')";
                    }
                }
                $JCAssociationTestCases += @{
                    testDescription = 'Add Some Associations By ' + ($byNameOrID[$i].ByType)
                    testType        = "Add"
                    TestParam       = $sourceParams
                    Commands        = [ordered]@{
                        '0' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -TargetType:('$($_.TargetType)')";
                        '1' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -Raw -TargetType:('$($_.TargetType)')";
                        '2' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -Direct -TargetType:('$($_.TargetType)')";
                        '3' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -IncludeInfo -TargetType:('$($_.TargetType)')";
                        '4' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -IncludeNames -TargetType:('$($_.TargetType)')";
                        '5' = "Get-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -IncludeVisualPath -TargetType:('$($_.TargetType)')";
                    }
                }
                $JCAssociationTestCases += @{
                    testDescription = 'Remove Some Associations By ' + ($byNameOrID[$i].ByType)
                    testType = "Remove"
                    TestParam       = $sourceParams
                    Commands        = [ordered]@{
                        '0' = "Remove-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -Force -TargetType:('$($_.TargetType)') -$($byNameOrID[$i].DestTarget):('$($TargetByType)')";
                    }
                }
            }
            Write-Host("###################################")
        }
        return $JCAssociationTestCases
    }

    Context ('ID and Name Case Tests of Application Tests'){
        It '<testDescription>' -TestCases:(Get-JCAssociationTestCases) {
            # Write-Host("Test Name: " + $testDescription)
            foreach ($value in $Commands.values) {
                # Write-Host("Command: " + $value)
                $Associations_Test = Invoke-Expression -Command:($value)
                if ($testType -eq "Add"){
                    # Write-Host("Test Object" + $Associations_Test)
                    $Associations_Test | Should -Not -BeNullOrEmpty
                    ($Associations_Test | Measure-Object).Count | Should -BeGreaterThan 0
                    If ($value -match '-Raw') {
                        $TestParam.TargetId | Should -BeIn $Associations_Test.Id
                        $TestParam.TargetType | Should -BeIn $Associations_Test.Type
                    }
                    Else{
                        $TestParam.TargetId | Should -BeIn $Associations_Test.TargetId
                        $TestParam.TargetType | Should -BeIn $Associations_Test.TargetType
                        $TestParam.SourceId | Should -BeIn $Associations_Test.Id
                        $TestParam.SourceType | Should -BeIn $Associations_Test.Type
                        $TestParam.SourceId | Should -Not -Be $TargetId
                        $TestParam.SourceType | Should -Not -Be $TargetType
                        $TestParam.SourceId | Should -Not -BeIn $Associations_Test.TargetId
                        $TestParam.SourceType | Should -Not -BeIn $Associations_Test.TargetType
                    }
                }
            }
        }
    }
}