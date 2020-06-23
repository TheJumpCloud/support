Describe -Tag:('JCAssociation') "Association Tests" {
    function Get-JCAssociations {
        # Generate possible associations
        $JCAssociationTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' } | Select-Object -First 2 # | Get-Random -Count 1 # remove when not testing
        $EmptySources = @()
        ForEach ($JCAssociationType In $JCAssociationTypes) {
            $Source = Get-JCObject -Type:($JCAssociationType.TypeName.TypeNameSingular) | Select-Object -First 1 # | Get-Random
            $AssociationDataSet = If ($Source) {
                ForEach ($TargetSingular In $Source.Targets.TargetSingular) {
                    If ( $TargetSingular -notin $EmptySources) {
                        $Target = Get-JCObject -Type:($TargetSingular) | Select-Object -First 1 # | Select-Object -First 1 # | Get-Random
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
        # Generate Test Cases
        $DataSet = Get-JCAssociations
        # Check that target id is set, only test with valid param set
        $ValidAssociationItems = $DataSet | Where-Object { $_.ValidRecord -and $_.SourceId -and $_.TargetId }
        $ValidAssociationItems = $ValidAssociationItems | Where-Object { $_.SourceType -ne 'active_directory' -and $_.TargetType -ne 'active_directory' }
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
        # Loop through both Id and Name hash tables
        $byNameOrID = @($byName, $byId)
        for ($i = 0; $i -lt $byNameOrID.Count; $i++) {
            # Loop through generated associaion objects from Get-JCAssocitaions
            $ValidAssociationItems | ForEach-Object {
                # $sourceParams = @{
                #         'SourceType'  = $_.Source.TypeName.TypeNameSingular;
                #         'SourceId'    = $_.Source.($_.Source.ById);
                #         'SourceName'  = $_.Source.($_.Source.ByName);
                #         'Source'      = $_.Source;
                #         'TargetType'  = $_.Target.TypeName.TypeNameSingular;
                #         'TargetId'    = $_.Target.($_.Target.ById);
                #         'TargetName'  = $_.Target.($_.Target.ByName);
                #         'Target'      = $_.Target;
                #         'ValidRecord' = $true;
                #     }
                # Either assign source and target vars by Name or Id
                if ($byNameOrID[$i].ByType -eq "Name"){
                    $SourceByType = $_.SourceName
                    $TargetByType = $_.TargetName
                }
                if ($byNameOrID[$i].ByType -eq "Id"){
                    $SourceByType = $_.SourceId
                    $TargetByType = $_.TargetId
                }
                $JCAssociationTestCases += @{
                    testDescription = 'Get Origional Associations By ' + ($byNameOrID[$i].ByType)
                    testType = "remove"
                    TestParam = $_
                    Commands = [ordered]@{
                        '0'    = "Get-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -Direct";
                    }
                }
                $JCAssociationTestCases += @{
                    testDescription = 'Add Associations By ' + ($byNameOrID[$i].ByType)
                    testType        = "Add"
                    TestParam       = $_
                    Commands        = [ordered]@{
                        '0' = "Add-JCAssociation -Type:('$($_.SourceType)') -$($byNameOrID[$i].SourceTarget):('$($SourceByType)') -Force -TargetType:('$($_.TargetType)') -$($byNameOrID[$i].DestTarget):('$($TargetByType)')";
                    }
                }
                $JCAssociationTestCases += @{
                    testDescription = 'Get Associations By ' + ($byNameOrID[$i].ByType)
                    testType        = "Get"
                    TestParam       = $_
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
                    testDescription = 'Remove Associations By ' + ($byNameOrID[$i].ByType)
                    testType = "Remove"
                    TestParam       = $_
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
            Write-Host("#### Test Name: " + $testDescription + " ####")
            foreach ($value in $Commands.values) {
                Write-Host("Command: " + $value)
                $Associations_Test = Invoke-Expression -Command:($value)
                if ($testType -eq "remove"){
                    Write-Host("ORIGIONAL COMMAND: " + $value)
                    if ($Associations_Test){
                        $Associations_Test | Remove-JCAssociation -Force
                        $testType | Should -Be ($Associations_Test.Action | Select-Object -Unique)
                    }
                    else {
                        Write-Host("No Association Found")
                        $Associations_Test | Should -Be $null
                    }
                }
                else {
                    Write-Host("Test Object" + $Associations_Test)
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
                        $testType | Should -Be ($Associations_Test.Action | Select-Object -Unique)
                    }
                }
            }
        }
    }
}