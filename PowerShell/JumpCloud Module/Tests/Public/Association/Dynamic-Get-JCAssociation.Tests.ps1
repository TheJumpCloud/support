BeforeAll{
    # Generate possible variables
    # Test must be invoked by invoke pestter to load get-jcobject into memory
    $AssociationDataSet = @()
    $JCAssociationTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' }
    $EmptySources = @()
    ForEach ($JCAssociationType In $JCAssociationTypes) {
        $Source = Get-JCObject -Type:($JCAssociationType.TypeName.TypeNameSingular) | Select-Object -First 1 # | Get-Random
        If ($Source) {
            ForEach ($TargetSingular In $Source.Targets.TargetSingular) {
                If ( $TargetSingular -notin $EmptySources) {
                    $Target = Get-JCObject -Type:($TargetSingular) | Select-Object -First 1 # | Get-Random
                    If ($Target) {
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
                    Else {
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
        Else {
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
}
Describe -Tag:('JCAssociation') "Association Tests" {
    Context ('ID and Name Case Tests of Application Tests'){
        It '<testDescription' -TestCases @(
            @{
                testDescription = 'By Id: Application Associations Tests'
                TestSourceType  = ($AssociationDataSet | Where-Object SourceType -eq 'application')
                SourceID        = $TestSourceType.SourceId
                SourceName      = $null
                Source          = $null
                TargetType      = $null
                TargetId        = $null
                TargetName      = $null
                Target          = $null
                ValidRecord     = $null
            }
        ) {
            param (

            )
            # Print out AssociationDataSet of Current Test:
            Write-Host($TestSourceType)
            Write-Host($SourceId)
            $TargetId = $TestSourceType.TargetId
            $TargetType = $TestSourceType.TargetType

            # Begin Dynamic Test
            $Associations_Test = Add-JCAssociation -Type:($TestSourceType.SourceType) -Id:($TestSourceType.SourceId) -Force -TargetType:($TestSourceType.TargetType) -TargetId:($TestSourceType.TargetId); # [Mock-Tests]
            $Associations_Test = Get-JCAssociation -Type:($TestSourceType.SourceType) -Id:($TestSourceType.SourceId) -TargetType:($TestSourceType.TargetType); # [Mock-Tests]
            $Associations_Test = Get-JCAssociation -Type:($TestSourceType.SourceType) -Id:($TestSourceType.SourceId) -Raw -TargetType:($TestSourceType.TargetType); # [Mock-Tests]
            $Associations_Test = Get-JCAssociation -Type:($TestSourceType.SourceType) -Id:($TestSourceType.SourceId) -Direct -TargetType:($TestSourceType.TargetType); # [Mock-Tests]
            $Associations_Test = Get-JCAssociation -Type:($TestSourceType.SourceType) -Id:($TestSourceType.SourceId) -IncludeInfo -TargetType:($TestSourceType.TargetType); # [Mock-Tests]
            $Associations_Test = Get-JCAssociation -Type:($TestSourceType.SourceType) -Id:($TestSourceType.SourceId) -IncludeNames -TargetType:($TestSourceType.TargetType); # [Mock-Tests]
            $Associations_Test = Get-JCAssociation -Type:($TestSourceType.SourceType) -Id:($TestSourceType.SourceId) -IncludeVisualPath -TargetType:($TestSourceType.TargetType); # [Mock-Tests]
            $Associations_Test = Remove-JCAssociation -Type:($TestSourceType.SourceType) -Id:($TestSourceType.SourceId) -Force -TargetType:($TestSourceType.TargetType) -TargetId:($TestSourceType.TargetId); # [Mock-Tests]
            $Associations_Current = Get-JCAssociation -Type:($TestSourceType.SourceType) -Id:($TestSourceType.SourceId) -Direct # [Mock-Restore]
            if ($Associations_Current) {
                $Associations_Current | Remove-JCAssociation -Force; # [Mock-Restore]
            }
            $Associations_Test | Should -Not -BeNullOrEmpty
            ($Associations_Test | Measure-Object).Count | Should -BeGreaterThan 0
            $TargetId | Should -BeIn $Associations_Test.TargetId
            $TargetType | Should -BeIn $Associations_Test.TargetType
        }
    }
    Context -Skip ('ForEach Test of AssociationDataSet') {
        foreach ($Association in $AssociationDataSet) {
            It "$($Association.SourceName) Dynamic Test" -TestCases @{
                'TestCase' = $Association
                'SourceType'  = $Association.SourceType
                'SourceId'    = $Association.SourceId
                'SourceName'  = $Association.SourceName
                # 'Source'      = $Association
                'TargetType'  = $Association.TargetType
                'TargetId'    = $Association.TargetId
                'TargetName'  = $Association.TargetName
                # 'Target'      = $Target
                'ValidRecord' = $true
            } {
                Write-Host($TestCase)
                write-host($SourceType)
                #  | Should -BeOfType [int]
                $Associations_Original = Get-JCAssociation -Type:($SourceType) -Id:($SourceId) -Direct # [Mock-Backup]
                $Associations_Original | Remove-JCAssociation -Force; # [Mock-Backup]
                $Associations_Test = Add-JCAssociation -Type:($SourceType) -Id:($SourceId) -Force -TargetType:($TargetType) -TargetId:($TargetId); # [Mock-Tests]
                $Associations_Test = Get-JCAssociation -Type:($SourceType) -Id:($SourceId) -TargetType:($TargetType); # [Mock-Tests]
                $Associations_Test = Get-JCAssociation -Type:($SourceType) -Id:($SourceId) -Raw -TargetType:($TargetType); # [Mock-Tests]
                $Associations_Test = Get-JCAssociation -Type:($SourceType) -Id:($SourceId) -Direct -TargetType:($TargetType); # [Mock-Tests]
                $Associations_Test = Get-JCAssociation -Type:($SourceType) -Id:($SourceId) -IncludeInfo -TargetType:($TargetType); # [Mock-Tests]
                $Associations_Test = Get-JCAssociation -Type:($SourceType) -Id:($SourceId) -IncludeNames -TargetType:($TargetType); # [Mock-Tests]
                $Associations_Test = Get-JCAssociation -Type:($SourceType) -Id:($SourceId) -IncludeVisualPath -TargetType:($TargetType); # [Mock-Tests]
                $Associations_Test = Remove-JCAssociation -Type:($SourceType) -Id:($SourceId) -Force -TargetType:($TargetType) -TargetId:($TargetId); # [Mock-Tests]
                $Associations_Current = Get-JCAssociation -Type:($SourceType) -Id:($SourceId) -Direct # [Mock-Restore]
                if ($Associations_Current) {
                    $Associations_Current | Remove-JCAssociation -Force; # [Mock-Restore]
                }
                $Associations_Original | Add-JCAssociation -Force; # [Mock-Restore]
                # Define dynamic tests
                $Associations_Test | Should -Not -BeNullOrEmpty
                ($Associations_Test | Measure-Object).Count | Should -BeGreaterThan 0
                # $TargetId | Should -BeIn $TestCase.Id
                # $TargetType | Should -BeIn $TestCase.Type
            }
        }
    }
}
# AfterAll{

# }
# $Associations_Original = Get-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2') -Direct # [Mock-Backup]
# $Associations_Original | Remove-JCAssociation -Force; # [Mock-Backup]
# $Associations_Test = Add-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2') -Force -TargetType:('user_group') -TargetId:('5ee7a829232e11200a805f77'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2')  -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2') -Raw -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2') -Direct -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2') -IncludeInfo -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2') -IncludeNames -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2') -IncludeVisualPath -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Remove-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2') -Force -TargetType:('user_group') -TargetId:('5ee7a829232e11200a805f77'); # [Mock-Tests]
# $Associations_Current = Get-JCAssociation -Type:('application') -Id:('5c868a8e712cd916b1cd99d2') -Direct # [Mock-Restore]
# if ($Associations_Current){
#     $Associations_Current | Remove-JCAssociation -Force; # [Mock-Restore]
# }
# $Associations_Original | Add-JCAssociation -Force; # [Mock-Restore]
# #########################################################################################
# $Associations_Original = Get-JCAssociation -Type:('application') -Name:('DropBox') -Direct # [Mock-Backup]
# $Associations_Original | Remove-JCAssociation -Force; # [Mock-Backup]
# $Associations_Test = Add-JCAssociation -Type:('application') -Name:('DropBox') -Force -TargetType:('user_group') -TargetName:('PesterTest_UserGroup'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Name:('DropBox')  -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Name:('DropBox') -Raw -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Name:('DropBox') -Direct -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Name:('DropBox') -IncludeInfo -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Name:('DropBox') -IncludeNames -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Get-JCAssociation -Type:('application') -Name:('DropBox') -IncludeVisualPath -TargetType:('user_group'); # [Mock-Tests]
# $Associations_Test = Remove-JCAssociation -Type:('application') -Name:('DropBox') -Force -TargetType:('user_group') -TargetName:('PesterTest_UserGroup'); # [Mock-Tests]
# $Associations_Current = Get-JCAssociation -Type:('application') -Name:('DropBox') -Direct # [Mock-Restore]
# if ($Associations_Current){
#     $Associations_Current | Remove-JCAssociation -Force; # [Mock-Restore]
# }
# $Associations_Original | Add-JCAssociation -Force; # [Mock-Restore]
# #########################################################################################
# #variables
# $AssociationDataSet = @()
# $JCAssociationTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' }
# $EmptySources = @()
# ForEach ($JCAssociationType In $JCAssociationTypes)
# {
#     $Source = Get-JCObject -Type:($JCAssociationType.TypeName.TypeNameSingular) | Select-Object -First 1 # | Get-Random
#     If ($Source)
#     {
#         ForEach ($TargetSingular In $Source.Targets.TargetSingular)
#         {
#             If ( $TargetSingular -notin $EmptySources)
#             {
#                 $Target = Get-JCObject -Type:($TargetSingular) | Select-Object -First 1 # | Get-Random
#                 If ($Target)
#                 {
#                     $AssociationDataSet += [PSCustomObject]@{
#                         'SourceType'  = $Source.TypeName.TypeNameSingular;
#                         'SourceId'    = $Source.($Source.ById);
#                         'SourceName'  = $Source.($Source.ByName);
#                         'Source'      = $Source;
#                         'TargetType'  = $Target.TypeName.TypeNameSingular;
#                         'TargetId'    = $Target.($Target.ById);
#                         'TargetName'  = $Target.($Target.ByName);
#                         'Target'      = $Target;
#                         'ValidRecord' = $true;
#                     }
#                 }
#                 Else
#                 {
#                     $EmptySources += $TargetSingular
#                     $AssociationDataSet += [PSCustomObject]@{
#                         'SourceType'  = $Source.TypeName.TypeNameSingular;
#                         'SourceId'    = $Source.($Source.ById);
#                         'SourceName'  = $Source.($Source.ByName);
#                         'Source'      = $Source;
#                         'TargetType'  = $TargetSingular;
#                         'TargetId'    = $null;
#                         'TargetName'  = $null;
#                         'Target'      = $null;
#                         'ValidRecord' = $false;
#                     }
#                 }
#             }
#         }
#     }
#     Else
#     {
#         $EmptySources += $JCAssociationType.TypeName.TypeNameSingular
#         $JCAssociationType.Targets | ForEach-Object {
#             $AssociationDataSet += [PSCustomObject]@{
#                 'SourceType'  = $JCAssociationType.TypeName.TypeNameSingular
#                 'SourceId'    = $null
#                 'SourceName'  = $null
#                 'Source'      = $null
#                 'TargetType'  = $_.Targets.TargetSingular
#                 'TargetId'    = $null
#                 'TargetName'  = $null
#                 'Target'      = $null
#                 'ValidRecord' = $false
#             }
#         }
#     }
# }

# #Tests
# # It("Where properties returned '$($ExpectedColumns -join ", ")' should be '$($AssociationsProperties -join ", ")'") {
# #     $ExpectedColumns | Should -Be $AssociationsProperties
# # }
# # Direct or Indirect
# It("Where '$($Associations_Test.associationType)' match '$($ParameterName)'") {
#     $Associations_Test.associationType | Should -Be $ParameterName
# }
# It("Where '$($ParameterName)' match '$($Associations_Test.associationType)'") {
#     $ParameterName | Should -BeIn $Associations_Test.associationType
# }
# It("Where results should be not NullOrEmpty") { $Associations_Test | Should -Not -BeNullOrEmpty }
# It("Where results count should BeGreaterThan 0") { ($Associations_Test | Measure-Object).Count | Should -BeGreaterThan 0 }
# It("Where results TargetId '$($TargetId)' should be in '$($Associations_Test.Id -join ', ')'") { $TargetId | Should -BeIn $Associations_Test.Id }
# It("Where results TargetType '$($TargetType)' should be in '$($Associations_Test.Type -join ', ')'") { $TargetType | Should -BeIn $Associations_Test.Type }
# It("Where results action property '$($Verb)' should be '$($Associations_Test.Action | Select-Object -Unique)'") { $Verb | Should -Be ($Associations_Test.Action | Select-Object -Unique) }
# It("Where results SourceId '$($SourceId)' should be in '$($Associations_Test.Id -join ', ')'") { $SourceId | Should -BeIn $Associations_Test.Id }
# It("Where results SourceType '$($SourceType)' should be in '$($Associations_Test.Type -join ', ')'") { $SourceType | Should -BeIn $Associations_Test.Type }
# It("Where results TargetId '$($TargetId)' should be in '$($Associations_Test.TargetId -join ', ')'") { $TargetId | Should -BeIn $Associations_Test.TargetId }
# It("Where results TargetType '$($TargetType)' should be in '$($Associations_Test.TargetType -join ', ')'") { $TargetType | Should -BeIn $Associations_Test.TargetType }
# It("Where results SourceId '$($SourceId)' should not the same as the TargetId '$($TargetId)'") { $SourceId | Should -Not -Be $TargetId }
# It("Where results SourceType '$($SourceType)' should not the same as the TargetType '$($TargetType)'") { $SourceType | Should -Not -Be $TargetType }
# It("Where results SourceId '$($SourceId)' should not be in TargetId '$($Associations_Test.TargetId -join ', ')'") { $SourceId | Should -Not -BeIn $Associations_Test.TargetId }
# It("Where results SourceType '$($SourceType)' should not be in TargetType '$($Associations_Test.TargetType -join ', ')'") { $SourceType | Should -Not -BeIn $Associations_Test.TargetType }