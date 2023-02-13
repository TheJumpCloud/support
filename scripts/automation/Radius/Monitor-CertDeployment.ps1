# Import Global Config:
. "$psscriptroot/config.ps1"
Connect-JCOnline $JCAPIKEY -force

################################################################################
# Do not modify below
################################################################################
# Import the functions
Import-Module "$psscriptroot/RadiusCertFunctions.ps1" -Force
# Define jsonData file
$jsonFile = "$PSScriptRoot/users.json"

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

################################################################################
# If needed you can clear out your command queue with the following commands.
# Copy and Paste these into a powershell terminal window to clear all queued
# commands in your org.
# . "scripts/automation/Radius/RadiusCertFunctions.ps1"
# Get-JCQueuedCommands | Foreach-Object { Clear-JCQueuedCommand -workflowId $_.id }
