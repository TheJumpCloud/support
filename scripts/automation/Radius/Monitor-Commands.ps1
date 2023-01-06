# Import Global Config:
. "$psscriptroot/config.ps1"
Connect-JCOnline $JCAPIKEY -Force

# Tracking Variables for results
$SuccessfulCommandRuns = @()
$FailedCommandRuns = @()

# Create CommandResults dir
if (Test-Path "$PSScriptRoot/CommandResults") {
    Write-Host "[status] Command Results Directory Exists"
} else {
    Write-Host "[status] Creating Command Results Directory"
    [void](New-Item -ItemType Directory -Path "$PSScriptRoot/CommandResults")
}

# Get all Commands with the RadiusCertInstall trigger
$RadiusCommands = Get-JCCommand | Where-Object trigger -Like 'RadiusCertInstall'
$CommandCount = $RadiusCommands.Count

# Get all Command Results for the RadiusCommands
$CommandResults = Get-JCCommandResult -Detailed | Where-Object { $_.name -like "RadiusCert-Install*" }
$ResultCount = $CommandResults.Count

# Check results
$SuccessfulCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "0" }
$FailedCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "1" -or $_.exitCode -eq "4" }

# Send Results to CSV
$SuccessfulCommandRuns | Export-Csv -Path "$PSScriptRoot/CommandResults/SuccessfulCommands.csv" -NoTypeInformation
$FailedCommandRuns | Export-Csv -Path "$PSScriptRoot/CommandResults/FailedCommands.csv" -NoTypeInformation

Write-Host "[info] Results will be constantly checked until all commands have been executed"
Write-Host "[info] You may monitor the results by checking the CSV files located in the $PSScriptRoot/CommandResults folder"
Write-Host "[info] This may take some time due to queued commands and device status"
while ($ResultCount -lt $CommandCount) {
    # Gather Result information
    $CommandResults = Get-JCCommandResult -Detailed | Where-Object { $_.name -like "RadiusCert-Install*" }
    $ResultCount = $CommandResults.Count

    # Check results
    $SuccessfulCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "0" }
    $FailedCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "1" -or $_.exitCode -eq "4" }

    # Send Results to CSV
    $SuccessfulCommandRuns | Export-Csv -Path "$PSScriptRoot/CommandResults/SuccessfulCommands.csv" -NoTypeInformation
    $FailedCommandRuns | Export-Csv -Path "$PSScriptRoot/CommandResults/FailedCommands.csv" -NoTypeInformation

    # Track % Completed
    $Completed = ($ResultCount / $CommandCount) * 100

    # Progress Bar
    Write-Progress -Activity "Checking Command Results..." -Status "Progress:" -PercentComplete $Completed

    # Sleep 5 seconds
    Start-Sleep -Seconds 5
}

Write-Host "[status] All commands have been executed"
Write-Host "[status] $($SuccessfulCommandRuns.Count) successful command executions and $($FailedCommandRuns.Count) failures"