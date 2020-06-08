Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$TestOrgAPIKey
)
$VariableNamePrefix = 'PesterParams_'
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
$PesterParams_OS = If ($OS -eq 'Windows_NT')
{
    @{
        # Specific to MTP portal
        'SingleTernateOrgId'       = '5a4bff7ab17d0c9f63bcd277'
        'MultiTernateOrgId1'       = "5d2f6ff0e7aad925fc317577"
        'MultiTernateOrgId2'       = "5d2f6ffd8910770b8545756a"
        'SystemID'                 = '5e4c67d7933afe1cd17a6583' # Enter the System ID for a linux system
        'SystemId_Windows'         = '5d24be43c9448f245effa736'
        'SystemId_Mac'             = '5d24af30e72dab44aee39426'
        'UserID'                   = '5a4c0216fbd238d531f253a6' # Paste the UserID for the user with username pester.tester
        'UserGroupID'              = '5a4f72bcc911807e553dfa1b'  # Paste the corresponding GroupID for the user group named PesterTest_UserGroup
        'SystemGroupID'            = '5a4fe3df45886d6c62ee188f'  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup
        'CommandID'                = '5a4fe5c149812520079d1e7a'
        # Command Deployments
        'SetCommandID'             = "5b7194548781bb466496fe2f" #Pester - Set-JCCommand
        'DeployCommandID'          = "5b719043bc43db696b4dbd90" #Invoke JCDeployment Test
        # Policies
        'SystemWithPolicyResultID' = "5c2e2d012a28b62befe395a3"
    }
}
ElseIf ($OS -eq 'Darwin')
{
    @{
        # Specific to MTP portal
        'SingleTernateOrgId'       = '5eb2ebea87b5ba160c16857a'
        'MultiTernateOrgId1'       = "5d2f7011f3b0a039b65f4e8b"
        'MultiTernateOrgId2'       = "5d2f701be7aad925fc317667"
        'SystemID'                 = '5ece896d3063492783d0f540' # Enter the System ID for a linux system
        'SystemId_Windows'         = '5ec300ed58c6c807bbde5712'
        'SystemId_Mac'             = '5ec3f0ad518f1814e2b1aee5'
        'UserID'                   = '5ec30ef936119c0892d550e1' # Paste the UserID for the user with username pester.tester
        'UserGroupID'              = '5ec30f201f247540bf7e2159'  # Paste the corresponding GroupID for the user group named PesterTest_UserGroup
        'SystemGroupID'            = '5ec30f77232e1156647f2ff3'  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup
        'CommandID'                = '5ec44422bb57ae79a5d0ef1a'
        # Command Deployments
        'SetCommandID'             = "5ec699ad1bccb46c80d891a2" #Pester - Set-JCCommand
        'DeployCommandID'          = "5ec32efb5a797e17deda0551" #Invoke JCDeployment Test
        # Policies
        'SystemWithPolicyResultID' = "5ec40d537b7ff91360386bc4"
    }
}
ElseIf ($OS -eq 'Linux')
{
    @{
        # Specific to MTP portal
        'SingleTernateOrgId'       = '5ebeb8c7de6f1e713e19cfba'
        'MultiTernateOrgId1'       = "5d2f7024f0e1526be4df38e7"
        'MultiTernateOrgId2'       = "5d35e14eb90ad46e65ba0739"
        'SystemID'                 = '5ece89f65723050e98242113' # Enter the System ID for a linux system
        'SystemId_Windows'         = '5ecd8b313778a13c9bd90eb8'
        'SystemId_Mac'             = '5ecd8a4cdfef2d0a9ec39883'
        'UserID'                   = '5ecd8bb3454ad57c2151ecff' # Paste the UserID for the user with username pester.tester
        'UserGroupID'              = '5ecd8c66232e1133edc880df'  # Paste the corresponding GroupID for the user group named PesterTest_UserGroup
        'SystemGroupID'            = '5ecd8c471f24751b14c33daf'  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup
        'CommandID'                = '5ecd8d279a9c6a2495c4833f'
        # Command Deployments
        'SetCommandID'             = "5ecd8ee2454ad57c2152593a" #Pester - Set-JCCommand
        'DeployCommandID'          = "5ecd8e3352b7211df60f9646" #Invoke JCDeployment Test
        # Policies
        'SystemWithPolicyResultID' = "5ecd8b0e40f99e14ac2c66d3"
    }
}
Else
{
    Write-Error ("Unknown OS: $($OS)")
}
# Parameters that are on Org specific
$PesterParams_Common = @{
    PesterResultsFileXml            = "$($PSScriptRoot)/JumpCloud-$($OS)-TestResults.xml"
    SystemGroupName                 = 'PesterTest_SystemGroup'
    RadiusServerName                = 'PesterTest_RadiusServer';
    OneTrigger                      = 'onetrigger'
    TwoTrigger                      = 'twotrigger'
    ThreeTrigger                    = 'threetrigger'
    UserGroupName                   = 'PesterTest_UserGroup'  #Create a user group named PesterTest_UserGroup within your environment
    Username                        = 'pester.tester' # Create a user with username 'pester.tester'
    # Generate random string
    RandomString                    = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
    # CSV Files
    Import_JCUsersFromCSV_1_1_Tests = "$PSScriptRoot/Csv_Files/import/ImportExample_Pester_Tests_1.1.0.csv" # This CSV file is specific to pester environment (SystemID's and Group Names)
    JCDeployment_2_CSV              = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_2.csv"
    JCDeployment_10_CSV             = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_10.csv"
    ImportPath                      = "$PSScriptRoot/Csv_Files/import"
    UpdatePath                      = "$PSScriptRoot/Csv_Files/update"
    # Policy Info
    MultiplePolicyList              = @('1 Linux', 'Disable USB Storage - Linux')
    SinglePolicyList                = @('Disable USB Storage - Linux')
}
# Params that need to run commands to get their values with inputs from other hash tables
$PesterParams_Commands = @{
    RandomEmail    = '{0}@{1}.com' -f $PesterParams_Common.RandomString, $PesterParams_Common.RandomString
    SinglePolicy   = Get-JCPolicy -Name:($PesterParams_Common.SinglePolicyList)
    MultiplePolicy = Get-JCPolicy -Name:($PesterParams_Common.MultiplePolicyList)
}

# Combine all hash tables into one list and foreach of their values create a new global parameter
(Get-Variable -Name:("$VariableNamePrefix*")).Value | ForEach-Object {
    $_.GetEnumerator() | ForEach-Object {
        Set-Variable -Name:("$($VariableNamePrefix)$($_.Name)") -Value:($_.Value) -Scope:('Global')
    }
}
