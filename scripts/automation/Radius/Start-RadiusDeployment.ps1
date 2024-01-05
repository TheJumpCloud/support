# Import Global Config:
Write-Verbose 'Verifying JCAPI Key'
if ($JCAPIKEY.length -ne 40) {
    Connect-JCOnline -force
}
. "$psscriptroot/config.ps1"

################################################################################
# Do not modify below
################################################################################
# set script root
#TODO: move to global functions
$global:JCScriptRoot = $PSScriptRoot

# Import the functions
Import-Module "$JCScriptRoot/Functions/JCRadiusCertDeployment.psm1" -DisableNameChecking -Force

# Show user selection
do {
    #Output-Certs
    Show-RadiusMainMenu
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' {
            Generate-RootCert
        } '2' {
            Generate-UserCerts
        } '3' {
            Distribute-UserCerts
        } '4' {
            Monitor-CertDeployment
        } '5' {
            Get-JCRGlobalVars -force
        }
    }
    Pause
} until ($selection.ToUpper() -eq 'Q')