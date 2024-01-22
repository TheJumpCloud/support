Function Invoke-CommandsRetry {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.string]
        $jsonFile
    )
    begin {
        $RetryCommands = @()
        $userArray = Get-UserJsonData
        # $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json -Depth 6
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
        Foreach ($user in ($userArray) | Where-Object { $_.commandAssociations -ne $null }) {
            $userIndex = $userArray.userId.IndexOf($user.userID)
            $failedCommands = $mostRecentCommandResults | Where-Object DataExitCode -NE 0
            $commands = $user.commandAssociations
            # foreach command in the command object
            foreach ($command in $commands) {
                if ($queuedCommands.command -contains $command.commandId) {
                    Write-Host "[status] $($command.commandName) is currently $([char]0x1b)[93mPENDING"
                    continue
                } else {
                    if (($failedCommands.workflowId -contains $command.commandId) -or ($command.commandPreviouslyRun -eq $false) -or ($QueuedCommands.command -notcontains $command.commandId -and $finishedCommands.workflowId -notcontains $command.commandId)) {
                        try {
                            # invoke each user's command on their set systems:
                            invoke-commandByUserid -userID $user.userId
                            # update user table info per command
                            (($user.commandAssociations) | Where-Object { $_.commandId -eq $command.commandId }).commandPreviouslyRun = $true
                            (($user.commandAssociations) | Where-Object { $_.commandId -eq $command.commandId }).commandQueued = $true
                            $user.certInfo.deployed = $true
                            $user.certInfo.deploymentDate = (get-date)
                            Set-UserTable -index $userIndex -certInfoObject $user.certInfo -commandAssociationsObject $user.commandAssociations
                            # track retried commands
                            $RetryCommands += $command.commandId
                        } catch {
                            Write-Error "$($command.commandName) could not be invoked"
                        }
                    }
                }
            }
        }
    }
    end {
        # TODO: validate no need to write this out since it's done in Set-UserTable
        # # write out/ update jsonFile
        # Set-UserJsonData -userArray $userArray
        # $commandsObject | ConvertTo-Json -Depth 6 | Out-File $jsonFile
        return $RetryCommands
    }
}