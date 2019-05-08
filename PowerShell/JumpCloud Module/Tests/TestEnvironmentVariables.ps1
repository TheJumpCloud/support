. "$PSScriptRoot/HelperFunctions.ps1"

$ModuleManifestName = 'JumpCloud.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

$TestOrgAPIKey = "" 

$MultiTenanntAPIKey = ""

$PesterParams = @{

    # Specific to MTP portal
    'MultiTenanntOrgID1' = "5b5a13f06fefdb0a29b0d306"
    'MultiTenanntOrgID2' = "5b5a14d13f852310b1d689b1"

    'SystemID'           = '5c2e83b2bc6fe97784a8749b' # Enter the System ID for a linux system
    'Username'           = 'pester.tester' # Create a user with username 'pester.tester'
    'UserID'             = '5a4c0216fbd238d531f253a6' # Paste the UserID for the user with username pester.tester

    'UserGroupName'      = 'PesterTest_UserGroup'  #Create a user group named PesterTest_UserGroup within your environment
    'UserGroupID'        = '5a4f72bcc911807e553dfa1b'  # Paste the corresponding GroupID for the user group named PesterTest_UserGroup

    'SystemGroupName'    = 'PesterTest_SystemGroup' # Create a sytem group named PesterTest_SystemGroup within your environment
    'SystemGroupID'      = '5a4fe3df45886d6c62ee188f'  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup

    'CommandID'          = '5a4fe5c149812520079d1e7a'

    # Specific to pester environment
    'OneTrigger'         = 'onetrigger'
    'TwoTrigger'         = 'twotrigger'
    'ThreeTrigger'       = 'threetrigger'

    # Command Deployments

    'SetCommandID'       = "5b7194548781bb466496fe2f"
    'DeployCommandID'    = "5b719043bc43db696b4dbd90"
}

$Random = New-RandomString '8'
$RandomEmail = "$Random@$Random.com"

## CSV Files
$Import_JCUsersFromCSV_1_1_Tests = "$PSScriptRoot/csv_files/import/ImportExample_Pester_Tests_1.1.0.csv" # This CSV file is specific to pester environment (SystemID's and Group Names)

$JCDeployment_2_CSV = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_2.csv"

$JCDeployment_10_CSV = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_10.csv"

$ImportPath = "$PSScriptRoot/Csv_files/import"

$UpdatePath = "$PSScriptRoot/Csv_files/update"

## Policy Info

$MultiplePolicyList = @('Disable Cortana 1', 'Disable Cortana 10', 'Disable Cortana 100', 'Disable USB Storage - Linux') #Populate with multiple policy names.
$SinglePolicyList = @('Disable USB Storage - Linux') #Populate with single policy name.
$Policies = Get-JCPolicy
$SystemIDWithPolicyResult = Get-JCSystem -SystemID '5a4c05ccaad9ac5f68b31022'
$SinglePolicy = $Policies | Where-Object { $_.Name -eq $SinglePolicyList }
$MultiplePolicy = $Policies | Where-Object { $_.Name -in $MultiplePolicyList }

