Function Invoke-CommandsRetry {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.string]
        $jsonFile
    )
    begin {
        $RetryCommands = @()
        $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json -Depth 6
        $queuedCommands = Get-JCQueuedCommands
        $SearchFilter = @{
            searchTerm = 'RadiusCert-Install'
            fields     = @('name')
        }
        $commandResults = Search-JcSdkCommandResult -SearchFilter $SearchFilter
        $groupedCommandResults = $commandResults | Sort-Object -Property responseTime -Descending | Group-Object name, SystemId
        $mostRecentCommandResults = $groupedCommandResults | ForEach-Object { $_.Group | Select-Object -First 1 }
    }
    process {
        # Prompt to rerun commands that have failed or expired
        Foreach ($command in $commandsObject.commandAssociations) {
            $failedCommands = $mostRecentCommandResults | Where-Object DataExitCode -NE 0

            if ($queuedCommands.command -contains $command.commandId) {
                Write-Host "[status] $($command.commandName) is currently $([char]0x1b)[93mPENDING"
                continue
            } else {
                if (($failedCommands.workflowId -contains $command.commandId) -or ($command.commandPreviouslyRun -eq $false) -or ($QueuedCommands.command -notcontains $command.commandId -and $finishedCommands.workflowId -notcontains $command.commandId)) {
                    try {
                        if (!(Get-JcSdkCommandAssociation -CommandId $command.commandId -Targets system)) {
                            continue
                        } else {
                            Invoke-CommandRun -commandID $command.commandId
                            Write-Host "[status] $([char]0x1b)[92mInvoking $($command.commandName)"
                            # set command to queued
                            $command.commandQueued = $true
                            $RetryCommands += $command.commandId
                        }
                    } catch {
                        Write-Error "$($command.commandId) could not be invoked"
                    }
                }
            }
        }
    }
    end {
        # write out/ update jsonFile
        $commandsObject | ConvertTo-Json -Depth 6 | Out-File $jsonFile
        return $RetryCommands
    }
}