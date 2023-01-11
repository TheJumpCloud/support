# Import Global Config:
. "$psscriptroot/config.ps1"
Connect-JCOnline $JCAPIKEY -force

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
            Write-Host "$CommandID triggered sucessfully"
        } else {
            Throw "Command with ID: $commandID could not be triggered"
        }

    }

}

function Clear-JCQueuedCommand {
    param (
        [System.String]
        $workflowId
    )
    process {
        $headers = @{
            'x-api-key' = $Env:JCApiKey
            'x-org-id'  = $Env:JCOrgId
        }
        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/commandqueue/$workflowId" -Method DELETE -Headers $headers
    }
    end {
        return $response
    }
}

function Get-JCQueuedCommands {
    begin {
        $headers = @{
            "x-api-key" = $Env:JCApiKey
            "x-org-id"  = $Env:JCOrgId

        }
        $limit = [int]100
        $skip = [int]0
        $resultsArray = @()
    }
    process {
        while (($resultsArray.results).Count -ge $skip) {
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/queuedcommand/workflows?limit=$limit&skip=$skip" -Method GET -Headers $headers
            $skip += $limit
            $resultsArray += $response.results
        }
    }
    end {
        return $resultsArray
    }
}


Function Update-CommandsObject {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $jsonFile
    )
    begin {
        $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json
        $QueuedCommandRuns = Get-JCQueuedCommands
    }
    process {
        # Update the Command Result status for commands no longer in queue
        foreach ($command in $commandsObject | Where-Object { $_.commandID -notin $QueuedCommandRuns.command }) {
            $progress = $commandsObject.commandId.indexOf($command.commandId)
            $Completed = ($progress / $commandsObject.count) * 100
            Write-Progress -Activity "Checking Radius Command Results" -Status "Progress:" -PercentComplete $Completed
            # update command results
            $CommandResults = Get-JCCommandResult -CommandID $command.commandId
            if ($commandResults) {
                # write-host "$($commandResults.count) command results found for $($command.commandID)"
                $lastCommandResult = $CommandResults | Sort-Object -Property responseTime | Select-Object -Last 1
                # $lastCommandResultTimestamp.responseTime
                $lastCommandResultTimestampUTC = Get-Date $lastCommandResult.responseTime -Format o -AsUTC
                # update lastRun line
                $command.commandPreviouslyRun = $true
                $command.resultTimeStamp = $lastCommandResultTimestampUTC
                $command.result = $lastCommandResult.output
                $command.exitCode = $lastCommandResult.exitCode
            }

            if ($lastCommandResult.exitCode -eq 0) {
                # Cleanup old failed results
                $commandResults | Where-Object { $_._id -notin $lastCommandResult._id } | Remove-JCCommandResult -force | Out-Null
            }
        }
        # Then update the command queue status for every object
        foreach ($command in $commandsObject) {
            # update current command queued status
            if ($command.commandId -in $QueuedCommandRuns.command) {
                $command.commandQueued = $true
            } else {
                $command.commandQueued = $false
            }
        }
    }
    end {
        $commandsObject | ConvertTo-Json | Out-File $jsonFile
        return $commandsObject
    }
}

Function Invoke-CommandsRetry {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.string]
        $jsonFile
    )
    begin {
        $RetryCommands = @()
        $currentTime = Get-Date -Format o
        $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json

        $FailedCommands = $commandsObject | Where-Object { ($_.commandQueued -eq $false) -And ($_.exitCode -ne 0) }
        Write-Host "$($failedCommands.count) commands will be re-run"
    }
    process {
        # Prompt to rerun commands that have failed or expired
        $FailedCommands | ForEach-Object {
            try {
                Invoke-CommandRun -commandID $_.commandId
                # update last run timestamp & set command to queued
                $_.lastRun = $currentTime
                $_.commandQueued = $true
                $RetryCommands += $_.commandId
            } catch {
                Write-Error "$($_.commandId) could not be invoked"
            }
        }
    }
    end {
        # write out/ update jsonFile
        $commandsObject | ConvertTo-Json | Out-File $jsonFile
        return $RetryCommands
    }
}
# End Functions
# Define jsonData file
$jsonFile = "$PSScriptRoot/commands.json"

# First get latest command results & set $jsonFile with any updates
$CommandResults = Update-CommandsObject -jsonFile $jsonFile

# Tracking Variables for results
$SuccessfulCommandRuns = @()
$AvailableCommands = @()

# Check results
$SuccessfulCommandRuns = $CommandResults | Where-Object { $_.exitCode -eq "0" }
$AvailableCommands = $CommandResults | Where-Object { ($_.exitCode -ne 0) -And ($_.commandQueued -eq $false) }

# Prompt to rerun commands that have failed or expired (if possible)
If ($AvailableCommands) {
    $confirmation = Read-Host "Would you like to rerun failed/unrun commands and/or expired queued commands? [y/n]"
    while ($confirmation -ne 'y') {
        if ($confirmation -eq 'n') {
            break
        }
    }
    if ($confirmation -eq 'y') {
        # Retry commands
        $retryCommands = Invoke-CommandsRetry -jsonFile $jsonFile
    }
}

# display current json
Write-Host "`n[Radius Cert Deployment Status]"
$commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json
foreach ($command in $commandsObject) {
    $character = if (($command.exitCode -eq 0)) {
        "$([char]0x1b)[92mOK"
    } elseif ($command.commandId -in $retryCommands) {
        "$([char]0x1b)[34mCOMMAND RE-SCHEDULED"
    } elseif (($command.exitCode -ne 0) -and ($command.commandQueued -eq $true)) {
        "$([char]0x1b)[93mPENDING"
    } elseif (($command.lastRun -eq "") -and ($command.commandQueued -eq $false)) {
        "$([char]0x1b)[91mNOT SCHEDULED"
    } elseif (($command.exitCode -eq "") -and ($command.commandQueued -eq $false)) {
        "$([char]0x1b)[91mNOT SCHEDULED"
    } else {
        "$([char]0x1b)[91mFAILED"
    }
    $command | Add-Member -Name "Status" -Type NoteProperty -Value $character
}
$commandsObject | ForEach-Object { [PSCustomObject]$_ } | Format-Table commandName, @{N = "commandPreviouslyRun"; E = { $_.commandPreviouslyRun }; align = 'center' }, lastRun, @{N = "commandQueued"; E = { $_.commandQueued }; align = 'center' }, resultTimestamp, @{N = "exitCode"; E = { $_.exitCode }; align = 'center' }, Status -AutoSize
# break

# # Get all Command Results for the RadiusCommands
# $CommandResults = Get-JCCommandResult -Detailed | Where-Object { ($_.name -like "RadiusCert-Install*") }

# # Check results
# $SuccessfulCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "0" }
# $QueuedCommandRuns = Get-JCQueuedCommands
# $FailedCommandRuns = $CommandResults | Select-Object -ExcludeProperty command | Where-Object { $_.exitCode -eq "1" -or $_.exitCode -eq "4" }

# # Update Commands.json with updated information
# $RadiusCommands | ForEach-Object {
#     if ($_.commandId -in $SuccessfulCommandRuns.workflowId) {
#         # Check if command exists in successful command runs
#         $commandInfo = $SuccessfulCommandRuns | Where-Object workflowId -EQ $_.commandId
#         $_.commandQueued = $false
#         $_.resultTimeStamp = $commandInfo.responseTime
#         $_.result = $commandInfo.output
#         $_.exitCode = $commandInfo.exitCode
#     } elseif ($_.commandId -in $FailedCommandRuns.workflowId) {
#         # Check if command exists in failed command runs. if so, add to retryCommand array
#         $commandInfo = $FailedCommandRuns | Where-Object workflowId -EQ $_.commandId
#         $_.commandQueued = $false
#         $_.resultTimeStamp = $commandInfo.responseTime
#         $_.result = $commandInfo.output
#         $_.exitCode = $commandInfo.exitCode

#         $RetryCommands += $_
#     } elseif ($_.exitCode -eq 0 -or $_.exitCode -eq 4) {
#         $RetryCommands += $_
#     } elseif ($_.commandId -in $QueuedCommandRuns.command -or $_.commandQueued -eq $true) {
#         # Check if command exists in queuedCommands or previously had the commandQueued property set to true
#         $_.commandQueued = $true
#         $lastRun = $_.lastRun | Get-Date
#         $currentTime = Get-Date -Format o

#         # If the current time is greater than the lastRun timestamp by 1 hour (TTL expired), add to retryCommand array
#         if ($currentTime -ge $lastRun.AddDays(10)) {
#             $RetryCommands += $_
#         }
#     }
# }
# # Output json object
# $RadiusCommands | ForEach-Object { [PSCustomObject]$_ } | Format-Table -AutoSize
# Write-Host "[status] $($SuccessfulCommandRuns.Count) successful command executions and $($RetryCommands.Count) failures"

# # Prompt to rerun commands that have failed or expired
# $confirmation = Read-Host "Would you like to rerun failed commands and/or expired queued commands? [y/n]"
# while ($confirmation -ne 'y') {
#     if ($confirmation -eq 'n') {
#         $RadiusCommands | ConvertTo-Json | Out-File "$psscriptroot\commands.json"
#         exit
#     }
# }

# # Cleanup old failed results
# Write-Host "[status] Cleaning up old command result failures"
# $FailedCommandRuns | Remove-JCCommandResult -force | Out-Null

# # Retry commands
# $RetryCommands | ForEach-Object {
#     if ($_.commandId -in $QueuedCommandRuns.command) {
#         Write-Host "[status] Queued: $($_.commandName)"
#     } else {
#         Write-Host "[status] Running: $($_.commandName)"
#         Invoke-CommandRun -commandID $_.commandId
#     }
# }

# # Update the lastRun property for the commands
# $RadiusCommands | ForEach-Object {
#     if ($_.commandId -in $RetryCommands.commandId) {
#         $_.lastRun = (Get-Date -Format o -AsUTC)
#     }
# }

# # Update json file
# $RadiusCommands | ConvertTo-Json | Out-File "$psscriptroot\commands.json"

# Have the script call itself to update the json file
# . $PSCommandPath
