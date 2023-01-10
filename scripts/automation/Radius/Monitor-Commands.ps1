# Import Global Config:
. "$psscriptroot/config.ps1"
Connect-JCOnline $JCAPIKEY -Force

# Begin Functions
function Invoke-CommandRun {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $commandID
    )
    begin {
        if ($commandID.length -ne 24) {
            throw "Supplied CommandID is not of the correct length"
        }
    }
    process {
        $headers = @{
            'x-api-key'    = $Env:JCApiKey
            'x-org-id'     = $Env:JCOrgId
            "content-type" = "application/json"
        }
        $body = @{
            _id = $commandID
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/runCommand' -Method POST -Headers $headers -ContentType 'application/json' -Body $body
    }
    end {
        if ($response.queueIds) {
            Write-Debug "$CommandID triggered sucessfully"
        } else {
            Throw "Command with ID: $commandID could not be triggered"
        }

    }

}

function Get-JCQueuedCommands {
    begin {
        $headers = @{
            "x-api-key" = $JCAPIKEY
            "x-org-id"  = $JCORGID

        }
        $limit = [int]100
        $skip = [int]0
        $resultsArray = @()
        $resultsArrayList = New-Object System.Collections.ArrayList
    }
    process {
        while (($resultsArray.results).Count -ge $skip) {
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/queuedcommand/workflows?limit=$limit&skip=$skip" -Method GET -Headers $headers
            $skip += $limit
            $resultsArray += $response
        }
        $resultsArrayList.Add($resultsArray)
    }
    end {
        return $resultsArrayList.Results
    }
}
# End Functions

# Tracking Variables for results
$SuccessfulCommandRuns = @()
$QueuedCommandRuns = @()
$FailedCommandRuns = @()
$RetryCommands = @()

# Get all Commands with the RadiusCertInstall trigger
$RadiusCommands = Get-Content -Raw -Path "$PSScriptRoot/commands.json" | ConvertFrom-Json

# Get all Command Results for the RadiusCommands
$CommandResults = Get-JCCommandResult -Detailed | Where-Object { ($_.name -like "RadiusCert-Install*") -And ($_.workflowId -in $RadiusCommands.commandId) }
$ResultCount = $CommandResults.Count

# Check results
$SuccessfulCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "0" }
$QueuedCommandRuns = Get-JCQueuedCommands
$FailedCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "1" -or $_.exitCode -eq "4" }

# Update Commands.json with updated information
$RadiusCommands | ForEach-Object {
    if ($_.commandId -in $SuccessfulCommandRuns.workflowId) {
        # Check if command exists in successful command runs
        $commandInfo = $SuccessfulCommandRuns | Where-Object workflowId -EQ $_.commandId
        $_.commandQueued = $false
        $_.resultTimeStamp = $commandInfo.responseTime
        $_.result = $commandInfo.output
        $_.exitCode = $commandInfo.exitCode
    } elseif ($_.commandId -in $QueuedCommandRuns.command -or $_.commandQueued -eq $true) {
        # Check if command exists in queuedCommands or previously had the commandQueued property set to true
        $_.commandQueued = $true
        $lastRun = $_.lastRun | Get-Date
        $currentTime = Get-Date -Format o

        # If the current time is greater than the lastRun timestamp by 1 hour (TTL expired), add to retryCommand array
        if ($currentTime -ge $lastRun.AddHours(1)) {
            $RetryCommands += $_
        }
    } elseif ($_.commandId -in $FailedCommandRuns.workflowId) {
        # Check if command exists in failed command runs. if so, add to retryCommand array
        $commandInfo = $FailedCommandRuns | Where-Object workflowId -EQ $_.commandId
        $_.commandQueued = $false
        $_.resultTimeStamp = $commandInfo.responseTime
        $_.result = $commandInfo.output
        $_.exitCode = $commandInfo.exitCode

        $RetryCommands += $_
    } elseif ($_.exitCode -eq 0 -or $_.exitCode -eq 4) {
        $RetryCommands += $_
    }
}

Write-Host "[status] $($SuccessfulCommandRuns.Count) successful command executions and $($RetryCommands.Count) failures"

# Output json object
# $RadiusCommands | ForEach-Object { [PSCustomObject]$_ } | Format-Table -AutoSize

# Prompt to rerun commands that have failed or expired
$confirmation = Read-Host "Would you like to rerun failed commands and/or expired queued commands? [y/n]"
while ($confirmation -ne 'y') {
    if ($confirmation -eq 'n') {
        $RadiusCommands | ConvertTo-Json | Out-File "$psscriptroot\commands.json"
        exit
    }
}

# Cleanup old failed results
Write-Host "[status] Cleaning up old command result failures"
$FailedCommandRuns | Remove-JCCommandResult -Force | Out-Null

# Retry commands
$RetryCommands | ForEach-Object {
    if ($_.commandId -in $QueuedCommandRuns.command) {
        Write-Host "[status] Queued: $($_.commandName)"
    } else {
        Write-Host "[status] Running: $($_.commandName)"
        Invoke-CommandRun -commandID $_.commandId
    }
}

# Update the lastRun property for the commands
$RadiusCommands | ForEach-Object {
    if ($_.commandId -in $RetryCommands.commandId) {
        $_.lastRun = (Get-Date -Format o -AsUTC)
    }
}

# Update json file
$RadiusCommands | ConvertTo-Json | Out-File "$psscriptroot\commands.json"

# Have the script call itself to update the json file
. $PSCommandPath
