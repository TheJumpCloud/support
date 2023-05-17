Function Get-CommandObjectTable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject]$retryCommands,
        [Parameter()]
        [string]$jsonFile,
        [Parameter(ParameterSetName = 'Failed')]
        [switch]$Failed,
        [Parameter(ParameterSetName = 'Detailed')]
        [switch]$Detailed
    )
    process {
        switch ($PSCmdlet.ParameterSetName) {
            Failed {
                # Import the users.json file and get the commandAssociations
                $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json -Depth 6
                # Gather hash of system ids and displayNames
                $SystemHash = Get-JCSystem -returnProperties displayName
                # Find all the queued commands for organization
                $QueuedCommands = Get-JCQueuedCommands

                $CommandObjectTable = @()

                # Clean up command results
                $SearchFilter = @{
                    searchTerm = 'RadiusCert-Install'
                    fields     = @('name')
                }
                $commandResults = Search-JcSdkCommandResult -SearchFilter $SearchFilter
                if ($commandResults) {
                    $groupedCommandResults = $commandResults | Group-Object name, SystemId | Sort-Object -Property responseTime -Descending
                    $mostRecentCommandResults = $groupedCommandResults | ForEach-Object { $_.Group | Select-Object -First 1 }
                    $commandResults | ForEach-Object {
                        if ($_.id -in $mostRecentCommandResults.id) {
                            return
                        } else {
                            Remove-JCCommandResult -CommandResultID $_.id -force | Out-Null
                        }
                    }
                }

                # Iterate through all the associated commands
                foreach ($command in $commandsObject.commandAssociations) {
                    $finishedCommands = $mostRecentCommandResults | Where-Object workflowId -EQ $command.commandID
                    if ($finishedCommands) {
                        # If there are finished command results, iterate through each and add to command object array
                        $finishedCommands | ForEach-Object {
                            if (($_.DataExitCode -ne 0)) {
                                $character = "$([char]0x1b)[91mFAILED"
                                #$output = Get-JCCommandResult -id $_._id | Select-Object -ExpandProperty output
                            } else {
                                continue
                            }
                            $CommandTable = @{
                                commandName       = $command.commandName
                                systemDisplayName = $SystemHash | Where-Object _id -EQ $_.systemId | Select-Object -ExpandProperty displayName
                                status            = $character
                                output            = $_.DataOutput
                            }
                            $CommandObjectTable += $CommandTable
                        }
                    }
                }
                # Display object array
                Write-Host "`n[Radius Cert Deployment Status - Failed]"
                $CommandObjectTable | ForEach-Object { [PSCustomObject]$_ } | Format-List commandName, systemDisplayName, status, output
            }
            Detailed {
                # Import the users.json file and get the commandAssociations
                $commandsObject = Get-Content -Raw -Path $jsonFile | ConvertFrom-Json -Depth 6
                # Gather hash of system ids and displayNames
                $SystemHash = Get-JCSystem -returnProperties displayName
                # Find all the queued commands for organization
                $QueuedCommands = Get-JCQueuedCommands

                $CommandObjectTable = @()

                # Clean up command results
                $SearchFilter = @{
                    searchTerm = 'RadiusCert-Install'
                    fields     = @('name')
                }
                $commandResults = Search-JcSdkCommandResult -SearchFilter $SearchFilter
                if ($commandResults) {
                    $groupedCommandResults = $commandResults | Group-Object name, systemId | Sort-Object -Property responseTime -Descending
                    $mostRecentCommandResults = $groupedCommandResults | ForEach-Object { $_.Group | Select-Object -First 1 }
                    $commandResults | ForEach-Object {
                        if ($_.id -in $mostRecentCommandResults.id) {
                            return
                        } else {
                            Remove-JCCommandResult -CommandResultID $_.id -force | Out-Null
                        }
                    }
                }

                # Iterate through all the associated commands
                foreach ($command in $commandsObject.commandAssociations) {
                    # Check to see if the current command is pending/queued
                    if ($command.commandId -in $QueuedCommands.command) {
                        # Get the queued command info for all workflows
                        $queuedCommandInfo = $QueuedCommands | Where-Object command -EQ $command.commandId
                        # Get the individual workflow information
                        $pendingCommands = Get-JCQueuedCommands -workflow $queuedCommandInfo.id
                        # Set the command properties in json
                        $command.commandPreviouslyRun = $true
                        $command.commandQueued = $true
                        # Create command table and add to object array
                        $pendingCommands | ForEach-Object {
                            $CommandTable = @{
                                commandName       = $command.commandName
                                systemDisplayName = $SystemHash | Where-Object _id -EQ $_.system | Select-Object -ExpandProperty displayName
                                status            = "$([char]0x1b)[93mPENDING"
                            }
                            $CommandObjectTable += $CommandTable
                        }
                    }

                    # Get finished command results for current command
                    $finishedCommands = $mostRecentCommandResults | Where-Object workflowId -EQ $command.commandID
                    if ($finishedCommands) {
                        # If there are finished command results, iterate through each and add to command object array
                        $finishedCommands | ForEach-Object {
                            if (($finishedCommands.DataExitCode -eq 0)) {
                                $character = "$([char]0x1b)[92mOK"
                                # Remove successful systems from command associations
                                Set-JcSdkCommandAssociation -CommandId:("$($command.commandId)") -Op 'remove' -Type:('system') -Id:("$($_.systemId)") -ErrorAction SilentlyContinue | Out-Null
                            } else {
                                $character = "$([char]0x1b)[91mFAILED"
                            }
                            $CommandTable = @{
                                commandName       = $command.commandName
                                systemDisplayName = $SystemHash | Where-Object _id -EQ $_.systemId | Select-Object -ExpandProperty displayName
                                status            = $character
                            }
                            $CommandObjectTable += $CommandTable
                        }
                    }

                    if ($CommandObjectTable.commandName -notcontains $command.commandName) {
                        if (!(Get-JcSdkCommandAssociation -CommandId $command.commandId -Targets system)) {
                            $CommandTable = @{
                                commandName       = $command.commandName
                                systemDisplayName = $null
                                status            = "$([char]0x1b)[91mNo system associations found"
                            }
                            $CommandObjectTable += $CommandTable
                        } elseif (($command.commandPreviouslyRun -eq $false -and $command.commandQueued -eq $false) -or ($command.commandId -notin $QueuedCommands.command -and $command.commandId -notin $finishedCommands.workflowId)) {
                            foreach ($system in $command.systems) {
                                $CommandTable = @{
                                    commandName       = $command.commandName
                                    systemDisplayName = $SystemHash | Where-Object _id -EQ $system.systemId | Select-Object -ExpandProperty displayName
                                    status            = "$([char]0x1b)[91mNOT SCHEDULED"
                                }
                                $CommandObjectTable += $CommandTable
                            }
                        }
                    }
                }
                # Display object array
                Write-Host "`n[Radius Cert Deployment Status - Detailed]"
                $CommandObjectTable | ForEach-Object { [PSCustomObject]$_ } | Sort-Object -Property commandName, systemDisplayName, status | Format-Table commandName, systemDisplayName, status
            }
        }
    }
    end {
        # Update the json
        $commandsObject | ConvertTo-Json -Depth 6 | Out-File $jsonFile
    }
}