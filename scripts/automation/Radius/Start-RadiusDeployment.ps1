# Import Global Config:
. "$psscriptroot/Config.ps1"
Connect-JCOnline $JCAPIKEY -force

################################################################################
# Do not modify below
################################################################################
# set script root
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
            . "$JCScriptRoot/Functions/Public/Generate-RootCert.ps1"
        } '2' {
            . "$JCScriptRoot/Functions/Public/Generate-UserCerts.ps1"
        } '3' {
            . "$JCScriptRoot/Functions/Public/Distribute-UserCerts.ps1"
        } '4' {
            . "$JCScriptRoot/Functions/Public/Monitor-CertDeployment.ps1"
        }
    }
    Pause
} until ($selection.ToUpper() -eq 'Q')
