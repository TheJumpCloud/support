. "$PSScriptRoot/HelperFunctions.ps1"
. "$PSScriptRoot/TestEnvironmentVariables.ps1"

Connect-JCOnline $TestOrgAPIKey

$PesterResults = Invoke-Pester -Script @{ Path = '/Users/sreed/Git/support/PowerShell/JumpCloud Module/Tests'; Parameters = $PesterParms; } -PassThru