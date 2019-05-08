. "$PSScriptRoot/HelperFunctions.ps1"
. "$PSScriptRoot/TestEnvironmentVariables.ps1"


$PesterResults = Invoke-Pester -Script @{ Path = $PSScriptRoot; Parameters = $PesterParms; } -PassThru