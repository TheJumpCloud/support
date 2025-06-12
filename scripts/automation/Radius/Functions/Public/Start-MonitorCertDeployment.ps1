Function Start-MonitorCertDeployment {


    ################################################################################
    # Do not modify below
    ################################################################################
    # Import the functions
    # Import-Module "$JCRScriptRoot/Functions/JCRadiusCertDeployment.psm1" -DisableNameChecking -Force
    # Define jsonData file
    $jsonFile = "$JCRScriptRoot/users.json"



    # Show user selection
    do {
        Show-CertDeploymentMenu
        $option = Read-Host "Please make a selection"
        switch ($option) {
            '1' {
                $data = Get-UserJsonData
                $certResults = Get-InstalledCertsFromUsersJson -userData $data
                $certResults | Format-Table
                pause
            } '2' {
                Get-CommandObjectTable -Detailed -jsonFile $jsonFile
                Pause
            } '3' {
                Get-CommandObjectTable -Failed -jsonFile $jsonFile
                Pause
            } '4' {
                $retryCommands = Invoke-CommandsRetry
                Pause
            }
        }
    } until ($option.ToUpper() -eq 'E')
}
