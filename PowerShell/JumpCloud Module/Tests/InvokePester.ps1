. "$PSScriptRoot/HelperFunctions.ps1"
. "$PSScriptRoot/TestEnvironmentVariables.ps1"

Connect-JCOnline $TestOrgAPIKey

$PesterResults = Invoke-Pester -Script @{ Path = $PSScriptRoot; Parameters = $PesterParms; } -PassThru