function Start-RadiusDeployment {
    # Import Global Config:
    Write-Verbose 'Verifying JCAPI Key'
    if ($JCAPIKEY.length -ne 40) {
        Connect-JCOnline -force
    }

    # validate the setting from the module have been set
    Confirm-JCRConfigFile -ErrorAction stop

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
            } '8' {
                Get-JCRGlobalVars -force -associateManually
            } '9' {
                $theUser = Read-Host "Enter the username of the user to manually update their association data"
                Get-JCRGlobalVars -force -associationUsername $theUser
            }
        }
        Pause
    } until ($selection.ToUpper() -eq 'Q')
}