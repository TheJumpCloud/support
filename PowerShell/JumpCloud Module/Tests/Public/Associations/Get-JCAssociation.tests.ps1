Describe "Association Tests" {
    BeforeAll {
        # $DebugPreference = 'Continue'
        # $VerbosePreference = 'Continue'
        $ErrorActionPreference = 'Stop'
    }
    AfterAll {
        # $DebugPreference = 'SilentlyContinue'
        # $VerbosePreference = 'SilentlyContinue'
        $ErrorActionPreference = 'Continue'
    }
    # BeforeEach {}
    # AfterEach {}
    $TestMethods = ('ById', 'ByName')
    # Generate $Associations object records by looping through each association type and its target types
    Context ("Get each type of object association possible and build list of objects to test with") {
        $Associations = @()
        $JCAssociationTypes = Get-JCObjectType | Where-Object { $_.Category -eq 'JumpCloud' }
        ForEach ($JCAssociationType In $JCAssociationTypes)
        {
            $Type = $JCAssociationType.Singular
            $TargetTypes = $JCAssociationType.Targets
            ForEach ($TargetType In $TargetTypes)
            {
                $Object = Get-JCObject -Type:([string]$Type) | Select-Object -First 1 #| Get-Random
                $Id = $Object.($Object.ById)
                $Name = $Object.($Object.ByName)
                $Target = Get-JCObject -Type:([string]$TargetType) | Select-Object -First 1 #| Get-Random
                $TargetId = $Target.($Target.ById)
                $TargetName = $Target.($Target.ByName)
                $AssociationsRecord = [PSCustomObject]@{'Type' = $Type; 'Id' = $Id; 'Name' = $Name; 'TargetType' = $TargetType; 'TargetId' = $TargetId; 'TargetName' = $TargetName; }
                # Replace NULLs with UNKNOWN
                $AssociationsRecord.PSObject.Properties.name | ForEach-Object {If (!($AssociationsRecord.($_))) { $AssociationsRecord.($_) = 'UNKNOWN'; }}
                $Associations += $AssociationsRecord
            }
        }
        # Export data to file
        # ($Associations | ConvertTo-JSON) | Out-File -Path:($PSScriptRoot + '/Get-JCAssociation.Tests.BigOrg.json')
        # Import data for testing manually
        # $AssociationsContent = Get-Content -Raw -Path:($PSScriptRoot + '/Get-JCAssociation.Tests.BigOrg.json')
        # $Associations = $AssociationsContent | ConvertFrom-Json
        # Test to see if there are any UNKNOWN values found in the dataset
        It("Validate that all object types exist within the specified test environment.") {
            $Associations | Where-Object { $_.Id -eq 'UNKNOWN' } | Should -BeNullOrEmpty
            $Associations | Where-Object { $_.Name -eq 'UNKNOWN' } | Should -BeNullOrEmpty
            $Associations | Where-Object { $_.TargetId -eq 'UNKNOWN' } | Should -BeNullOrEmpty
            $Associations | Where-Object { $_.TargetName -eq 'UNKNOWN' } | Should -BeNullOrEmpty
        }
        If ($Associations | Where-Object { $_.Type -eq 'UNKNOWN' }) { Write-Error ("Need to create: $Type"); }
        If ($Associations | Where-Object { $_.TargetType -eq 'UNKNOWN' }) { Write-Error ("Need to create: $TargetType"); }
        If ($Associations | Where-Object { $_.Name -eq 'UNKNOWN' }) { Write-Error ("Need to create: $Name"); }
        If ($Associations | Where-Object { $_.TargetName -eq 'UNKNOWN' }) { Write-Error ("Need to create: $TargetName"); }
        If ($Associations | Where-Object { $_.Id -eq 'UNKNOWN' }) { Write-Error ("Need to create: $Id"); }
        If ($Associations | Where-Object { $_.TargetId -eq 'UNKNOWN' }) { Write-Error ("Need to create: $TargetId"); }
        # Filter out UNKNOWN's from the dataset
        $AssociationObject = $Associations | Where-Object { $_.Id -ne 'UNKNOWN' -and $_.Name -ne 'UNKNOWN' -and $_.TargetId -ne 'UNKNOWN' -and $_.TargetName -ne 'UNKNOWN' }
        # Start tests
        ForEach ($TestMethod In  $TestMethods)
        {
            $TestMethodIdentifier = $TestMethod.Replace('By', '')
            Context ("When Association functions are called with parameterSet: '$TestMethod'") {
                ForEach ($AssociationRecord In $AssociationObject)
                {
                    $SourceType = $AssociationRecord.Type
                    $SourceId = $AssociationRecord.Id
                    $SourceName = $AssociationRecord.Name
                    $SourceTargetType = $AssociationRecord.TargetType
                    $SourceTargetId = $AssociationRecord.TargetId
                    $SourceTargetName = $AssociationRecord.TargetName
                    Context ("Running Association tests for Type:'$SourceType';Name:'$SourceName';TargetType:'$SourceTargetType';TargetName:'$SourceTargetName';") {
                        Try
                        {
                            $ExistingAssociation = $false
                            $SourceSearchByValue = Switch ($TestMethod) { 'ById' { $SourceId }'ByName' { $SourceName } }
                            $SourceTargetSearchByValue = Switch ($TestMethod) { 'ById' { $SourceTargetId }'ByName' { $SourceTargetName } }
                            # Get Object
                            $Object = Get-JCObject -Type:($SourceType) -SearchBy:($TestMethod) -SearchByValue:($SourceSearchByValue);
                            It ("Test if Object exists by running: Get-JCObject -Type:('$SourceType') -SearchBy:('$TestMethod') -SearchByValue:('$SourceSearchByValue');") {
                                $Object | Should -Not -BeNullOrEmpty
                                $Object.($Object.($TestMethod)) | Should -Be $SourceSearchByValue
                            }
                            If (!($Object)) { Write-Error ('Object does not exist:' + $SourceType + ':' + $SourceSearchByValue); }
                            # Get Target
                            $Target = Get-JCObject -Type:($SourceTargetType) -SearchBy:($TestMethod) -SearchByValue:($SourceTargetSearchByValue);
                            It ("Test if Target exists by running: Get-JCObject -Type:('$SourceTargetType') -SearchBy:('$TestMethod') -SearchByValue:('$SourceTargetSearchByValue');") {
                                $Target | Should -Not -BeNullOrEmpty
                                $Target.($Target.($TestMethod)) | Should -Be $SourceTargetSearchByValue
                            }
                            If (!($Target)) { Write-Error ('Target does not exist:' + $SourceTargetType + ':' + $SourceTargetSearchByValue); }
                            # Get the Object and Target Id and Name
                            $Id = $Object.($Object.ById)
                            $Name = $Object.($Object.ByName)
                            $TargetId = $Target.($Target.ById)
                            $TargetName = $Target.($Target.ByName)
                            $SourceSearchByValue = Switch ($TestMethod) { 'ById' { $Id }'ByName' { $Name } }
                            $TargetSearchByValue = Switch ($TestMethod) { 'ById' { $TargetId }'ByName' { $TargetName } }
                            # Test if the association already exists between $Id and $TargetId
                            $GetJCAssociation = Switch ($TestMethod)
                            {
                                'ById' { Get-JCAssociation -Type:($SourceType) -Id:($Id) -TargetType:($SourceTargetType) | Where-Object { $_.TargetId -eq $TargetId }; }
                                'ByName' { Get-JCAssociation -Type:($SourceType) -Name:($Name) -TargetType:($SourceTargetType) | Where-Object { $_.TargetName -eq $TargetName }; }
                            }
                            #If the association exists
                            If ($GetJCAssociation)
                            {
                                $ExistingAssociation = $true
                                $GetJCAssociation_Id = $GetJCAssociation.Id
                                $GetJCAssociation_Name = $GetJCAssociation.Name
                                $GetJCAssociation_TargetId = $GetJCAssociation.TargetId
                                $GetJCAssociation_TargetName = $GetJCAssociation.TargetName
                                $GetJCAssociation_SourceSearchByValue = Switch ($TestMethod) { 'ById' { $GetJCAssociation_Id }'ByName' { $GetJCAssociation_Name } }
                                $GetJCAssociation_TargetSearchByValue = Switch ($TestMethod) { 'ById' { $GetJCAssociation_TargetId }'ByName' { $GetJCAssociation_TargetName } }
                                # Remove the association between $Id and $TargetId
                                It ("If the association exists then remove the association by running: Remove-JCAssociation -Type:('$SourceType') -$TestMethodIdentifier`:('$GetJCAssociation_SourceSearchByValue') -TargetType:('$SourceTargetType') -Target$TestMethodIdentifier`:('$GetJCAssociation_TargetSearchByValue');") {
                                    $Error.Clear()
                                    $RemoveAssociation = Switch ($TestMethod)
                                    {
                                        'ById' { Remove-JCAssociation -Type:($SourceType) -Id:($GetJCAssociation_Id) -TargetType:($SourceTargetType) -TargetId:($GetJCAssociation_TargetId); }
                                        'ByName' { Remove-JCAssociation -Type:($SourceType) -Name:($GetJCAssociation_Name) -TargetType:($SourceTargetType) -TargetName:($GetJCAssociation_TargetName); }
                                    }
                                    $Error.Count | Should -BeLessThan 1
                                    $RemoveAssociation | Should -BeNullOrEmpty
                                }
                            }
                            # Create new association between $Name and $TargetName
                            $NewAssociation = Switch ($TestMethod)
                            {
                                'ById' { New-JCAssociation -Type:($SourceType) -Id:($Id) -TargetType:($SourceTargetType) -TargetId:($TargetId); }
                                'ByName' { New-JCAssociation -Type:($SourceType) -Name:($Name) -TargetType:($SourceTargetType) -TargetName:($TargetName); }
                            }
                            It ("Create new association by running: New-JCAssociation -Type:('$SourceType') -$TestMethodIdentifier`:('$SourceSearchByValue') -TargetType:('$SourceTargetType') -Target$TestMethodIdentifier`:('$TargetSearchByValue');") {
                                $NewAssociation | Should -BeNullOrEmpty
                            }
                            # Validate that the new association has been created between $SourceSearchByValue and $TargetSearchByValue
                            $SourceToTargetAssociation = Get-JCAssociation -Type:($SourceType) -Name:($Name) -TargetType:($SourceTargetType) | Where-Object { $_.TargetName -eq $TargetName }
                            # Get the Object and Target Id and Name
                            $SourceToTargetAssociation_Id = $SourceToTargetAssociation.Id
                            $SourceToTargetAssociation_Name = $SourceToTargetAssociation.Name
                            $SourceToTargetAssociation_TargetId = $SourceToTargetAssociation.TargetId
                            $SourceToTargetAssociation_TargetName = $SourceToTargetAssociation.TargetName
                            $SourceToTargetAssociation_SourceSearchByValue = Switch ($TestMethod) { 'ById' { $SourceToTargetAssociation_Id }'ByName' { $SourceToTargetAssociation_Name } }
                            $SourceToTargetAssociation_TargetSearchByValue = Switch ($TestMethod) { 'ById' { $SourceToTargetAssociation_TargetId }'ByName' { $SourceToTargetAssociation_TargetName } }
                            It ("Validate that the new association has been created by running: Get-JCAssociation -Type:('$SourceType') -Name:('$Name') -TargetType:('$SourceTargetType') | Where-Object {`$_.TargetName -eq '$TargetName'};") {
                                $SourceToTargetAssociation | Should -Not -BeNullOrEmpty
                                $SourceToTargetAssociation_Name | Should -Be $Name
                                $SourceToTargetAssociation_TargetName | Should -Be $TargetName
                            }
                            If (!($SourceToTargetAssociation)) { Write-Error ("$SourceToTargetAssociation_SourceSearchByValue does not have an association with $SourceToTargetAssociation_TargetSearchByValue!"); }
                            # Test that Get-JCAssociation works
                            It ("Validate that the Get-JCAssociation returns associations for the Object and the Target by running: Get-JCAssociation -Type:('$SourceType') -$TestMethodIdentifier`:('$SourceToTargetAssociation_SourceSearchByValue') -TargetType:('$SourceTargetType');") {
                                $GetJCAssociationTest = Switch ($TestMethod)
                                {
                                    'ById' { Get-JCAssociation -Type:($SourceType) -Id:($SourceToTargetAssociation_Id) -TargetType:($SourceTargetType); }
                                    'ByName' { Get-JCAssociation -Type:($SourceType) -Name:($SourceToTargetAssociation_Name) -TargetType:($SourceTargetType); }
                                }
                                ($GetJCAssociationTest | Get-Member) | Where-Object {$_.Name -in ('TargetInfo', 'TargetName')} | Should -Not -BeNullOrEmpty
                                $GetJCAssociationTest | Should -Not -BeNullOrEmpty
                                ($GetJCAssociationTest.Name | Select-Object -Unique) | Should -Be $Name
                                ($GetJCAssociationTest.TargetName | Select-Object -Unique) | Should -Not -BeNullOrEmpty
                            }
                            # Test that Get-JCAssociation works with -HideTargetData
                            It ("Validate that the Get-JCAssociation returns associations for the Object but not the Target by running: Get-JCAssociation -Type:('$SourceType') -$TestMethodIdentifier`:('$SourceToTargetAssociation_SourceSearchByValue') -TargetType:('$SourceTargetType') -HideTargetData;") {
                                $GetJCAssociationTest = Switch ($TestMethod)
                                {
                                    'ById' { Get-JCAssociation -Type:($SourceType) -Id:($SourceToTargetAssociation_Id) -TargetType:($SourceTargetType) -HideTargetData; }
                                    'ByName' { Get-JCAssociation -Type:($SourceType) -Name:($SourceToTargetAssociation_Name) -TargetType:($SourceTargetType) -HideTargetData; }
                                }
                                $GetJCAssociationTest | Should -Not -BeNullOrEmpty
                                ($GetJCAssociationTest.Name | Select-Object -Unique) | Should -Be $Name
                                ($GetJCAssociationTest.TargetName | Select-Object -Unique) | Should -BeNullOrEmpty
                                ($GetJCAssociationTest | Get-Member) | Where-Object {$_.Name -in ('TargetInfo', 'TargetName')} | Should -BeNullOrEmpty
                            }
                            # Test that Get-JCAssociation works when you don't provide a name or id for items in the console that there is only 1 of
                            If ($SourceType -in ('ldap_server', 'g_suite', 'office_365'))
                            {
                                It ("Validate that the Get-JCAssociation returns associations when you don't provide a name or id for items that there is only 1 of: Get-JCAssociation -Type:('$SourceType') -TargetType:('$SourceTargetType');") {
                                    $GetJCAssociationTest = Switch ($TestMethod)
                                    {
                                        'ById' { Get-JCAssociation -Type:($SourceType) -TargetType:($SourceTargetType); }
                                        'ByName' { Get-JCAssociation -Type:($SourceType) -TargetType:($SourceTargetType); }
                                    }
                                    $GetJCAssociationTest | Should -Not -BeNullOrEmpty
                                    ($GetJCAssociationTest.Name | Select-Object -Unique).Count | Should -Be 1
                                    ($GetJCAssociationTest.Name | Select-Object -Unique) | Should -Be $Name
                                }
                            }
                            # Remove the association between $SourceSearchByValue and $TargetSearchByValue
                            $RemoveAssociation_Cleanup = Switch ($TestMethod)
                            {
                                'ById' { Remove-JCAssociation -Type:($SourceType) -Id:($SourceToTargetAssociation_Id) -TargetType:($SourceTargetType) -TargetId:($SourceToTargetAssociation_TargetId); }
                                'ByName' { Remove-JCAssociation -Type:($SourceType) -Name:($SourceToTargetAssociation_Name) -TargetType:($SourceTargetType) -TargetName:($SourceToTargetAssociation_TargetName); }
                            }
                            It ("If the association exists then remove the association by running: Remove-JCAssociation -Type:('$SourceType') -$TestMethodIdentifier`:('$SourceToTargetAssociation_SourceSearchByValue') -TargetType:('$SourceTargetType') -Target$TestMethodIdentifier`:('$SourceToTargetAssociation_TargetSearchByValue');") {
                                $RemoveAssociation_Cleanup | Should -BeNullOrEmpty
                            }
                            # Test to see that the Object does not have an association with the Target
                            $SourceToTargetDissociation = Switch ($TestMethod)
                            {
                                'ById' { Get-JCAssociation -Type:($SourceType) -Id:($SourceToTargetAssociation_Id) -TargetType:($SourceTargetType) | Where-Object { $_.TargetId -eq $SourceToTargetAssociation_TargetId }; }
                                'ByName' { Get-JCAssociation -Type:($SourceType) -Name:($SourceToTargetAssociation_Name) -TargetType:($SourceTargetType) | Where-Object { $_.TargetName -eq $SourceToTargetAssociation_TargetName }; }
                            }
                            It ("Validate that the association has been dissociated by running: Get-JCAssociation -Type:('$SourceType)' -$TestMethodIdentifier`:('$SourceToTargetAssociation_TargetSearchByValue') -TargetType:('$SourceTargetType') | Where-Object {`$_.Target$TestMethodIdentifier -eq '$SourceToTargetAssociation_TargetSearchByValue'};") {
                                $SourceToTargetDissociation | Should -BeNullOrEmpty
                            }
                        }
                        Catch
                        {
                            $Exception = $_.Exception
                            $Message = $Exception.Message
                            While ($Exception.InnerException)
                            {
                                $Exception = $Exception.InnerException
                                $Message += "`n" + $Exception.Message
                            }
                            Write-Error ($_.FullyQualifiedErrorId.ToString() + "`n" + $_.InvocationInfo.PositionMessage + "`n" + $Message)
                        }
                        Finally
                        {
                            # Set the environment back to how it was when script started
                            If ($ExistingAssociation)
                            {
                                # Add the association between $Id and $TargetId
                                $NewAssociation_Cleanup = Switch ($TestMethod)
                                {
                                    'ById' { New-JCAssociation -Type:($SourceType) -Id:($GetJCAssociation_Id) -TargetType:($SourceTargetType) -TargetId:($GetJCAssociation_TargetId); }
                                    'ByName' { New-JCAssociation -Type:($SourceType) -Name:($GetJCAssociation_Name) -TargetType:($SourceTargetType) -TargetName:($GetJCAssociation_TargetName); }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}