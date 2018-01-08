#Tests for JumpCloud Module Version 1.0.0

# To run all the Pester Tests you will need to have a tenant that matches the below criteria.

# For Command Results Tests - Have at least 5 command results present in your Org (These results will be deleted)
# For Commands Tests - Have at least 2 JumpCloud commands that are set to run via the 'Run on Trigger' event
# For Groups Tests - Have at least 2 JumpCloud User Groups and 2 JumpCloud System Groups
# For Systems Tests - Have at least 2 JumpCloud Systems present in your Org.
# For Users Tests - Have at least 2 JumpCloud Users present in your Org.

#Additionally you must populate the below variables to run successful tests using the -ByID parameter


$SystemID = '' # Enter the System ID for a system in your test tenant. **Note users will be added and removed from this system during the tests

$Username = 'pester.tester' # Create a user with username 'pester.tester'
$UserID = '' # Paste the UserID for the user with username pester.tester


$UserGroupName = 'PesterTest_UserGroup'  #Create a user group named PesterTest_UserGroup within your environment
$UserGroupID = ''  # Paste the corresponding GroupID for the user group named PesterTest_UserGroup

$SystemGroupName = 'PesterTest_SystemGroup' # Create a sytem group named PesterTest_SystemGroup within your environment
$SystemGroupID = ''  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup

$NewJCSystemGroup = 'NewSystemGroup' #Do not modify this
$NewJCUserGroup = 'NewUserGroup' #Do not modify this

#Test Functions

Function New-RandomUser  ()
{
    [CmdletBinding(DefaultParameterSetName='NoAttributes')]
    param
    (
        [Parameter(Mandatory,Position=0)]
        [String]
        $Domain,

        [Parameter(ParameterSetName='Attributes')] ##Test this to see if this can be modified.
        [switch]
        $Attributes

    )

    if (($PSCmdlet.ParameterSetName -eq 'NoAttributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
        $email =  $username + "@$Domain.com"

        $RandomUser = [ordered]@{
        FirstName = 'Pester'
        LastName = 'Test'
        Username = $username
        Email = $email
        Password = 'Temp123!'
        }

        $NewRandomUser =  New-Object psobject -Property $RandomUser
    }

    if (($PSCmdlet.ParameterSetName -eq 'Attributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
        $email =  $username + "@$Domain.com"

        $RandomUser = [ordered]@{
        FirstName = 'Pester'
        LastName = 'Test'
        Username = $username
        Email = $email
        Password = 'Temp123!'
        NumberOfCustomAttributes = 3
        Attribute1_name = 'Department'
        Attribute1_value = 'Sales'
        Attribute2_name = 'Office'
        Attribute2_value = '456789'
        Attribute3_name = 'Lang'
        Attribute3_value = 'French'
        }
        $NewRandomUser =  New-Object psobject -Property $RandomUser
    }


    return $NewRandomUser
}
Function New-RandomString () {
    [CmdletBinding()]

    param(

    [Parameter(Mandatory)] ##Test this to see if this can be modified.
    [ValidateRange(0,52)]
    [Int]
    $NumberOfChars

    )
    begin {}
    process{
        $Random = -join ((65..90) + (97..122) | Get-Random -Count $NumberOfChars | % {[char]$_})
    }
    end{Return $Random}


}

$Random = New-RandomString '8'
$RandomEmail = "$Random@$Random.com"

$ModuleManifestName = 'JumpCloud.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

#region CommandResult Pester tests

#region CommandResults test data validation
$CommandResults = Get-JCCommandResult #Ensure there are command results to test

if ($CommandResults._id.Count -lt 5) #If there are not at least five command results then use the Invoke-JCCommand to populate four command results
{
    Write-Error 'You must have at least 5 Command Results to run the Pester tests'
}

Write-Host "There are $($CommandResults._id.Count) command results"
#endregion CommandResults test data validation

Describe 'Get-JCCommandResults'{

    It "Gets all JumpCloud command results"{

        $CommandResults = Get-JCCommandResult
        $CommandResults.count | Should -BeGreaterThan 1
        return $CommandResults.count

    }

   It "Gets a single JumpCloud command result using -ByID" {

        $SingleCommand = Get-JCCommandResult | Select-Object -Last 1
        $SingleCommandResult = Get-JCCommandResult -ByID $SingleCommand._id
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty

    }

   It "Gets a single JumpCloud command result without declaring -ByID" {

        $SingleCommand = Get-JCCommandResult | Select-Object -Last 1
        $SingleCommandResult = Get-JCCommandResult $SingleCommand._id
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty

    }

   It "Gets a single JumpCloud command result declaring CommandResultID" {

        $SingleCommand = Get-JCCommandResult | Select-Object -Last 1
        $SingleCommandResult = Get-JCCommandResult -CommandResultID $SingleCommand._id
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty

    }

    It "Gets a single JumpCloud command result using -ByID passed through the pipeline" {

        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1 | Get-JCCommandResult -ByID
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty
    }

    It "Gets a single JumpCloud command result passed through the pipeline without declaring -ByID" {

        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1 | Get-JCCommandResult
        $SingleCommandResult._id | Should -Not -BeNullOrEmpty
    }

    It "Gets all JumpCloud commandresults using -ByID passed through the pipeline" {

        $CommandResults = Get-JCCommandResult | Get-JCCommandResult -ByID
        $CommandResults._id.count | Should -BeGreaterThan 1

    }

    It "Gets all JumpCloud commandresults passed through the pipeline with out declaring -ByID" {

        $CommandResults = Get-JCCommandResult | Get-JCCommandResult
        $CommandResults._id.count | Should -BeGreaterThan 1

    }

}

Describe 'Remove-JCCommandResult'{

    It "Ensures the warning message is displayed by default, Deletes a single JumpCloud command result declaring -CommandResultIT" {
        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1
        $DeletedResult = Remove-JCCommandResult -CommandResultID $SingleCommandResult._id
        $DeletedResult._id.count | Should -Be 1
    }


    It "Removes a JumpCloud command result using -CommandResultID with the force paramter"{
        $SingleCommandResult = Get-JCCommandResult | Select-Object -Last 1
        $DeletedResult = Remove-JCCommandResult -CommandResultID $SingleCommandResult._id -force
        $DeletedResult._id.count | Should -Be 1
    }

    It "Removes a JumpCloud command result passed through the pipeline with the force parameter without declaring -CommandResultID"{

        $DeletedResult = Get-JCCommandResult | Select-Object -Last 1 | Remove-JCCommandResult -force
        $DeletedResult._id.count | Should -Be 1

    }

    It "Removes two JumpCloud command results passed through the pipeline with force parameter without declaring -CommandResultID"{
        $DeletedResult = Get-JCCommandResult | Select-Object -Last 2 | Remove-JCCommandResult -force
        $DeletedResult._id.count | Should -Be 2

    }

}

#endregion CommandResult Pester tests

#region Commands Pester test


#region Commands test data validation
$Commands = Get-JCCommand

if ($($Commands._id.Count) -le 1)
{Write-Error 'You must have at least 2 JumpCloud commands to run the Pester tests';break}

Write-Host "There are $($Commands.Count) commands"

$Triggers = $Commands | Where-Object trigger -ne '' | Measure-Object

if ($Triggers.Count -lt 2 )
{Write-Error 'You must have at least 2 JumpCloud commands with command triggers to run the Pester tests'
break}
#endregion Commands test data validation

Describe 'Get-JCCommand'{

    It "Gets all JumpCloud commands"{
        $AllCommands = Get-JCCommand
        $AllCommands._id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud command  declaring -CommandID"{
        $SingleCommand = Get-JCCommand | Select-Object -Last 1
        $SingleResult = Get-JCCommand -CommandID $SingleCommand._id
        $SingleResult._id.Count | Should Be 1

    }

    It "Gets a single JumpCloud command  without declaring -CommandID"{
        $SingleCommand = Get-JCCommand | Select-Object -Last 1
        $SingleResult = Get-JCCommand $SingleCommand._id
        $SingleResult._id.Count | Should Be 1

    }

    It "Gets a single JumpCloud command using -ByID passed through the pipeline"{
        $SingleResult = Get-JCCommand | Select-Object -Last 1 | Get-JCCommand -ByID
        $SingleResult._id.Count | Should Be 1
    }

    It "Gets a single JumpCloud command passed through the pipeline without declaring -ByID"{
        $SingleResult = Get-JCCommand | Select-Object -Last 1 | Get-JCCommand
        $SingleResult._id.Count | Should Be 1
    }


    It "Gets all JumpCloud command passed through the pipeline declaring -ByID"{
        $MultiResult = Get-JCCommand | Get-JCCommand -ByID
        $MultiResult._id.Count | Should -BeGreaterThan 1
    }

    It "Gets all JumpCloud command triggers"{
        $Triggers = Get-JCCommand | Where-Object trigger -ne ''
        $Triggers._id.Count | Should -BeGreaterThan 1
    }


}

Describe 'Invoke-JCCommand'{

    It "Invokes a single JumpCloud command declaring the -trigger"{
        $SingleTrigger = Get-JCCommand | Where-Object trigger -ne '' | Select-Object -Last 1 | Select-Object trigger
        $SingleResult = Invoke-JCCommand -trigger $SingleTrigger.trigger
        $SingleResult.triggered.Count | Should Be 1

    }

    It "Invokes a single JumpCloud command passed through the pipeline from Get-JCCommand without declaring -trigger"{
        $SingleResult = Get-JCCommand | Where-Object trigger -ne '' | Select-Object -Last 1 | Invoke-JCCommand
        $SingleResult.triggered.Count | Should Be 1
    }

    It "Invokes two JumpCloud command passed through the pipeline from Get-JCCommand without declaring -trigger"{
        $MultiResult = Get-JCCommand | Where-Object trigger -ne '' | Select-Object -Last 2 | Invoke-JCCommand
        $MultiResult.triggered.Count | Should Be 2
    }

}

#endregion Commands Pester test

#region Groups pester test

#region Groups test data validation

$SystemGroups = Get-JCGroup -Type System
$UserGroups = Get-JCGroup -Type User

if ($UserGroups._id.Count -lt 2) {
    Write-Error 'You must have at least 2 JumpCloud User Groups to run the Pester tests';break
}

if ($SystemGroups._id.Count -lt 2) {
    Write-Error 'You must have at least 2 JumpCloud System Groups to run the Pester tests';break
}

Write-Host "There are $($UserGroups._id.Count) User Groups and " -NoNewline
Write-Host "there are $($SystemGroups._id.Count) System Groups"

Get-JCGroup -Type System | Get-JCSystemGroupMember | Remove-JCSystemGroupMember | Out-Null #Remove all system group members
#endregion Groups test data validation
Describe 'Add-JCSystemGroupMember and Remove-JCSystemGroupmember'{

    It "Adds a JumpCloud system to a JumpCloud system group by System Groupname and SystemID"{
        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $SystemID -GroupName $SystemGroupName
        $SingleSystemGroupAdd.Status | Should Be 'Added'

    }

    It "Removes a JumpCloud system from a JumpCloud system group by System Groupname and SystemID"{
        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $SystemID -GroupName $SystemGroupName
        $SingleSystemGroupRemove.Status | Should Be 'Removed'

    }

    It "Adds a JumpCloud system to a JumpCloud system group by System GroupID and SystemID"{
        $SingleSystemGroupAdd = Add-JCSystemGroupMember -SystemID $SystemID -GroupID $SystemGroupID
        $SingleSystemGroupAdd.Status | Should Be 'Added'
    }

    It "Removes a JumpCloud system from a JumpCloud system group by System GroupID and SystemID"{
        $SingleSystemGroupRemove = Remove-JCSystemGroupMember -SystemID $SystemID -GroupID $SystemGroupID
        $SingleSystemGroupRemove.Status | Should Be 'Removed'

    }

    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline"{
        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $SystemGroupName
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

    It "Removes two JumpCloud systems from a JumpCloud system group using the pipeline" {
        $MultiSystemGroupRemove =  Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $SystemGroupName
        $MultiSystemGroupRemove.Status | Select-Object -Unique | Should Be 'Removed'

    }

    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline using -ByID"{
        $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $SystemGroupName -ByID
        $MultiSystemGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

    It "Removes two JumpCloud systems from a JumpCloud system group using the pipeline using -ByID" {
        $MultiSystemGroupRemove =  Get-JCSystem | Select-Object -Last 2 | Remove-JCSystemGroupMember -GroupName $SystemGroupName -ByID
        $MultiSystemGroupRemove.Status | Select-Object -Unique | Should Be 'Removed'

    }


}

Describe 'Add-JCUserGroupMember and Remove-JCUserGroupMember'{

    It "Adds a JumpCloud user to a JumpCloud user group by User GroupName and Username"{
        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupName $UserGroupName -username $Username
        $SingleUserGroupAdd = $SingleUserGroupAdd.Status | Should Be 'Added'

    }

    It "Removes JumpCloud user from a JumpCloud user group by User GroupName and Username"{
        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupName $UserGroupName -username $Username
        $SingleUserGroupRemove.Status | Should Be 'Removed'

    }

    It "Adds a JumpCloud user to a JumpCloud user group by UserID and Group ID"{
        $SingleUserGroupAdd = Add-JCUserGroupMember -GroupID $UserGroupID -UserID $UserID
        $SingleUserGroupAdd.Status | Should Be 'Added'
    }

    It "Removes a JumpCloud system from a JumpCloud system group by System GroupID and SystemID"{
        $SingleUserGroupRemove = Remove-JCUserGroupMember -GroupID $UserGroupID -UserID $UserID
        $SingleUserGroupRemove.Status | Should Be 'Removed'
    }

    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline"{
        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $UserGroupName
        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

    It "Removes two JumpCLoud users from a JumpCloud user group using the pipeline"{
        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $UserGroupName
        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Removed'
    }
    It "Adds two JumpCLoud users to a JumpCloud user group using the pipeline using -ByID"{
        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $UserGroupName -ByID
        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

    It "Removes two JumpCLoud users from a JumpCloud user group using the pipeline using -ByID"{
        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Remove-JCUserGroupMember -GroupName $UserGroupName  -ByID
        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Removed'
    }
        It "Adds back two JumpCLoud users to a JumpCloud user group using the pipeline using -ByID"{
        $MultiUserGroupAdd = Get-JCUser | Select-Object -Last 2 | Add-JCUserGroupMember -GroupName $UserGroupName -ByID
        $MultiUserGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }




}

Describe 'Get-JCGroup'{

    IT 'Gets all groups: System and User'{

        $Groups = Get-JCGroup
        $TwoGroups = $Groups.type | Select-Object -Unique | Measure-Object
        $TwoGroups.Count | Should -Be 2
    }

    IT 'Gets all JumpCloud User Groups'{

        $UserGroups = Get-JCGroup -Type User
        $OneGroup = $UserGroups.type | Select-Object -Unique | Measure-Object
        $OneGroup.Count | Should -Be 1

    }

    IT 'Gets all JumpCloud System Groups'{

        $SystemGroups = Get-JCGroup -Type System
        $OneGroup = $SystemGroups.type | Select-Object -Unique | Measure-Object
        $OneGroup.Count | Should -Be 1

    }

}

Describe 'Get-JCSystemGroupMember'{

    It "Adds two JumpCloud systems to a JumpCloud system group using the pipeline"{
    $MultiSystemGroupAdd = Get-JCSystem | Select-Object -Last 2 | Add-JCSystemGroupMember -GroupName $SystemGroupName
    $MultiSystemGroupAdd.Status | Select-Object -Unique | Should Be 'Added'
    }

    IT 'Gets a System Groups membership by Groupname'{
        $SystemGroupMembers = Get-JCSystemGroupMember -GroupName $SystemGroupName
        $SystemGroupMembers.id.Count | Should -BeGreaterThan 0
    }

    IT 'Gets a System Groups membership -ByID'{
        $SystemGroupMembers = Get-JCSystemGroupMember -ByID $SystemGroupID
        $SystemGroupMembers.to.id.Count | Should -BeGreaterThan 0
    }

    It 'Gets all System Group members using Get-JCGroup -type system and the pipeline'{
        $AllSystemGroupmembers = Get-JCGroup -Type System | Get-JCSystemGroupMember
        $AllSystemGroupmembers.GroupName.Count | Should -BeGreaterThan 1
    }

}

Describe 'Get-JCUserGroupMember'{

    IT 'Gets a User Groups membership by Groupname'{
        $UserGroupMembers = Get-JCUserGroupMember -GroupName $UserGroupName
        $UserGroupMembers.id.Count | Should -BeGreaterThan 0
    }

    IT 'Gets a User Groups membership -ByID'{
        $UserGroupMembers = Get-JCUserGroupMember -ByID $UserGroupID
        $UserGroupMembers.to.id.Count | Should -BeGreaterThan 0
    }

    It 'Gets all User Group members using Get-JCGroup -type User and the pipeline'{
        $AllUserGroupmembers = Get-JCGroup -Type User | Get-JCUserGroupMember
        $AllUserGroupmembers.GroupName.Count | Should -BeGreaterThan 1
    }

}
Describe 'New-JCSystemGroup and Remove-JCSystemGroup'{

    It "Creates a new system group"{
        $NewG =  New-JCSystemGroup -GroupName $NewJCSystemGroup
        $NewG.Result | Should -Be 'Created'
    }

    It "Removes a system group with warning"{
        $DeletedG = Remove-JCSystemGroup -GroupName $NewJCSystemGroup
        $DeletedG.Result | Should -Be 'Deleted'
    }

    It "Creates a new system group"{
        $NewG =  New-JCSystemGroup -GroupName $NewJCSystemGroup
        $NewG.Result | Should -Be 'Created'
    }

    It "Removes a system group with -force paramter"{
        $DeletedG = Remove-JCSystemGroup -GroupName $NewJCSystemGroup -force
        $DeletedG.Result | Should -Be 'Deleted'
    }

}

Describe 'New-JCUserGroup and Remove-JCUserGroup'{

    It "Creates a new User group"{
        $NewG =  New-JCUserGroup -GroupName $NewJCUserGroup
        $NewG.Result | Should -Be 'Created'
    }

    It "Removes a User group with warning"{
        $DeletedG = Remove-JCUserGroup -GroupName $NewJCUserGroup
        $DeletedG.Result | Should -Be 'Deleted'
    }

    It "Creates a new User group"{
        $NewG =  New-JCUserGroup -GroupName $NewJCUserGroup
        $NewG.Result | Should -Be 'Created'
    }

    It "Removes a User group with -force paramter"{
        $DeletedG = Remove-JCUserGroup -GroupName $NewJCUserGroup -force
        $DeletedG.Result | Should -Be 'Deleted'
    }

}

#endregion Groups pester test

#region Systems Pester test

#region Systems data validation

$Systems = Get-JCSystem

if ($($Systems._id.Count) -le 1)
{Write-Error 'You must have at least 2 JumpCloud systems to run the Pester tests';break}

#endregion Systems data validation


Describe 'Add-JCSystemUser and Remove-JCSystemUser'{

    IT "Adds a single user to a single system by Username and SystemID"{
        $UserAdd = Add-JCSystemUser -Username $Username -SystemID $SystemID
        $UserAdd.Status | Should Be 'Added'
    }

    IT "Removes a single user froma single system by Username and SystemID with default warning"{
        $UserRemove = Remove-JCSystemUser -Username $Username -SystemID $SystemID
        $UserRemove.Status | Should Be 'Removed'
    }

    IT "Adds a single user to a single system by UserID and SystemID"{
        $UserAdd = Add-JCSystemUser -UserID $UserID -SystemID $SystemID
        $UserAdd.Status | Should Be 'Added'
    }

    IT "Removes a single user froma single system with -force parameter"{
        $UserRemove = Remove-JCSystemUser -Username $Username -SystemID $SystemID -force
        $UserRemove.Status | Should Be 'Removed'
    }

    IT "Adds two users to a single system using the pipeline and system ID"{
        $MultiUserAdd = Get-JCUser | Select-Object -Last 2 | Add-JCSystemUser -SystemID $SystemID
        $MultiUserAdd.Status.Count | Should Be 2
    }

    IT "Removes two users from a single system using the pipeline and system ID using the -force paramter"{
        $MultiUserRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCSystemUser -SystemID $SystemID -force
        $MultiUserRemove.Status.Count | Should Be 2
    }

    IT "Adds back two users to a single system using the pipeline and system ID"{
    $MultiUserAdd = Get-JCUser | Select-Object -Last 2 | Add-JCSystemUser -SystemID $SystemID
    $MultiUserAdd.Status.Count | Should Be 2
    }
}

Describe 'Get-JCSystem'{

    It "Gets all JumpCloud systems"{
        $Systems = Get-JCSystem
        $Systems._id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud system"{
        $SingleSystem = Get-JCSystem -ByID $SystemID
        $SingleSystem.id.Count | Should -be 1
    }

    It "Gets all JumpCloud systems -ByID using the pipeline"{
        $AllSystems = Get-JCSystem | Get-JCSystem -ByID
        $AllSystems.id.Count | Should -BeGreaterThan 1
    }
}

Describe 'Get-JCSystemUser'{

    IT "Gets JumpCloud system users for a system using SystemID"{

        $SystemUsers = Get-JCSystemUser -SystemID  $SystemID
        $SystemUsers.username.Count | Should -BeGreaterThan 1
    }

    IT "Gets all JumpCloud system user associations using Get-JCsystem and the pipeline"{

        $AllSystemUsers = Get-JCSystem | Get-JCSystemUser
        $Systems = $AllSystemUsers.SystemID | Select-Object -Unique | Measure-Object
        $Systems.Count| Should -BeGreaterThan 1
    }
}

Describe 'Remove-JCSystem'{

    It "Removes a JumpCloud system with the default warning (Halted with H)"{

        {Remove-JCSystem -SystemID $SystemID} | Should -Throw
    }

}
Describe 'Set-JCSystem'{

    It "Updates the DisplyName and then set it back"{
        $CurrentDisplayName = Get-JCSystem -SystemID $SystemID | Select-Object DisplayName
        $UpdatedSystem = Set-JCSystem -SystemID $SystemID -displayName 'NewName'
        $UpdatedSystem.displayName | Should -be 'NewName'
        Set-JCSystem -SystemID $SystemID -displayName $CurrentDisplayName.displayName | Out-Null

    }

    It "Updates a system SshPasswordAuthentication -eq True"{
        $Update = Set-JCSystem -SystemID $SystemID -allowSshPasswordAuthentication $true
        $Update.allowSshPasswordAuthentication | Should -Be True
    }

    It "Updates a system SshPasswordAuthentication -eq False"{
        $Update = Set-JCSystem -SystemID $SystemID -allowSshPasswordAuthentication $false
        $Update.allowSshPasswordAuthentication | Should -Be False
    }

    It "Updates a system allowSshRootLogin -eq True"{
        $Update = Set-JCSystem -SystemID $SystemID -allowSshRootLogin $true
        $Update.allowSshRootLogin | Should -Be True
    }

    It "Updates a system allowSshRootLogin -eq False"{
        $Update = Set-JCSystem -SystemID $SystemID -allowSshRootLogin $false
        $Update.allowSshRootLogin | Should -Be False
    }
    It "Updates a system allowMultiFactorAuthentication -eq True"{
        $Update = Set-JCSystem -SystemID $SystemID -allowMultiFactorAuthentication $true
        $Update.allowMultiFactorAuthentication | Should -Be True
    }

    It "Updates a system allowMultiFactorAuthentication -eq False"{
        $Update = Set-JCSystem -SystemID $SystemID -allowMultiFactorAuthentication $false
        $Update.allowMultiFactorAuthentication | Should -Be False
    }

    It "Updates a system allowPublicKeyAuthentication -eq True"{
        $Update = Set-JCSystem -SystemID $SystemID -allowPublicKeyAuthentication $true
        $Update.allowPublicKeyAuthentication | Should -Be True
    }

    It "Updates a system allowPublicKeyAuthentication -eq False"{
        $Update = Set-JCSystem -SystemID $SystemID -allowPublicKeyAuthentication $false
        $Update.allowPublicKeyAuthentication | Should -Be False
    }
}
#Purposefully left off Remove-JCSystem -force (I don't have enough systems to test with)

#endregion Systems Pester test

#region Users Pester test

#region Users data validation

$Users = Get-JCUser

if ($($Users._id.Count) -le 1)
{Write-Error 'You must have at least 2 JumpCloud users to run the Pester tests';break}

#endregion Users data validation


Describe 'Get-JCUser'{

    IT "Gets all JumpCloud users using Get-JCuser"{$Users = Get-JCUser
    $Users._id.count | Should -BeGreaterThan 1}

    IT 'Get a single JumpCloud user by Username'{
        $User = Get-JCUser -Username $Username
        $User._id.count | Should -Be 1
    }

    IT 'Get a single JumpCloud user by UserID'{
        $User = Get-JCUser -UserID $UserID
        $User._id.count | Should -Be 1
    }

    IT 'Get multiple JumpCloud users via the pipeline using -ByID'{
        $Users = Get-JCUser | Select-Object -Last 2 | Get-JCUser -ByID
        $Users._id.count | Should -Be 2
    }
}


Describe 'New-JCUser and Remove-JCuser'{

    It "Creates a new user"{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $NewUser._id.count | Should -Be 1
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new user and then deletes them"{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
        $DeleteUser = Remove-JCUser -UserID $NewUser._id -ByID -Force
        $DeleteUser.results | Should -be 'Deleted'
    }

    It "Creates a new User allow_public_key -eq True "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -allow_public_key $true
        $NewUser.allow_public_key | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User allow_public_key -eq False "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -allow_public_key $false
        $NewUser.allow_public_key | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sudo -eq True "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -sudo $true
        $NewUser.sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sudo -eq False "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -sudo $false
        $NewUser.sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_managed_uid -eq True "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_managed_uid $true
        $NewUser.enable_managed_uid | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_managed_uid -eq False "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_managed_uid $false
        $NewUser.enable_managed_uid | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User passwordless_sudo -eq True "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -passwordless_sudo $true
        $NewUser.passwordless_sudo | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User passwordless_sudo -eq False "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -passwordless_sudo $false
        $NewUser.passwordless_sudo | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }


    It "Creates a new User ldap_binding_user -eq True "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -ldap_binding_user $true
        $NewUser.ldap_binding_user | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User ldap_binding_user -eq False "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -ldap_binding_user $false
        $NewUser.ldap_binding_user | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_user_portal_multifactor -eq True "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_user_portal_multifactor $true
        $NewUser.enable_user_portal_multifactor | Should -Be True
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User enable_user_portal_multifactor -eq False "{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -enable_user_portal_multifactor $false
        $NewUser.enable_user_portal_multifactor | Should -Be False
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sets unix_uid"{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -unix_uid 100
        $NewUser.unix_uid | Should -Be 100
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User sets unix_guid"{
        $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser  -unix_guid 100
        $NewUser.unix_guid | Should -Be 100
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User with 1 custom attributes"{
        $NewUser = New-RandomUser -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 1
        $NewUser.attributes._id.Count | Should -Be 1
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Creates a new User with 3 custom attributes"{
        $NewUser = New-RandomUser -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 3
        $NewUser.attributes._id.Count | Should -Be 3
        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }
}

Describe 'Set-JCUser'{

    IT "Updates the firstname and then sets it back using -ByID and -UserID"{
        $CurrentFirstName = Get-JCUser -ByID -UserID $UserID | Select-Object firstname
        $NewFirstName = Set-JCUser -ByID -UserID $UserID -firstname 'NewFirstName'
        $NewFirstName.firstname | Should -be 'NewFirstName'
        Set-JCUser -ByID -UserID $UserID -firstname $CurrentFirstName.firstname | Out-Null

    }

    IT "Updates the firstname and then sets it back using -Username"{
        $CurrentFirstName = Get-JCUser -ByID -UserID $UserID | Select-Object firstname
        $NewFirstName = Set-JCUser -Username $Username -firstname 'NewFirstName'
        $NewFirstName.firstname | Should -be 'NewFirstName'
        Set-JCUser -ByID -UserID $UserID -firstname $CurrentFirstName.firstname | Out-Null

    }

    IT "Updates the lastname and then sets it back using -ByID and -UserID"{
        $Currentlastname = Get-JCUser -ByID -UserID $UserID | Select-Object lastname
        $Newlastname = Set-JCUser -ByID -UserID $UserID -lastname 'NewLastName'
        $Newlastname.lastname | Should -be 'NewLastName'
        Set-JCUser -ByID -UserID $UserID -lastname $Currentlastname.lastname | Out-Null

    }

    IT "Updates the lastname and then sets it back using -Username"{
        $Currentlastname = Get-JCUser -ByID -UserID $UserID | Select-Object lastname
        $Newlastname = Set-JCUser -Username $Username -lastname 'NewLastName'
        $Newlastname.lastname | Should -be 'NewLastName'
        Set-JCUser -ByID -UserID $UserID -lastname $Currentlastname.lastname | Out-Null

    }

    IT "Updates the email and then sets it back using -ByID and -UserID"{
        $Currentemail = Get-JCUser -ByID -UserID $UserID | Select-Object email
        $Newemail = Set-JCUser -ByID -UserID $UserID -email $RandomEmail
        $Newemail.email | Should -be $RandomEmail
        Set-JCUser -ByID -UserID $UserID -email $Currentemail.email | Out-Null

    }

    IT "Updates the email and then sets it back using -Username"{
        $Currentemail = Get-JCUser -ByID -UserID $UserID | Select-Object email
        $Newemail = Set-JCUser -Username $Username -email $RandomEmail
        $Newemail.email | Should -be $RandomEmail
        Set-JCUser -ByID -UserID $UserID -email $Currentemail.email | Out-Null

    }

    IT "Updates the password using -ByID and -UserID"{

        {Set-JCUser -ByID -UserID $UserID -password 'Temp123!'} | Should -Not -Throw

    }

    IT "Updates the password using -Username"{

        {Set-JCUser -Username $username -password 'Temp123!'} | Should -Not -Throw

    }

    It "Updates a User allow_public_key -eq True using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -allow_public_key $true
        $Update.allow_public_key | Should -Be True
    }

    It "Updates a User allow_public_key -eq False using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -allow_public_key $false
        $Update.allow_public_key | Should -Be False
    }

    It "Updates a User allow_public_key -eq True using -Username"{
        $Update = Set-JCUser -Username $Username -allow_public_key $true
        $Update.allow_public_key | Should -Be True
    }

    It "Updates a User allow_public_key -eq False using -Username"{
        $Update = Set-JCUser -Username $Username -allow_public_key $false
        $Update.allow_public_key | Should -Be False
    }

    It "Updates a User sudo -eq True using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -sudo $true
        $Update.sudo | Should -Be True
    }

    It "Updates a User sudo -eq False using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -sudo $false
        $Update.sudo | Should -Be False
    }

    It "Updates a User sudo -eq True using -Username"{
        $Update = Set-JCUser -Username $Username -sudo $true
        $Update.sudo | Should -Be True
    }

    It "Updates a User sudo -eq False using -Username"{
        $Update = Set-JCUser -Username $Username -sudo $false
        $Update.sudo | Should -Be False
    }

    It "Updates a User enable_managed_uid -eq True using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -enable_managed_uid $true
        $Update.enable_managed_uid | Should -Be True
    }

    It "Updates a User enable_managed_uid -eq False using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -enable_managed_uid $false
        $Update.enable_managed_uid | Should -Be False
    }

    It "Updates a User enable_managed_uid -eq True using -Username"{
        $Update = Set-JCUser -Username $Username -enable_managed_uid $true
        $Update.enable_managed_uid | Should -Be True
    }

    It "Updates a User enable_managed_uid -eq False using -Username"{
        $Update = Set-JCUser -Username $Username -enable_managed_uid $false
        $Update.enable_managed_uid | Should -Be False
    }

    It "Updates a User account_locked -eq True using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -account_locked $true
        $Update.account_locked | Should -Be True
    }

    It "Updates a User account_locked -eq False using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -account_locked $false
        $Update.account_locked | Should -Be False
    }

    It "Updates a User account_locked -eq True using -Username"{
        $Update = Set-JCUser -Username $Username -account_locked $true
        $Update.account_locked | Should -Be True
    }

    It "Updates a User account_locked -eq False using -Username"{
        $Update = Set-JCUser -Username $Username -account_locked $false
        $Update.account_locked | Should -Be False
    }
    It "Updates a User passwordless_sudo -eq True using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -passwordless_sudo $true
        $Update.passwordless_sudo | Should -Be True
    }

    It "Updates a User passwordless_sudo -eq False using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -passwordless_sudo $false
        $Update.passwordless_sudo | Should -Be False
    }

    It "Updates a User passwordless_sudo -eq True using -Username"{
        $Update = Set-JCUser -Username $Username -passwordless_sudo $true
        $Update.passwordless_sudo | Should -Be True
    }

    It "Updates a User passwordless_sudo -eq False using -Username"{
        $Update = Set-JCUser -Username $Username -passwordless_sudo $false
        $Update.passwordless_sudo | Should -Be False
    }

    It "Updates a User externally_managed -eq True using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -externally_managed $true
        $Update.externally_managed | Should -Be True
    }

    It "Updates a User externally_managed -eq False using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -externally_managed $false
        $Update.externally_managed | Should -Be False
    }

    It "Updates a User externally_managed -eq True using -Username"{
        $Update = Set-JCUser -Username $Username -externally_managed $true
        $Update.externally_managed | Should -Be True
    }

    It "Updates a User externally_managed -eq False using -Username"{
        $Update = Set-JCUser -Username $Username -externally_managed $false
        $Update.externally_managed | Should -Be False
    }

    It "Updates a User ldap_binding_user -eq True using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -ldap_binding_user $true
        $Update.ldap_binding_user | Should -Be True
    }

    It "Updates a User ldap_binding_user -eq False using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -ldap_binding_user $false
        $Update.ldap_binding_user | Should -Be False
    }

    It "Updates a User ldap_binding_user -eq True using -Username"{
        $Update = Set-JCUser -Username $Username -ldap_binding_user $true
        $Update.ldap_binding_user | Should -Be True
    }

    It "Updates a User ldap_binding_user -eq False using -Username"{
        $Update = Set-JCUser -Username $Username -ldap_binding_user $false
        $Update.ldap_binding_user | Should -Be False
    }
    It "Updates a User enable_user_portal_multifactor -eq True using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -enable_user_portal_multifactor $true
        $Update.enable_user_portal_multifactor | Should -Be True
    }

    It "Updates a User enable_user_portal_multifactor -eq False using -ByID and -UserID"{
        $Update = Set-JCUser -ByID -UserID $UserID -enable_user_portal_multifactor $false
        $Update.enable_user_portal_multifactor | Should -Be False
    }

    It "Updates a User enable_user_portal_multifactor -eq True using -Username"{
        $Update = Set-JCUser -Username $Username -enable_user_portal_multifactor $true
        $Update.enable_user_portal_multifactor | Should -Be True
    }

    It "Updates a User enable_user_portal_multifactor -eq False using -Username"{
        $Update = Set-JCUser -Username $Username -enable_user_portal_multifactor $false
        $Update.enable_user_portal_multifactor | Should -Be False
    }


    IT "Updates the unix_uid and then sets it back using -ByID and -UserID"{
        $Currentunix_uid = Get-JCUser -ByID -UserID $UserID | Select-Object unix_uid
        $100 = Set-JCUser -ByID -UserID $UserID -unix_uid '100'
        $100.unix_uid | Should -be '100'
        Set-JCUser -ByID -UserID $UserID -unix_uid $Currentunix_uid.unix_uid | Out-Null

    }

    IT "Updates the unix_uid and then sets it back using -Username"{
        $Currentunix_uid = Get-JCUser -ByID -UserID $UserID | Select-Object unix_uid
        $100 = Set-JCUser -Username $Username -unix_uid '100'
        $100.unix_uid | Should -be '100'
        Set-JCUser -ByID -UserID $UserID -unix_uid $Currentunix_uid.unix_uid | Out-Null

    }

    IT "Updates the unix_guid and then sets it back using -ByID and -UserID"{
        $Currentunix_guid = Get-JCUser -ByID -UserID $UserID | Select-Object unix_guid
        $100 = Set-JCUser -ByID -UserID $UserID -unix_guid '100'
        $100.unix_guid | Should -be '100'
        Set-JCUser -ByID -UserID $UserID -unix_guid $Currentunix_guid.unix_guid | Out-Null

    }

    IT "Updates the unix_guid and then sets it back using -Username"{
        $Currentunix_guid = Get-JCUser -ByID -UserID $UserID | Select-Object unix_guid
        $100 = Set-JCUser -Username $Username -unix_guid '100'
        $100.unix_guid | Should -be '100'
        Set-JCUser -ByID -UserID $UserID -unix_guid $Currentunix_guid.unix_guid | Out-Null

    }
}

Describe "Set-JCUser - CustomAttributes"{

    It "Updates a custom attribute on a User"{
        $NewUser = New-RandomUser -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 3
        $UpdatedUser = Set-JCUser $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'Department' -Attribute1_value 'IT'

        [string]$NewUserAttr = $NewUser.attributes.name | Sort-Object
        [string]$UpdatedUserAttr = $UpdatedUser.attributes.name | Sort-Object

        $match = if($NewUserAttr -eq $UpdatedUserAttr) {$true}
            else {
                $false
            }

        $match | Should -be $true

        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Adds a custom attribute to a User"{
        $NewUser = New-RandomUser -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 3
        $UpdatedUser = Set-JCUser $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'NewAttribute' -Attribute1_value 'IT'

        [int]$NewUserAttr = $NewUser.attributes.name.count
        [int]$UpdatedUserAttr = $UpdatedUser.attributes.name.count

        $NewUserAttr ++

        $match = if($NewUserAttr -eq $UpdatedUserAttr) {$true}
            else {
                $false
            }

        $match | Should -be $true

        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }

    It "Removes a custom attribute from a User"{
        $NewUser = New-RandomUser -Attributes -Domain DeleteMe | New-JCUser -NumberOfCustomAttributes 3
        $UpdatedUser = Set-JCUser $NewUser.username -RemoveAttribute 'Department'

        [int]$NewUserAttr = $NewUser.attributes.name.count
        [int]$UpdatedUserAttr = $UpdatedUser.attributes.name.count

        $UpdatedUserAttr++

        $match = if($NewUserAttr -eq $UpdatedUserAttr) {$true}
            else {
                $false
            }

        $match | Should -be $true

        Remove-JCUser -UserID $NewUser._id -ByID -Force
    }


}



#endregion Users Pester test