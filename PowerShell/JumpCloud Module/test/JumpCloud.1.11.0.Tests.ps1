# Generic Test
$SingleAdminAPIKey = ''
Describe "Connect-JCOnline" {
    It "Connects to JumpCloud with a single admin API Key using force" {
        $Connect = Connect-JCOnline -JumpCloudAPIKey "$SingleAdminAPIKey" -force
        $Connect | Should -BeNullOrEmpty
    }
}
Describe "Association Tests" {
    # NOTE: To run these test manually comment out the line starting with "$Associations += [PSCustomObject]@{" and uncomment the line starting with "Write-Host ('$Associations' + " += [PSCustomObject]@{".
    # Then run the ForEach loop "ForEach ($JCAssociationType In $JCAssociationTypes)" manually.
    # Copy and paste the results from the output just after the ForEach loop previously mentioned and comment out the ForEach loop.
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
        $JCAssociationTypes = Get-JCObjectType | Where-Object {$_.Category -eq 'JumpCloud'}
        ForEach ($JCAssociationType In $JCAssociationTypes)
        {
            $InputObjectType = $JCAssociationType.Plural
            $TargetObjectTypes = $JCAssociationType.Targets
            ForEach ($TargetObjectType In $TargetObjectTypes)
            {
                $InputObject = Get-JCObject -Type:([string]$InputObjectType) | Get-Random #| Select-Object -First 1
                $InputObjectId = $InputObject.($InputObject.ById)
                $InputObjectName = $InputObject.($InputObject.ByName)
                $TargetObject = Get-JCObject -Type:([string]$TargetObjectType) | Get-Random #| Select-Object -First 1
                $TargetObjectId = $TargetObject.($TargetObject.ById)
                $TargetObjectName = $TargetObject.($TargetObject.ByName)
                If (!($InputObjectName)) {$InputObjectName = 'UNKNOWN'; }
                If (!($TargetObjectName)) {$TargetObjectName = 'UNKNOWN'; }
                If (!($InputObjectType)) {$InputObjectType = 'UNKNOWN'; }
                If (!($InputObjectId)) {$InputObjectId = 'UNKNOWN'; }
                If (!($TargetObjectType)) {$TargetObjectType = 'UNKNOWN'; }
                If (!($TargetObjectId)) {$TargetObjectId = 'UNKNOWN'; }
                # Write-Host ('$Associations' + " += [PSCustomObject]@{'InputObjectType' = '$InputObjectType'; 'InputObjectId' = '$InputObjectId'; 'InputObjectName' = '$InputObjectName'; 'TargetObjectType' = '$TargetObjectType'; 'TargetObjectId' = '$TargetObjectId'; 'TargetObjectName' = '$TargetObjectName'; }")
                # Write-Host ("$InputObjectType`t$InputObjectId`t$InputObjectName`t$TargetObjectType`t$TargetObjectId`t$TargetObjectName")
                $Associations += [PSCustomObject]@{'InputObjectType' = $InputObjectType; 'InputObjectId' = $InputObjectId; 'InputObjectName' = $InputObjectName; 'TargetObjectType' = $TargetObjectType; 'TargetObjectId' = $TargetObjectId; 'TargetObjectName' = $TargetObjectName; }
            }
        }
        # Test to see if there are any UNKNOWN values found in the dataset
        It("Validate that all object types exist within the specified test environment.") {
            $Associations | Where-Object {$_.InputObjectId -eq 'UNKNOWN'} | Should -BeNullOrEmpty
            $Associations | Where-Object {$_.InputObjectName -eq 'UNKNOWN'} | Should -BeNullOrEmpty
            $Associations | Where-Object {$_.TargetObjectId -eq 'UNKNOWN'} | Should -BeNullOrEmpty
            $Associations | Where-Object {$_.TargetObjectName -eq 'UNKNOWN'} | Should -BeNullOrEmpty
        }
        If ($Associations | Where-Object {$_.InputObjectType -eq 'UNKNOWN'}) {Write-Error ("Need to create: $InputObjectType"); }
        If ($Associations | Where-Object {$_.TargetObjectType -eq 'UNKNOWN'}) {Write-Error ("Need to create: $TargetObjectType"); }
        If ($Associations | Where-Object {$_.InputObjectName -eq 'UNKNOWN'}) {Write-Error ("Need to create: $InputObjectName"); }
        If ($Associations | Where-Object {$_.TargetObjectName -eq 'UNKNOWN'}) {Write-Error ("Need to create: $TargetObjectName"); }
        If ($Associations | Where-Object {$_.InputObjectId -eq 'UNKNOWN'}) {Write-Error ("Need to create: $InputObjectId"); }
        If ($Associations | Where-Object {$_.TargetObjectId -eq 'UNKNOWN'}) {Write-Error ("Need to create: $TargetObjectId"); }
        # Filter out UNKNOWN's from the dataset
        $AssociationObject = $Associations | Where-Object {$_.InputObjectId -ne 'UNKNOWN' -and $_.InputObjectName -ne 'UNKNOWN' -and $_.TargetObjectId -ne 'UNKNOWN' -and $_.TargetObjectName -ne 'UNKNOWN'}
        # Start tests
        ForEach ($TestMethod In  $TestMethods)
        {
            $TestMethodIdentifier = $TestMethod.Replace('By', '')
            Context ("When Association functions are called with parameterSet: '$TestMethod'") {
                ForEach ($AssociationRecord In $AssociationObject)
                {
                    $SourceInputObjectType = $AssociationRecord.InputObjectType
                    $SourceInputObjectId = $AssociationRecord.InputObjectId
                    $SourceInputObjectName = $AssociationRecord.InputObjectName
                    $SourceTargetObjectType = $AssociationRecord.TargetObjectType
                    $SourceTargetObjectId = $AssociationRecord.TargetObjectId
                    $SourceTargetObjectName = $AssociationRecord.TargetObjectName
                    Context ("Running Association tests for InputObjectType:'$SourceInputObjectType';InputObjectName:'$SourceInputObjectName';TargetObjectType:'$SourceTargetObjectType';TargetObjectName:'$SourceTargetObjectName';") {
                        $SourceInputSearchByValue = Switch ($TestMethod) {'ById' {$SourceInputObjectId}'ByName' {$SourceInputObjectName}}
                        $SourceTargetSearchByValue = Switch ($TestMethod) {'ById' {$SourceTargetObjectId}'ByName' {$SourceTargetObjectName}}
                        # Get InputObject
                        $InputObject = Get-JCObject -Type:($SourceInputObjectType) -SearchBy:($TestMethod) -SearchByValue:($SourceInputSearchByValue);
                        It ("Test if InputObject exists by running: Get-JCObject -Type:('$SourceInputObjectType') -SearchBy:('$TestMethod') -SearchByValue:('$SourceInputSearchByValue');") {
                            $InputObject | Should -Not -BeNullOrEmpty
                            $InputObject.($InputObject.($TestMethod)) | Should -Be $SourceInputSearchByValue
                        }
                        If (!($InputObject)) {Write-Error ('InputObject does not exist:' + $SourceInputObjectType + ':' + $SourceInputSearchByValue); }
                        # Get TargetObject
                        $TargetObject = Get-JCObject -Type:($SourceTargetObjectType) -SearchBy:($TestMethod) -SearchByValue:($SourceTargetSearchByValue);
                        It ("Test if TargetObject exists by running: Get-JCObject -Type:('$SourceTargetObjectType') -SearchBy:('$TestMethod') -SearchByValue:('$SourceTargetSearchByValue');") {
                            $TargetObject | Should -Not -BeNullOrEmpty
                            $TargetObject.($TargetObject.($TestMethod)) | Should -Be $SourceTargetSearchByValue
                        }
                        If (!($TargetObject)) {Write-Error ('TargetObject does not exist:' + $SourceTargetObjectType + ':' + $SourceTargetSearchByValue); }
                        # Get the InputObject and TargetObject Id and Name
                        $InputObjectId = $InputObject.($InputObject.ById)
                        $InputObjectName = $InputObject.($InputObject.ByName)
                        $TargetObjectId = $TargetObject.($TargetObject.ById)
                        $TargetObjectName = $TargetObject.($TargetObject.ByName)
                        $InputSearchByValue = Switch ($TestMethod) {'ById' {$InputObjectId}'ByName' {$InputObjectName}}
                        $TargetSearchByValue = Switch ($TestMethod) {'ById' {$TargetObjectId}'ByName' {$TargetObjectName}}
                        # Test if the association already exists between $InputObjectId and $TargetObjectId
                        $GetJCAssociation = Switch ($TestMethod)
                        {
                            'ById' {Get-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectId:($InputObjectId) -TargetObjectType:($SourceTargetObjectType) | Where-Object {$_.TargetObjectId -eq $TargetObjectId}; }
                            'ByName' {Get-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectName:($InputObjectName) -TargetObjectType:($SourceTargetObjectType) | Where-Object {$_.TargetObjectName -eq $TargetObjectName}; }
                        }
                        #If the association exists
                        If ($GetJCAssociation)
                        {
                            $GetJCAssociation_InputObjectId = $GetJCAssociation.InputObjectId
                            $GetJCAssociation_InputObjectName = $GetJCAssociation.InputObjectName
                            $GetJCAssociation_TargetObjectId = $GetJCAssociation.TargetObjectId
                            $GetJCAssociation_TargetObjectName = $GetJCAssociation.TargetObjectName
                            $GetJCAssociation_InputSearchByValue = Switch ($TestMethod) {'ById' {$GetJCAssociation_InputObjectId}'ByName' {$GetJCAssociation_InputObjectName}}
                            $GetJCAssociation_TargetSearchByValue = Switch ($TestMethod) {'ById' {$GetJCAssociation_TargetObjectId}'ByName' {$GetJCAssociation_TargetObjectName}}
                            # Remove the association between $InputObjectId and $TargetObjectId
                            $RemoveAssociation = Switch ($TestMethod)
                            {
                                'ById' {Remove-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectId:($GetJCAssociation_InputObjectId) -TargetObjectType:($SourceTargetObjectType) -TargetObjectId:($GetJCAssociation_TargetObjectId); }
                                'ByName' {Remove-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectName:($GetJCAssociation_InputObjectName) -TargetObjectType:($SourceTargetObjectType) -TargetObjectName:($GetJCAssociation_TargetObjectName); }
                            }
                            It ("If the association exists then remove the association by running: Remove-JCAssociation -InputObjectType:('$SourceInputObjectType') -InputObject$TestMethodIdentifier`:('$GetJCAssociation_InputSearchByValue') -TargetObjectType:('$SourceTargetObjectType') -TargetObject$TestMethodIdentifier`:('$GetJCAssociation_TargetSearchByValue');") {
                                $RemoveAssociation | Should -BeNullOrEmpty
                            }
                        }
                        # Create new association between $InputObjectName and $TargetObjectName
                        $NewAssociation = Switch ($TestMethod)
                        {
                            'ById' {New-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectId:($InputObjectId) -TargetObjectType:($SourceTargetObjectType) -TargetObjectId:($TargetObjectId); }
                            'ByName' {New-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectName:($InputObjectName) -TargetObjectType:($SourceTargetObjectType) -TargetObjectName:($TargetObjectName); }
                        }
                        It ("Create new association by running: New-JCAssociation -InputObjectType:('$SourceInputObjectType') -InputObject$TestMethodIdentifier`:('$InputSearchByValue') -TargetObjectType:('$SourceTargetObjectType') -TargetObject$TestMethodIdentifier`:('$TargetSearchByValue');") {
                            $NewAssociation | Should -BeNullOrEmpty
                        }
                        # Validate that the new association has been created between $InputSearchByValue and $TargetSearchByValue
                        $InputToTargetAssociation = Get-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectName:($InputObjectName) -TargetObjectType:($SourceTargetObjectType) | Where-Object {$_.TargetObjectName -eq $TargetObjectName}
                        # Get the InputObject and TargetObject Id and Name
                        $InputToTargetAssociation_InputObjectId = $InputToTargetAssociation.InputObjectId
                        $InputToTargetAssociation_InputObjectName = $InputToTargetAssociation.InputObjectName
                        $InputToTargetAssociation_TargetObjectId = $InputToTargetAssociation.TargetObjectId
                        $InputToTargetAssociation_TargetObjectName = $InputToTargetAssociation.TargetObjectName
                        $InputToTargetAssociation_InputSearchByValue = Switch ($TestMethod) {'ById' {$InputToTargetAssociation_InputObjectId}'ByName' {$InputToTargetAssociation_InputObjectName}}
                        $InputToTargetAssociation_TargetSearchByValue = Switch ($TestMethod) {'ById' {$InputToTargetAssociation_TargetObjectId}'ByName' {$InputToTargetAssociation_TargetObjectName}}
                        It ("Validate that the new association has been created by running: Get-JCAssociation -InputObjectType:('$SourceInputObjectType') -InputObjectName:('$InputObjectName') -TargetObjectType:('$SourceTargetObjectType') | Where-Object {`$_.TargetObjectName -eq '$TargetObjectName'};") {
                            $InputToTargetAssociation | Should -Not -BeNullOrEmpty
                            $InputToTargetAssociation_InputObjectName | Should -Be $InputObjectName
                            $InputToTargetAssociation_TargetObjectName | Should -Be $TargetObjectName
                        }
                        If (!($InputToTargetAssociation)) {Write-Error ("$InputToTargetAssociation_InputSearchByValue does not have an association with $InputToTargetAssociation_TargetSearchByValue!"); }
                        # Test that Get-JCAssociation works
                        $GetJCAssociationTest = Switch ($TestMethod)
                        {
                            'ById' {Get-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectId:($InputToTargetAssociation_InputObjectId) -TargetObjectType:($SourceTargetObjectType); }
                            'ByName' {Get-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectName:($InputToTargetAssociation_InputObjectName) -TargetObjectType:($SourceTargetObjectType); }
                        }
                        It ("Validate that the Get-JCAssociation returns associations for the InputObject and the TargetObject by running: Get-JCAssociation -InputObjectType:('$SourceInputObjectType') -InputObject$TestMethodIdentifier`:('$InputToTargetAssociation_InputSearchByValue') -TargetObjectType:('$SourceTargetObjectType');") {
                            $GetJCAssociationTest | Should -Not -BeNullOrEmpty
                            ($GetJCAssociationTest.InputObjectName | Select-Object -Unique) | Should -Be $InputObjectName
                            ($GetJCAssociationTest.TargetObjectName | Select-Object -Unique) | Should -Not -BeNullOrEmpty
                        }
                        # Test that Get-JCAssociation works with -HideTargetData
                        $GetJCAssociationTest = Switch ($TestMethod)
                        {
                            'ById' {Get-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectId:($InputToTargetAssociation_InputObjectId) -TargetObjectType:($SourceTargetObjectType) -HideTargetData; }
                            'ByName' {Get-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectName:($InputToTargetAssociation_InputObjectName) -TargetObjectType:($SourceTargetObjectType) -HideTargetData; }
                        }
                        It ("Validate that the Get-JCAssociation returns associations for the InputObject but not the TargetObject by running: Get-JCAssociation -InputObjectType:('$SourceInputObjectType') -InputObject$TestMethodIdentifier`:('$InputToTargetAssociation_InputSearchByValue') -TargetObjectType:('$SourceTargetObjectType') -HideTargetData;") {
                            $GetJCAssociationTest | Should -Not -BeNullOrEmpty
                            ($GetJCAssociationTest.InputObjectName | Select-Object -Unique) | Should -Be $InputObjectName
                            ($GetJCAssociationTest.TargetObjectName | Select-Object -Unique) | Should -BeNullOrEmpty
                        }
                        # Remove the association between $InputSearchByValue and $TargetSearchByValue
                        $RemoveAssociation_Cleanup = Switch ($TestMethod)
                        {
                            'ById' {Remove-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectId:($InputToTargetAssociation_InputObjectId) -TargetObjectType:($SourceTargetObjectType) -TargetObjectId:($InputToTargetAssociation_TargetObjectId); }
                            'ByName' {Remove-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectName:($InputToTargetAssociation_InputObjectName) -TargetObjectType:($SourceTargetObjectType) -TargetObjectName:($InputToTargetAssociation_TargetObjectName); }
                        }
                        It ("If the association exists then remove the association by running: Remove-JCAssociation -InputObjectType:('$SourceInputObjectType') -InputObject$TestMethodIdentifier`:('$InputToTargetAssociation_InputSearchByValue') -TargetObjectType:('$SourceTargetObjectType') -TargetObject$TestMethodIdentifier`:('$InputToTargetAssociation_TargetSearchByValue');") {
                            $RemoveAssociation_Cleanup | Should -BeNullOrEmpty
                        }
                        # Test to see that the InputObject does not have an association with the TargetObject
                        $InputToTargetDissociation = Switch ($TestMethod)
                        {
                            'ById' {Get-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectId:($InputToTargetAssociation_InputObjectId) -TargetObjectType:($SourceTargetObjectType) | Where-Object {$_.TargetObjectId -eq $InputToTargetAssociation_TargetObjectId}; }
                            'ByName' {Get-JCAssociation -InputObjectType:($SourceInputObjectType) -InputObjectName:($InputToTargetAssociation_InputObjectName) -TargetObjectType:($SourceTargetObjectType) | Where-Object {$_.TargetObjectName -eq $InputToTargetAssociation_TargetObjectName}; }
                        }
                        It ("Validate that the association has been dissociated by running: Get-JCAssociation -InputObjectType:('$SourceInputObjectType)' -InputObject$TestMethodIdentifier`:('$InputToTargetAssociation_TargetSearchByValue') -TargetObjectType:('$SourceTargetObjectType') | Where-Object {`$_.TargetObject$TestMethodIdentifier -eq '$InputToTargetAssociation_TargetSearchByValue'};") {
                            $InputToTargetDissociation | Should -BeNullOrEmpty
                        }
                    }
                }
            }
        }
    }
}