Function Monitor-CertDeployment {


    ################################################################################
    # Do not modify below
    ################################################################################
    # Import the functions
    Import-Module "$JCScriptRoot/Functions/JCRadiusCertDeployment.psm1" -DisableNameChecking -Force
    # Define jsonData file
    $jsonFile = "$JCScriptRoot/users.json"

    # Show user selection
    do {
        Show-CertDeploymentMenu
        $option = Read-Host "Please make a selection"
        switch ($option) {
            '1' {
                Get-CommandObjectTable -Detailed -jsonFile $jsonFile
                Pause
            } '2' {
                Get-CommandObjectTable -Failed -jsonFile $jsonFile
                Pause
            } '3' {
                $retryCommands = Invoke-CommandsRetry -jsonFile $jsonFile
                Pause
            }
        }
    } until ($option.ToUpper() -eq 'E')
}
