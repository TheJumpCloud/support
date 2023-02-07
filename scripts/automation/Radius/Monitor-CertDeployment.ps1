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
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' {
            Get-CommandObjectTable -Detailed -jsonFile $jsonFile
        } '2' {
            Get-CommandObjectTable -Failed -jsonFile $jsonFile
        } '3' {
            $retryCommands = Invoke-CommandsRetry -jsonFile $jsonFile
        }
    }
    Pause
} until ($selection.ToUpper() -eq 'E')

################################################################################
# If needed you can clear out your command queue with the following commands.
# Copy and Paste these into a powershell terminal window to clear all queued
# commands in your org.
# Import-Module scripts/automation/Radius/RadiusCertFunctions.ps1 -force
# Get-JCQueuedCommands | Foreach-Object { Clear-JCQueuedCommand -workflowId $_.id }
