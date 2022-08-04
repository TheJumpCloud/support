---
layout: post
title: Report on Commands and their System and System Group Associations
description: Gathers a list of commands and the systems, system groups that they are associated with
tags:
  - powershell
  - reports
---

This script generates a CSV report of all commands and their associations to systems and system groups.

### Basic Usage

* The PowerShell Module is required to run this script
* Save the script to a location
* In a PowerShell terminal window, run the script `~/Path/To/Script/commands_associations.ps1`

### Additional Information

This script will search for all commands in an organization and return command details along with bound systems and system groups. A commands_report.csv file will be generated in the working directory where the script is run.

### Script

```powershell
################################################################################
# This script requires the JumpCloud PowerShell Module to run. Specifically, the
# JumpCloud PowerShell SDK Modules are required to run the system queries. To
# install the PowerShell Modules, enter the following line in a PWSH terminal:
# Install-Module JumpCloud
#
# This script can take a moment to run in large orgs
################################################################################

# Object to store results and to convert to CSV
$csvObject = @()

# Get all the commands in the org
$Commands = Get-JCCommand

# See if there are groups assigned to commands
foreach ($Command in $Commands) {
    $groups = Get-JcSdkCommandTraverseSystemGroup -CommandId $($Command._id)
    $Systems = Get-JcSdkCommandTraverseSystem -CommandId $($Command._id)

    if ($Groups) {
        $AssignedGroup = $true
    } else {
        $AssignedGroup = $false
    }

    $csvObject += [pscustomobject]@{
        commandID          = $Command._id
        name               = $Command.name
        command            = $Command.command
        commandType        = $Command.commandType
        launchType         = $Command.launchType
        schedule           = $Command.schedule
        trigger            = $Command.trigger
        scheduleRepeatType = $Command.scheduleRepeatType
        assignedGroup      = [string]$AssignedGroup
        groupID            = if ($Groups.Id) {
            $Groups.Id -join ','
        }
        systemID           = if ($Systems.Id) {
            $Systems.Id -join ','
        }
    }
}

$csvObject | Export-csv -Path './commands_report.csv' -NoTypeInformation

```
