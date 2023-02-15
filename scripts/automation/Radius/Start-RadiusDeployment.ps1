# Import Global Config:
. "$psscriptroot/config.ps1"
Connect-JCOnline $JCAPIKEY -force

################################################################################
# Do not modify below
################################################################################
# Import the functions
Import-Module "$psscriptroot/RadiusCertFunctions.ps1" -Force

# Show user selection
do {
    Show-RadiusMainMenu
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' {
            . "$psscriptroot/Generate-RootCert.ps1"
        } '2' {
            . "$psscriptroot/Generate-UserCerts.ps1"
        } '3' {
            . "$psscriptroot/Distribute-UserCerts.ps1"
        } '4' {
            . "$psscriptroot/Monitor-CertDeployment.ps1"
        }
    }
    Pause
} until ($selection.ToUpper() -eq 'Q')