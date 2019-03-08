## Generic Test
# $SingleAdminAPIKey = ''
# Describe "Connect-JCOnline" {

#     It "Connects to JumpCloud with a single admin API Key using force" {
#         $Connect = Connect-JCOnline -JumpCloudAPIKey "$SingleAdminAPIKey" -force
#         $Connect | Should -be $null
#     }
# }
. ('/Users/epanipinto/Documents/LoadJumpCloudModule.ps1')
# # Generate $Associations object records by looping through each association type and its target types
# $JCAssociationTypes = Get-JCAssociationType
# ForEach ($JCAssociationType In $JCAssociationTypes)
# {
#     $InputObjectType = $JCAssociationType.InputObject
#     $TargetObjectTypes = $JCAssociationType.Targets
#     ForEach ($TargetObjectType In $TargetObjectTypes)
#     {
#         $InputObject = Get-JCObject -Type:([string]$InputObjectType) | Get-Random #| Select-Object -First 1
#         $InputObjectId = $InputObject.($InputObject.ById)
#         $InputObjectName = $InputObject.($InputObject.ByName)
#         $TargetObject = Get-JCObject -Type:([string]$TargetObjectType) | Get-Random #| Select-Object -First 1
#         $TargetObjectId = $TargetObject.($TargetObject.ById)
#         $TargetObjectName = $TargetObject.($TargetObject.ByName)
#         If (!($InputObjectType)) {$InputObjectType = 'UNKNOWN'}
#         If (!($InputObjectId)) {$InputObjectId = 'UNKNOWN'}
#         If (!($InputObjectName)) {$InputObjectName = 'UNKNOWN'}
#         If (!($TargetObjectType)) {$TargetObjectType = 'UNKNOWN'}
#         If (!($TargetObjectId)) {$TargetObjectId = 'UNKNOWN'}
#         If (!($TargetObjectName)) {$TargetObjectName = 'UNKNOWN'}
#         Write-Host ('$Associations' + " += [PSCustomObject]@{'InputObjectType' = '$InputObjectType'; 'InputObjectId' = '$InputObjectId'; 'InputObjectName' = '$InputObjectName'; 'TargetObjectType' = '$TargetObjectType'; 'TargetObjectId' = '$TargetObjectId'; 'TargetObjectName' = '$TargetObjectName'; }")
#         # Write-Host ("$InputObjectType`t$InputObjectId`t$InputObjectName`t$TargetObjectType`t$TargetObjectId`t$TargetObjectName")
#         # $Associations += [PSCustomObject]@{'InputObjectType' = $InputObjectType; 'InputObjectId' = $InputObjectId; 'InputObjectName' = $InputObjectName; 'TargetObjectType' = $TargetObjectType; 'TargetObjectId' = $TargetObjectId; 'TargetObjectName' = $TargetObjectName; }
#     }
# }
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


    # Get-JCAssociationType
    # Invoke-JCAssociation

    # New-JCAssociation
    # Remove-JCAssociation
    # Get-JCAssociation

    # Get-JCHash
    # Get-JCObject
    # Invoke-JCApi
    # New-DynamicParameter

    # If exists - Get
    # If not exist - Remove
    # New
    # Get
    # Set
    # Remove
    
    
    $Associations = @()
    $Associations += [PSCustomObject]@{'InputObjectType' = 'activedirectories'; 'InputObjectId' = 'UNKNOWN'; 'InputObjectName' = 'UNKNOWN'; 'TargetObjectType' = 'user'; 'TargetObjectId' = '5c75afc356b1317250b5fe54'; 'TargetObjectName' = 'Batman'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'activedirectories'; 'InputObjectId' = 'UNKNOWN'; 'InputObjectName' = 'UNKNOWN'; 'TargetObjectType' = 'user_group'; 'TargetObjectId' = '5c75afd145886d3955ae1703'; 'TargetObjectName' = 'MARVEL'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'commands'; 'InputObjectId' = '5c75afda56b1317250b5fe68'; 'InputObjectName' = 'Get Local Users'; 'TargetObjectType' = 'system'; 'TargetObjectId' = '5c75b034d4324071b68998dc'; 'TargetObjectName' = 'DESKTOP-UJIRR4U'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'commands'; 'InputObjectId' = '5c75afda56b1317250b5fe68'; 'InputObjectName' = 'Get Local Users'; 'TargetObjectType' = 'system_group'; 'TargetObjectId' = '5c785ca145886d3955aefb4a'; 'TargetObjectName' = 'SystemGroup1'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'ldapservers'; 'InputObjectId' = '5c0fdc5d45886d6cbd461378'; 'InputObjectName' = 'jumpcloud'; 'TargetObjectType' = 'user'; 'TargetObjectId' = '5c75afc14b697f234853b0d2'; 'TargetObjectName' = 'GreenLantern'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'ldapservers'; 'InputObjectId' = '5c0fdc5d45886d6cbd461378'; 'InputObjectName' = 'jumpcloud'; 'TargetObjectType' = 'user_group'; 'TargetObjectId' = '5c548360232e1164e94b8a6d'; 'TargetObjectName' = 'TestGroup'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'policies'; 'InputObjectId' = 'UNKNOWN'; 'InputObjectName' = 'UNKNOWN'; 'TargetObjectType' = 'system'; 'TargetObjectId' = '5c7858424345ab70018e08bb'; 'TargetObjectName' = 'darkhorse1'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'policies'; 'InputObjectId' = 'UNKNOWN'; 'InputObjectName' = 'UNKNOWN'; 'TargetObjectType' = 'system_group'; 'TargetObjectId' = '5c785cab45886d3955aefb4f'; 'TargetObjectName' = 'SystemGroup2'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'applications'; 'InputObjectId' = 'UNKNOWN'; 'InputObjectName' = 'UNKNOWN'; 'TargetObjectType' = 'user_group'; 'TargetObjectId' = '5c548360232e1164e94b8a6d'; 'TargetObjectName' = 'TestGroup'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'radiusservers'; 'InputObjectId' = '5c75bb9a2dff6d18cff199ca'; 'InputObjectName' = 'TestRadius'; 'TargetObjectType' = 'user_group'; 'TargetObjectId' = '5c75afd145886d3955ae1703'; 'TargetObjectName' = 'MARVEL'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'systemgroups'; 'InputObjectId' = '5c785cab45886d3955aefb4f'; 'InputObjectName' = 'SystemGroup2'; 'TargetObjectType' = 'policy'; 'TargetObjectId' = 'UNKNOWN'; 'TargetObjectName' = 'UNKNOWN'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'systemgroups'; 'InputObjectId' = '5c785ca145886d3955aefb4a'; 'InputObjectName' = 'SystemGroup1'; 'TargetObjectType' = 'user_group'; 'TargetObjectId' = '5c75afd145886d3955ae1703'; 'TargetObjectName' = 'MARVEL'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'systemgroups'; 'InputObjectId' = '5c785cab45886d3955aefb4f'; 'InputObjectName' = 'SystemGroup2'; 'TargetObjectType' = 'command'; 'TargetObjectId' = '5c75afda56b1317250b5fe68'; 'TargetObjectName' = 'Get Local Users'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'systems'; 'InputObjectId' = '5c75b034d4324071b68998dc'; 'InputObjectName' = 'DESKTOP-UJIRR4U'; 'TargetObjectType' = 'policy'; 'TargetObjectId' = 'UNKNOWN'; 'TargetObjectName' = 'UNKNOWN'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'systems'; 'InputObjectId' = '5c75b034d4324071b68998dc'; 'InputObjectName' = 'DESKTOP-UJIRR4U'; 'TargetObjectType' = 'user'; 'TargetObjectId' = '5c75afc72dff6d18cff194e6'; 'TargetObjectName' = 'Magneto'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'systems'; 'InputObjectId' = '5c75b034d4324071b68998dc'; 'InputObjectName' = 'DESKTOP-UJIRR4U'; 'TargetObjectType' = 'command'; 'TargetObjectId' = '5c75afda56b1317250b5fe68'; 'TargetObjectName' = 'Get Local Users'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'usergroups'; 'InputObjectId' = '5c75afd145886d3955ae1703'; 'InputObjectName' = 'MARVEL'; 'TargetObjectType' = 'active_directory'; 'TargetObjectId' = 'UNKNOWN'; 'TargetObjectName' = 'UNKNOWN'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'usergroups'; 'InputObjectId' = '5c75afce45886d3955ae1701'; 'InputObjectName' = 'D.C.'; 'TargetObjectType' = 'application'; 'TargetObjectId' = 'UNKNOWN'; 'TargetObjectName' = 'UNKNOWN'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'usergroups'; 'InputObjectId' = '5c75afce45886d3955ae1701'; 'InputObjectName' = 'D.C.'; 'TargetObjectType' = 'ldap_server'; 'TargetObjectId' = '5c0fdc5d45886d6cbd461378'; 'TargetObjectName' = 'jumpcloud'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'usergroups'; 'InputObjectId' = '5c548360232e1164e94b8a6d'; 'InputObjectName' = 'TestGroup'; 'TargetObjectType' = 'radius_server'; 'TargetObjectId' = '5c75bb9a2dff6d18cff199ca'; 'TargetObjectName' = 'TestRadius'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'usergroups'; 'InputObjectId' = '5c548360232e1164e94b8a6d'; 'InputObjectName' = 'TestGroup'; 'TargetObjectType' = 'system_group'; 'TargetObjectId' = '5c785cab45886d3955aefb4f'; 'TargetObjectName' = 'SystemGroup2'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'users'; 'InputObjectId' = '5c75afc14b697f234853b0d2'; 'InputObjectName' = 'GreenLantern'; 'TargetObjectType' = 'active_directory'; 'TargetObjectId' = 'UNKNOWN'; 'TargetObjectName' = 'UNKNOWN'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'users'; 'InputObjectId' = '5c75afc556b1317250b5fe5c'; 'InputObjectName' = 'Spiderman'; 'TargetObjectType' = 'ldap_server'; 'TargetObjectId' = '5c0fdc5d45886d6cbd461378'; 'TargetObjectName' = 'jumpcloud'; }
    $Associations += [PSCustomObject]@{'InputObjectType' = 'users'; 'InputObjectId' = '5c75afc62f2a730f31771fe7'; 'InputObjectName' = 'DoctorDoom'; 'TargetObjectType' = 'system'; 'TargetObjectId' = '5c7858424345ab70018e08bb'; 'TargetObjectName' = 'darkhorse1'; }
    $AssociationObject = $Associations | Where-Object {$_.InputObjectId -ne 'UNKNOWN' -and $_.InputObjectName -ne 'UNKNOWN' -and $_.TargetObjectId -ne 'UNKNOWN' -and $_.TargetObjectName -ne 'UNKNOWN'}
    # $TestMethods = ('ById', 'ByName')
    # $TestMethods = ('ById')
    $TestMethods = ('ByName')
    ForEach ($AssociationRecord In $AssociationObject)
    {
        $SourceInputObjectType = $AssociationRecord.InputObjectType
        $SourceInputObjectId = $AssociationRecord.InputObjectId
        $SourceInputObjectName = $AssociationRecord.InputObjectName
        $SourceTargetObjectType = $AssociationRecord.TargetObjectType
        $SourceTargetObjectId = $AssociationRecord.TargetObjectId
        $SourceTargetObjectName = $AssociationRecord.TargetObjectName

        ForEach ($TestMethod In  $TestMethods)
        {
            Context ("When Association functions are called with parameterSet '$TestMethod' for InputObjectType:'$SourceInputObjectType';InputObjectName:'$SourceInputObjectName';TargetObjectType:'$SourceTargetObjectType';TargetObjectName:'$SourceTargetObjectName';") {
                $TestMethodIdentifier = $TestMethod.Replace('By', '')
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
                It ("Validate that the Get-JCAssociation returns associations for the InputObject by running: Get-JCAssociation -InputObjectType:('$SourceInputObjectType') -InputObject$TestMethodIdentifier`:('$InputToTargetAssociation_InputSearchByValue') -TargetObjectType:('$SourceTargetObjectType');") {
                    $GetJCAssociationTest | Should -Not -BeNullOrEmpty
                    ($GetJCAssociationTest.InputObjectName | Select-Object -Unique) | Should -Be $InputObjectName
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



# ############################################################
# # Get-JCRadiusServer
# ############################################################
# Get-JCRadiusServer -Verbose | Select *
# Get-JCRadiusServer -RadiusServerId:('5c5c371704c4b477964ab4fa') -Verbose
# Get-JCRadiusServer -RadiusServerName:('Test Me') -Verbose -Debug
# ############################################################
# # Remove-JCRadiusServer
# ############################################################
# Remove-JCRadiusServer -RadiusServerName:('Test Me 2') -Verbose
# Remove-JCRadiusServer -RadiusServerId:('5c7e7d6a48706b3edab8a69b')
# Remove-JCRadiusServer -RadiusServerName:('Test Me 2') -force -Verbose
# ############################################################
# New-JCRadiusServer -networkSourceIp:('233.233.233.233') -sharedSecret:('HqySCjDJU!7YsQTG2cTHNRV9pF6lSc5') -name:('Test Me 2') -Verbose
# ############################################################
# # Set-JCRadiusServer
# ############################################################
# Set-JCRadiusServer  -RadiusServerName:('Test Me 2') -NewNetworkSourceIp:('233.233.233.234') -NewSharedSecret:('HqySCjDJU!7YsQTG2cTHNRV9pF6lSc5') -Verbose
# Set-JCRadiusServer  -RadiusServerName:('Test Me 2') -NewSharedSecret:('HqySCjDJU!7YsQTG2cTHNRV9pF6lSc6') -Verbose
# Set-JCRadiusServer  -RadiusServerName:('Test Me 2') -NewRadiusServerName:('Test Me 3') -Verbose
# Set-JCRadiusServer  -RadiusServerName:('Test Me 3') -NewRadiusServerName:('Test Me 2') -NewNetworkSourceIp:('233.233.233.233') -NewSharedSecret:('HqySCjDJU!7YsQTG2cTHNRV9pF6lSc5') -Verbose
# ############################################################
# # Add-JCRadiusServerGroup
# ############################################################
# Add-JCRadiusServerGroup -RadiusServerName:('Test Me 2') -UserGroupName:('201') -Verbose
# ############################################################
# # Get-JCRadiusServerGroup
# ############################################################
# Get-JCRadiusServerGroup -RadiusServerName:('Test Me 2')  -Verbose
# ############################################################
# # Remove-JCRadiusServerGroup
# ############################################################
# Remove-JCRadiusServerGroup -RadiusServerName:('Test Me 2') -UserGroupName:('201') -Verbose







# ##############################################################################################################################
# # /Private/NestedFunctions/Associations/New-JCAssociation.ps1
# ##############################################################################################################################
# # New-JCAssociation -InputObjectType:('radiusservers') -InputObjectId:('5c5c371704c4b477964ab4fa') -TargetObjectType:('user_group') -TargetObjectId:('59f20255c9118021fa01b80f') -Verbose # The API does not allow you to filter groups by Id.
# New-JCAssociation -InputObjectType:('radiusservers') -InputObjectName:('Test Me') -TargetObjectType:('user_group') -TargetObjectName:('All users') -Verbose
# ##############################################################################################################################
# # /Private/NestedFunctions/Associations/Remove-JCAssociation.ps1
# ##############################################################################################################################
# # Remove-JCAssociation -InputObjectType:('radiusservers') -InputObjectId:('5c5c371704c4b477964ab4fa') -TargetObjectType:('user_group') -TargetObjectId:('59f20255c9118021fa01b80f') -Verbose # The API does not allow you to filter groups by Id.
# Remove-JCAssociation -InputObjectType:('radiusservers') -InputObjectName:('Test Me') -TargetObjectType:('user_group') -TargetObjectName:('All users') -Verbose
# ##############################################################################################################################
# # /Private/NestedFunctions/Associations/Get-JCAssociation.ps1
# ##############################################################################################################################
# # Users to Systems
# Get-JCAssociation -InputObjectType:('users') -InputObjectId:('5ab915cf861178491b8fc399') -TargetObjectType:('system') -Verbose| FT
# Get-JCAssociation -InputObjectType:('users') -InputObjectName:('cool.dude') -TargetObjectType:('system') -Verbose | FT
# # Systems to Users
# Get-JCAssociation -InputObjectType:('systems') -InputObjectId:('5b193f483839366dd7ee3981') -TargetObjectType:('user') -Verbose | FT
# Get-JCAssociation -InputObjectType:('systems') -InputObjectName:('Active_AWS Linux') -TargetObjectType:('user') -Verbose | FT


# Get-JCAssociation -InputObjectType:('radiusservers') -InputObjectName:'Test Me 2' -TargetObjectType:('user') -Verbose | FT
# Get-JCAssociation -InputObjectType:'radiusservers' -InputObjectName:'Test Me 2' -TargetObjectType:'user_group' -Verbose

# New-JCAssociation -InputObjectType:'radiusservers' -InputObjectName:'Test Me 2' -TargetObjectType:'user' -TargetObjectName:'cool.dude'
# Remove-JCAssociation -InputObjectType:'radiusservers' -InputObjectName:'Test Me 2' -TargetObjectType:'user' -TargetObjectName:'cool.dude'



# ##############################################################################################################################
# # /Private/NestedFunctions/Associations/Invoke-JCAssociation.ps1
# ##############################################################################################################################
# # Add association
# # Invoke-JCAssociation -Action:('add') -InputObjectType:('radiusservers') -InputObjectId:('5c5c371704c4b477964ab4fa') -TargetObjectType:('user_group') -TargetObjectId:('59f20255c9118021fa01b80f') -Verbose # The API does not allow you to filter groups by Id.
# Invoke-JCAssociation -Action:('add') -InputObjectType:('radiusservers') -InputObjectName:('Test Me') -TargetObjectType:('user_group') -TargetObjectName:('All users') -Verbose -Debug
# Invoke-JCAssociation -Action:('add') -InputObjectType:('radiusservers') -InputObjectName:('Test Me') -TargetObjectName:('All users')
















# # Remove association
# # Invoke-JCAssociation -Action:('remove') -InputObjectType:('radiusservers') -InputObjectId:('5c5c371704c4b477964ab4fa') -TargetObjectType:('user_group') -TargetObjectId:('59f20255c9118021fa01b80f') -Verbose # The API does not allow you to filter groups by Id.
# Invoke-JCAssociation -Action:('remove') -InputObjectType:('radiusservers') -InputObjectName:('Test Me') -TargetObjectType:('user_group') -TargetObjectName:('All users') -Verbose

# # Get association
# # Users to Systems
# Invoke-JCAssociation -Action:('get') -InputObjectType:('users') -InputObjectId:('5ab915cf861178491b8fc399') -TargetObjectType:('system') -Verbose
# Invoke-JCAssociation -Action:('get') -InputObjectType:('users') -InputObjectName:('cool.dude') -TargetObjectType:('system') -Verbose
# # Systems to Users
# Invoke-JCAssociation -Action:('get') -InputObjectType:('systems') -InputObjectId:('5b193f483839366dd7ee3981') -TargetObjectType:('user') -Verbose
# Invoke-JCAssociation -Action:('get') -InputObjectType:('systems') -InputObjectName:('Active_AWS Linux') -TargetObjectType:('user') -Verbose

# ##############################################################################################################################
# # /Private/HashFunctions/Get-JCHash.ps1 - Example 1
# ##############################################################################################################################
# # Get specific data
# $UserHash = Get-JCHash -Url:('/api/search/systemusers') -Method:('POST') -Key:('username') -Values:(@('_id', 'email', 'firstname')) -Limit:(100) -Verbose
# # Verify count of users
# Write-Host ('Returning ' + [string]$UserHash.Count + ' users.') -BackgroundColor:('Cyan')
# # Search data for specific record
# $User = $UserHash.Get_Item('elliotttest')
# # Do something with record
# $User
# ##############################################################################################################################
# # /Private/HashFunctions/Get-JCHash.ps1 - Example 2
# ##############################################################################################################################
# # Get all data
# $UserHash = Get-JCHash -Url:('/api/search/systemusers') -Method:('POST') -Key:('username') -Verbose -Limit:(100)
# # Verify count of users
# Write-Host ('Returning ' + [string]$UserHash.Count + ' users.') -BackgroundColor:('Cyan')
# # Search data for specific record
# $User = $UserHash.Get_Item('elliotttest')
# # Do something with record
# $User

# ##############################################################################################################################
# # /Private/NestedFunctions/Invoke-JCApi.ps1
# ##############################################################################################################################
# Invoke-JCApi -Url:('/api/search/systemusers?filter=username:eq:elliotttest') -Method:('POST') -Body:('{"filter":[{"username":"elliotttest"}]}') -Paginate:($False) -Fields:(@('activated', 'username'))
# Invoke-JCApi -Url:('/api/search/systemusers') -Method:('POST') -Body:('{}') -Paginate:($True) -Fields:('') 

# ##############################################################################################################################
# # /Private/NestedFunctions/Get-JCObject.ps1
# ##############################################################################################################################
# $user = 'elliotttest'
# $system = 'Active_AWS Linux'
# $policies = 'Bespoke dog 1'
# $group = '201'
# $application = 'dropbox'
# $directory = 'Google Apps'
# $command = 'ElliottTest'
# $radiusservers = 'Test Me'
# # Get-JCObject -Type:('system') -SearchBy:('ByName') -SearchByValue:($system) -Verbose
# # Get-JCObject -Type:('user') -SearchBy:('ByName') -SearchByValue:($user) -Fields:(@('activated', 'username')) -Verbose | Select *
# # Get-JCObject -Type:('policies') -SearchBy:('ByName') -SearchByValue:($policies)
# # Get-JCObject -Type:('group') -SearchBy:('ByName') -SearchByValue:($group)
# # Get-JCObject -Type:('application') -SearchBy:('ByName') -SearchByValue:($application)
# # Get-JCObject -Type:('directory') -SearchBy:('ByName') -SearchByValue:($directory)
# # Get-JCObject -Type:('command') -SearchBy:('ByName') -SearchByValue:($command)
# # Get-JCObject -Type:('radiusservers') -SearchBy:('ByName') -SearchByValue:($radiusservers)

# # Get-JCObject -Type:('user') -ReturnAll -Verbose
# # Get-JCObject -Type:('system') -ReturnAll
# # Get-JCObject -Type:('policies') -ReturnAll
# # Get-JCObject -Type:('group') -ReturnAll
# # Get-JCObject -Type:('application') -ReturnAll
# # Get-JCObject -Type:('directory') -ReturnAll
# # Get-JCObject -Type:('command') -ReturnAll
# # Get-JCObject -Type:('radiusservers') -ReturnAll

# # Get-JCObject -Type:('policies') -SearchBy:('ByName') -SearchByValue:($policies) | Select-Object -Unique | ForEach-Object {Get-JCObject -Type:('policyresults') -SearchBy:('ById') -SearchByValue:($_.($_.ById)) -Verbose}
# # Get-JCObject -Type:('application') -SearchBy:('ByName') -SearchByValue:($application) | Select-Object -Unique | ForEach-Object { Get-JCObject -Type:('applicationUsers') -SearchBy:('ById') -SearchByValue:($_.($_.ById)) -Verbose}

# $Type = 'radiusservers'
# $SearchValue = 'test'
# $a = Get-JCObject -Type:($Type) -SearchBy:('ByName') -SearchByValue:($SearchValue) -Limit:(100) -Verbose | Select name
# $b = Get-JCObject -Type:($Type) -Limit:(100) -Verbose | Select name | Where-Object {$_.name -like $SearchValue}
# Compare-Object $a $b -IncludeEqual

# Get-JCObject -Type:('systems') -SearchBy:('ByName') -SearchByValue:('*desktop*') -Fields:('displayname') -Verbose -Limit 2| Select *
# Invoke-JCApi -Body:('{"filter":[{"displayName":"ElliottTest"}]}') -Fields:('displayName') -Method:('POST') -Paginate:($True) -Url:('/api/search/systems?filter=displayName:eq:ElliottTest') -Verbose:($True)
