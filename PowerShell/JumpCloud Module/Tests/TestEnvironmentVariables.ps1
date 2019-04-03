. "$PSScriptRoot/HelperFunctions.ps1"

$ModuleManifestName = 'JumpCloud.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

$Random = New-RandomString '8'
$RandomEmail = "$Random@$Random.com"

$TestOrgAPIKey = ''

$PesterParams = @{

    'SystemID'        = '5c86aefb84dc720843b9bc7a' # Enter the System ID for a MACOS system

    'Username'        = 'pester.tester' # Create a user with username 'pester.tester'
    'UserID'          = '5ca5213d043ad378c6996b21' # Paste the UserID for the user with username pester.tester

    'UserGroupName'   = 'PesterTest_UserGroup'  #Create a user group named PesterTest_UserGroup within your environment
    'UserGroupID'     = '5ca50f961f247561cfc325a3'  # Paste the corresponding GroupID for the user group named PesterTest_UserGroup

    'SystemGroupName' = 'PesterTest_SystemGroup' # Create a sytem group named PesterTest_SystemGroup within your environment
    'SystemGroupID'   = '5ca50fa71f247561cfc325a5'  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup

}