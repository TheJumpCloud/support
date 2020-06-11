Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$TestOrgAPIKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$MultiTenantAPIKey
)
$VariableNamePrefix = 'PesterParams_'
$VariableNamePrefixHash = 'PesterParamsHash_'
# Authenticate to JumpCloud
Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
# Determine OS type
$OS = If ($env:AGENT_OS)
{
    $env:AGENT_OS
}
Else
{
    If ($PSVersionTable.PSEdition -eq 'Core')
    {
        If ($IsWindows) { 'Windows_NT' }
        ElseIf ($IsMacOS) { 'Darwin' }
        ElseIf ($IsLinux) { 'Linux' }
        Else { Write-Error ('Unknown Operation System') }
    }
    Else
    {
        'Windows_NT'
    }
}
# Set test parameters bases on os
$PesterParamsHash_OS = If ($OS -eq 'Windows_NT')
{
    @{
        'ApiKey'                   = $TestOrgAPIKey
        'ApiKeyMsp'                = $MultiTenantAPIKey
        'OrgIdMsp1'                = "5d2f6ff0e7aad925fc317577"
        'OrgIdMsp2'                = "5d2f6ffd8910770b8545756a"
        'SystemID'                 = '5e4c67d7933afe1cd17a6583' # Enter the System ID for a linux system
        'SystemId_Windows'         = '5d24be43c9448f245effa736'
        'SystemId_Mac'             = '5d24af30e72dab44aee39426'
        'CommandID'                = '5a4fe5c149812520079d1e7a'
        # Command Deployments
        'SetCommandID'             = "5b7194548781bb466496fe2f" #Pester - Set-JCCommand
        'DeployCommandID'          = "5b719043bc43db696b4dbd90" #Invoke JCDeployment Test
        # Policies
        'SystemWithPolicyResultID' = "5c2e2d012a28b62befe395a3"
        NewRadiusServerIp          = '250.250.250.250'
    }
}
ElseIf ($OS -eq 'Darwin')
{
    @{
        'OrgIdMsp1'                = "5d2f7011f3b0a039b65f4e8b"
        'OrgIdMsp2'                = "5d2f701be7aad925fc317667"
        'SystemID'                 = '5ece896d3063492783d0f540' # Enter the System ID for a linux system
        'SystemId_Windows'         = '5ec300ed58c6c807bbde5712'
        'SystemId_Mac'             = '5ec3f0ad518f1814e2b1aee5'
        'CommandID'                = '5ec44422bb57ae79a5d0ef1a'
        # Command Deployments
        'SetCommandID'             = "5ec699ad1bccb46c80d891a2" #Pester - Set-JCCommand
        'DeployCommandID'          = "5ec32efb5a797e17deda0551" #Invoke JCDeployment Test
        # Policies
        'SystemWithPolicyResultID' = "5ec40d537b7ff91360386bc4"
        NewRadiusServerIp          = '250.251.250.251'
    }
}
ElseIf ($OS -eq 'Linux')
{
    @{
        'OrgIdMsp1'                = "5d2f7024f0e1526be4df38e7"
        'OrgIdMsp2'                = "5d35e14eb90ad46e65ba0739"
        'SystemID'                 = '5ece89f65723050e98242113' # Enter the System ID for a linux system
        'SystemId_Windows'         = '5ecd8b313778a13c9bd90eb8'
        'SystemId_Mac'             = '5ecd8a4cdfef2d0a9ec39883'
        'CommandID'                = '5ecd8d279a9c6a2495c4833f'
        # Command Deployments
        'SetCommandID'             = "5ecd8ee2454ad57c2152593a" #Pester - Set-JCCommand
        'DeployCommandID'          = "5ecd8e3352b7211df60f9646" #Invoke JCDeployment Test
        # Policies
        'SystemWithPolicyResultID' = "5ecd8b0e40f99e14ac2c66d3"
        NewRadiusServerIp          = '250.252.250.252'
    }
}
Else
{
    Write-Error ("Unknown OS: $($OS)")
}

# Parameters that are not Org specific
$PesterParamsHash_Common = @{
    PesterResultsFileXml            = "$($PSScriptRoot)/JumpCloud-$($OS)-TestResults.xml"
    UserLastName                    = 'Test'
    OneTrigger                      = 'onetrigger'
    TwoTrigger                      = 'twotrigger'
    ThreeTrigger                    = 'threetrigger'
    Groups                          = @('One', 'Two', 'Three', 'Four', 'Five', 'Six')
    # CSV Files
    Import_JCUsersFromCSV_1_1_Tests = "$PSScriptRoot/Csv_Files/import/ImportExample_Pester_Tests_1.1.0.csv" # This CSV file is specific to pester environment (SystemID's and Group Names)
    JCDeployment_2_CSV              = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_2.csv"
    JCDeployment_10_CSV             = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_10.csv"
    ImportPath                      = "$PSScriptRoot/Csv_Files/import"
    UpdatePath                      = "$PSScriptRoot/Csv_Files/update"
    # Policy Info
    MultiplePolicyList              = @('1 Linux', 'Disable USB Storage - Linux')
    SinglePolicyList                = @('Disable USB Storage - Linux')
    CommandTrigger                  = 'GetJCAgentLog'
    CommandResultCount              = 10
    SystemNameLinux                 = 'PesterTest-Linux'
    SystemNameMac                   = 'PesterTest-Mac'
    SystemNameWindows               = 'PesterTest-Windows'
}
Function Remove-Org
{
    Param(
        [switch]$Users
        , [switch]$Systems
        # , [switch]$Policies
        , [switch]$Groups
        # , [switch]$Applications
        # , [switch]$Directories
        , [switch]$Commands
        , [switch]$RadiusServers
    )
    # Remove all users from an org
    If ($Users)
    {
        # $null = Get-JCUser | Set-JCUser -externally_managed $false
        # $null = Get-JCUser | Remove-JCUser -force
        $UserToRemove = Get-JCUser | Where-Object { $_.Email -like '*delete*' }
        $null = $UserToRemove | Remove-JCUser -force
        $UserToRemove = Get-JCUser | Where-Object { $_.Email -like '*delete*' }
        $null = $UserToRemove | Set-JCUser -externally_managed $false
        $null = $UserToRemove | Remove-JCUser -force
    }
    # Remove all systems from an org
    If ($Systems)
    {
        $null = Get-JCSystem | Remove-JCSystem -force
    }
    # Remove all groups from an org
    If ($Groups)
    {
        $null = Get-JCGroup | ForEach-Object { If ($_.Type -eq 'system_group') { Remove-JCSystemGroup -GroupName:($_.Name) -force }ElseIf ($_.Type -eq 'user_group') { Remove-JCUserGroup -GroupName:($_.Name) -force }Else { Write-Error('Unknown') } }
    }
    # Remove all Commands from an org
    If ($Commands)
    {
        $null = Get-JCCommand | Remove-JCCommand -force
    }
    # Remove all RadiusServers from an org
    If ($RadiusServers)
    {
        $null = Get-JCRadiusServer | Remove-JCRadiusServer -Force
    }
}
Remove-Org -Users -RadiusServers

# Define items
$RandomString1 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
$NewUser1 = @{
    username                 = "pester.tester1_$($RandomString1)"
    email                    = "$($RandomString1)1@DeleteMe.com"
    employeeIdentifier       = "employeeIdentifier_$($RandomString1)"
    allow_public_key         = $false
    password_never_expires   = $true
    NumberOfCustomAttributes = 1
    Attribute1_name          = 'One1'
    Attribute1_value         = 'Attr_1'
    company                  = 'company_1'
    costCenter               = 'costCenter_1'
    department               = 'department_1'
    description              = 'description_1'
    displayName              = 'displayName_1'
    employeeType             = 'employeeType_1'
    firstname                = 'Pester_1'
    home_city                = 'home_city_1'
    home_country             = 'home_country_1'
    home_number              = 'home_number_1'
    home_poBox               = 'home_poBox_1'
    home_postalCode          = 'home_postalCode_1'
    home_state               = 'home_state_1'
    home_streetAddress       = 'home_streetAddress_1'
    jobTitle                 = 'jobTitle_1'
    lastname                 = 'Tester_1'
    location                 = 'location_1'
    MiddleName               = 'middlename_1'
    mobile_number            = 'mobile_number_1'
    work_city                = 'work_city_1'
    work_country             = 'work_country_1'
    work_fax_number          = 'work_fax_number_1'
    work_mobile_number       = 'work_mobile_number_1'
    work_number              = 'work_number_1'
    work_poBox               = 'work_poBox_1'
    work_postalCode          = 'work_postalCode_1'
    work_state               = 'work_state_1'
    work_streetAddress       = 'work_streetAddress_1'
}
$RandomString2 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
$NewUser2 = @{
    username                 = "pester.tester2_$($RandomString2)"
    email                    = "$($RandomString2)2@DeleteMe.com"
    employeeIdentifier       = "employeeIdentifier_$($RandomString2)"
    allow_public_key         = $false
    password_never_expires   = $true
    NumberOfCustomAttributes = 1
    Attribute1_name          = 'One2'
    Attribute1_value         = 'Attr_2'
    company                  = 'company_2'
    costCenter               = 'costCenter_2'
    department               = 'department_2'
    description              = 'description_2'
    displayName              = 'displayName_2'
    employeeType             = 'employeeType_2'
    firstname                = 'Pester_2'
    home_city                = 'home_city_2'
    home_country             = 'home_country_2'
    home_number              = 'home_number_2'
    home_poBox               = 'home_poBox_2'
    home_postalCode          = 'home_postalCode_2'
    home_state               = 'home_state_2'
    home_streetAddress       = 'home_streetAddress_2'
    jobTitle                 = 'jobTitle_2'
    lastname                 = 'Tester_2'
    location                 = 'location_2'
    MiddleName               = 'middlename_2'
    mobile_number            = 'mobile_number_2'
    work_city                = 'work_city_2'
    work_country             = 'work_country_2'
    work_fax_number          = 'work_fax_number_2'
    work_mobile_number       = 'work_mobile_number_2'
    work_number              = 'work_number_2'
    work_poBox               = 'work_poBox_2'
    work_postalCode          = 'work_postalCode_2'
    work_state               = 'work_state_2'
    work_streetAddress       = 'work_streetAddress_2'
}
$NewSystemGroup = @{
    GroupName = 'PesterTest_SystemGroup'
}
$NewUserGroup = @{
    GroupName = 'PesterTest_UserGroup'
}
$NewRadiusServer = @{
    networkSourceIp = If ($env:USERNAME -eq 'VssAdministrator') { $PesterParamsHash_OS.NewRadiusServerIp } Else { [IPAddress]::Parse([String](Get-Random)).IPAddressToString }
    sharedSecret    = 'f3TkHSK2GT4JR!W9tugRPp2zQnAVObv'
    name            = 'PesterTest_RadiusServer'
}
# Setup org
$User1 = New-JCUser @NewUser1
$User2 = New-JCUser @NewUser2
$UserGroup = New-JCUserGroup @NewUserGroup
$SystemGroup = New-JCSystemGroup @NewSystemGroup
$RadiusServer = New-JCRadiusServer @NewRadiusServer
# If no command results currently exist
$CommandResultsExist = Get-JCCommandResult
If ([System.String]::IsNullOrEmpty($CommandResultsExist) -or $CommandResultsExist.Count -lt $PesterParamsHash_Common.CommandResultCount)
{
    $testCmd = Get-JCCommand | Where-Object { $_.trigger -eq $PesterParamsHash_Common.CommandTrigger }
    If ($testCmd)
    {
        Add-JCCommandTarget -CommandID $testCmd.id -SystemID $PesterParamsHash_OS.SystemID
        $TriggeredCommand = For ($i = 1; $i -le $PesterParamsHash_Common.CommandResultCount; $i++)
        {
            Invoke-JCCommand -trigger:($testCmd.name)
        }
        While ((Get-JCCommandResult | Where-Object { $_.Name -eq $testCmd.name }).Count -ge $PesterParamsHash_Common.CommandResultCount)
        {
            Start-Sleep -Seconds:(1)
        }
        Remove-JCCommandTarget -CommandID $testCmd.id -SystemID $PesterParamsHash_OS.SystemID
    }
    Else
    {
        Write-Error ("No command called $($PesterParamsHash_Common.CommandTrigger) has been setup.")
    }
}
# Params that need to run commands to get their values with inputs from other hash tables
$PesterParamsHash_Commands = @{
    RadiusServerName     = $RadiusServer.Name
    SystemGroupName      = $SystemGroup.Name
    UserGroupName        = $UserGroup.Name
    Username             = $User1.username
    UserID               = $User1.Id
    User1                = $User1
    NewUser1             = $NewUser1
    NewRadiusServer      = $NewRadiusServer
    OrgId                = (Get-JCOrganization).OrgID
    SinglePolicy         = Get-JCPolicy -Name:($PesterParamsHash_Common.SinglePolicyList)
    MultiplePolicy       = Get-JCPolicy -Name:($PesterParamsHash_Common.MultiplePolicyList)
    UserGroupID          = (Get-JCGroup -Type:('User') -Name:($UserGroup.Name)).id
    SystemGroupID        = (Get-JCGroup -Type:('System') -Name:($SystemGroup.Name)).id
    UserGroupMembership  = Add-JCUserGroupMember -GroupName:($UserGroup.Name) -Username:($User1.username)
    SystemUserMembership = If (Get-JCSystem -Id:($PesterParamsHash_OS.SystemID)) { Add-JCSystemUser -Username:($User1.Username) -SystemID:($PesterParamsHash_OS.SystemID) }
}

# Combine all hash tables into one list and foreach of their values create a new global parameter
(Get-Variable -Name:("$VariableNamePrefixHash*")).Value | ForEach-Object {
    $_.GetEnumerator() | ForEach-Object {
        Set-Variable -Name:("$($VariableNamePrefix)$($_.Name)") -Value:($_.Value) -Scope:('Global')
    }
}
