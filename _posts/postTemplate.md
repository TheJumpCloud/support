---
layout: post
title: Title of post
description: Description of post (what the automation does)
tags:
  - powershell
  - reports
  - automation
---

This is a medium-length description of the command/ script/ workflow. It is intended to give customers an at-a-glance idea of the script and what it does. Ex. This script makes use of the JumpCloud PowerShell Module, it selects all systems in the org and groups systems by operating system. An h3 "summary" text title will appear before this text block.

### Basic Usage

* The PowerShell Module is required to run this script
* Save the script to a location
* In a PowerShell terminal window, run the script `~/Path/To/Scrpt/filename.ps1`

### Additional Information

This script will create three system groups (if they do not already exist) for each OS (windows mac and linux). It can be run multiple times to add new systems to groups.

### Script

```powershell
################################################################################
# This script requires the JumpCloud PowerShell Module to run. Specifically, the
# JumpCloud PowerShell SDK Modules are required to run the system queries. To
# install the PowerShell Modules, enter the following line in a PWSH terminal:
# Install-Module JumpCloud
#
# This script will search for systems and add them to system groups if they are
# not currently members of that group. It is intended to group systems by OS.
#
# This script can be run multiple times. As systems are added to JumpCloud, they
# will then be added to the defined system groups.
################################################################################

# Group Names
$MacGroupName = "AutoGroup-Mac"
$WindowsGroupName = "AutoGroup-Windows"
$LinuxGroupName = "AutoGroup-Linux"
$Groups = @($MacGroupName, $WindowsGroupName, $LinuxGroupName)

################################################################################
$allSystemGroups = Get-JcSdkSystemGroup
foreach ($Group in $Groups) {
    # Create groups if they do no exist
    if (!($allSystemGroups.Name -match $Group)) {
        # Create group
        New-JcSdkSystemGroup -Name $Group
    }
}
# Get Group ID & Group Membership for each group
$MacGroup = Get-JCGroup -Type System -Name $MacGroupName
$MacGroupMembers = Get-JCSystemGroupMember -ById $MacGroup.id
$WindowsGroup = Get-JCGroup -Type System -Name $WindowsGroupName
$WindowsGroupMembers = Get-JCSystemGroupMember -ById $WindowsGroup.id
$LinuxGroup = Get-JCGroup -Type System -Name $LinuxGroupName
$LinuxGroupMembers = Get-JCSystemGroupMember -ById $LinuxGroup.id

# query systems
$allSystems = Get-JcSdkSystem
foreach ($system in $allSystems) {
    # Get App List for each system
    if ($system.OS -eq 'Windows'){
        if (!($($WindowsGroupMembers.to.id) -match $($system.id))){
            Write-host "Adding $($system.hostname) to group $WindowsGroupName"
            Set-JcSdkSystemGroupMember -Id $($system.id) -Op add -GroupId $($WindowsGroup.id)
        }
    }
    elseif ($system.OS -eq 'Mac OS X'){
        if (!($($MacGroupMembers.to.id) -match $($system.id))){
            Write-host "Adding $($system.hostname) to group $MacGroupName"
            Set-JcSdkSystemGroupMember -Id $($system.id) -Op add -GroupId $($MacGroup.id)
        }
    }
    elseif ($system.OS -eq 'Ubuntu'){
        if (!($($LinuxGroupMembers.to.id) -match $($system.id))) {
            Write-host "Adding $($system.hostname) to group $LinuxGroupName"
            Set-JcSdkSystemGroupMember -Id $($system.id) -Op add -GroupId $($LinuxGroup.id)
        }

    }
}
```