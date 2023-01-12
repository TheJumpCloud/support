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
        if (!$response.queueIds) {
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
                $command.commandPreviouslyRun = $true
                $command.resultTimeStamp = $lastCommandResultTimestampUTC
                $command.result = $lastCommandResult.output
                $command.exitCode = $lastCommandResult.exitCode
            }

            if ($lastCommandResult.exitCode -eq 0) {
                # Cleanup old failed results
                $commandResults | Where-Object { $_._id -notin $lastCommandResult._id } | Remove-JCCommandResult -force | Out-Null
            } else {
                # Cleanup old results, save most recent
                $commandResults | Sort-Object responseTime -Descending | Select-Object -Skip 1 | Remove-JCCommandResult -force | Out-Null
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
        $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json

        $FailedCommands = $commandsObject | Where-Object { ($_.commandQueued -eq $false) -And ($_.exitCode -ne 0) }
        Write-Host "$($failedCommands.count) commands will be re-run"
    }
    process {
        # Prompt to rerun commands that have failed or expired
        $FailedCommands | ForEach-Object {
            try {
                Invoke-CommandRun -commandID $_.commandId
                # set command to queued
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

Function Get-CommandObjectTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject]$retryCommands,
        [Parameter()]
        [string]$jsonFile,
        [Parameter(ParameterSetName = 'Overview')]
        [switch]$Overview,
        [Parameter(ParameterSetName = 'Failed')]
        [switch]$Failed
    )
    process {
        switch ($PSCmdlet.ParameterSetName) {
            Overview {
                Write-Host "`n[Radius Cert Deployment Status - Overview]"
                $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json
                foreach ($command in $commandsObject) {
                    $character = if (($command.exitCode -eq 0)) {
                        "$([char]0x1b)[92mOK"
                    } elseif ($command.commandId -in $retryCommands) {
                        "$([char]0x1b)[34mCOMMAND RE-SCHEDULED"
                    } elseif (($command.exitCode -ne 0) -and ($command.commandQueued -eq $true)) {
                        "$([char]0x1b)[93mPENDING"
                    } elseif (($command.commandPreviouslyRun -eq $false) -and ($command.commandQueued -eq $false)) {
                        "$([char]0x1b)[91mNOT SCHEDULED"
                    } elseif (($command.exitCode -eq "") -and ($command.commandQueued -eq $false)) {
                        "$([char]0x1b)[91mNOT SCHEDULED"
                    } else {
                        "$([char]0x1b)[91mFAILED"
                    }
                    $command | Add-Member -Name "Status" -Type NoteProperty -Value $character
                }
                $commandsObject | ForEach-Object { [PSCustomObject]$_ } | Format-Table commandName, @{N = "commandQueued"; E = { $_.commandQueued }; align = 'center' }, resultTimestamp, @{N = "exitCode"; E = { $_.exitCode }; align = 'center' }, Status -AutoSize
            }
            Failed {
                Write-Host "`n[Radius Cert Deployment Status - Failed]"
                $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json
                $failedCommands = $commandsObject | Where-Object { $_.commandId -in $retryCommands }
                foreach ($command in $failedCommands) {
                    $character = if (($command.exitCode -eq 0)) {
                        "$([char]0x1b)[92mOK"
                    } elseif ($command.commandId -in $retryCommands) {
                        "$([char]0x1b)[34mCOMMAND RE-SCHEDULED"
                    } elseif (($command.exitCode -ne 0) -and ($command.commandQueued -eq $true)) {
                        "$([char]0x1b)[93mPENDING"
                    } elseif (($command.commandPreviouslyRun -eq "") -and ($command.commandQueued -eq $false)) {
                        "$([char]0x1b)[91mNOT SCHEDULED"
                    } elseif (($command.exitCode -eq "") -and ($command.commandQueued -eq $false)) {
                        "$([char]0x1b)[91mNOT SCHEDULED"
                    } else {
                        "$([char]0x1b)[91mFAILED"
                    }
                    $command | Add-Member -Name "Status" -Type NoteProperty -Value $character
                }
                $failedCommands | ForEach-Object { [PSCustomObject]$_ } | Format-Table commandName, @{N = "commandQueued"; E = { $_.commandQueued }; align = 'center' }, resultTimestamp, @{N = "exitCode"; E = { $_.exitCode }; align = 'center' }, Status -AutoSize
            }
        }
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

Get-CommandObjectTable -Overview -jsonFile $jsonFile

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
        Get-CommandObjectTable -jsonFile $jsonFile -retryCommands $retryCommands -Failed
    }
}

