# Import Global Config:
Write-Verbose 'Verifying JCAPI Key'
if ($JCAPIKEY.length -ne 40) {
    Connect-JCOnline -force
}
. "$psscriptroot/Config.ps1"

################################################################################
# Do not modify below
################################################################################
# set script root
#TODO: move to global functions
$global:JCScriptRoot = $PSScriptRoot

# Import the functions
Import-Module "$JCScriptRoot/JumpCloud-Radius.psm1" -DisableNameChecking -Force

# Show user selection
do {
    #Output-Certs
    Show-RadiusMainMenu
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' {
            Start-GenerateRootCert
        } '2' {
            Start-GenerateUserCerts
        } '3' {
            Start-DeployUserCerts
        } '4' {
            Start-MonitorCertDeployment
        } '5' {
            Get-JCRGlobalVars -force
        }
    }
    Pause
} until ($selection.ToUpper() -eq 'Q')