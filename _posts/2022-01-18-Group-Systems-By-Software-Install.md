---
layout: post
title: Group systems by software installed
description: Script to group systems based on whether or not they have a particular software title installed.
tags:
  - powershell
  - groups
  - automation
---

This script will group systems to determine whether or not they have a particular software installed. This script is useful if attempting to determine which systems require a specific software to be installed. Both Windows and Mac systems are included in this search and will be added to the same group. There are some limitations to this script, namely the `$softwareTtile` must be a title that both Windows and Mac systems use. Ex. "Chrome" is the same titled software for both Windows and Mac.

### Basic Usage

* The PowerShell Module is required to run this script
* Save the script to a location
* In a PowerShell terminal window, run the script `~/Path/To/Scrpt/filename.ps1`

### Additional Information

This script will create two system groups (if they do not already exist) `AutoGroup-$softwareTitle-has` and `AutoGroup-$softwareTitle-missing`. This script can be run multiple times. As systems update, they will be removed or added to the "has" or "missing" group depending on whether or not they have or do not have the software title in the $softwareTitle variable.

### Script

```powershell
################################################################################
# This script requires the JumpCloud PowerShell Module to run. Specifically, the
# JumpCloud PowerShell SDK Modules are required to run the system queries. To
# install the PowerShell Modules, enter the following line in a PWSH terminal:
# Install-Module JumpCloud
#
# To run this script, update the 'SoftwareTitle' to search for a software title
# match in the system insights tables. Optionally edit the group name variables
# if you would like to change the group names.
#
# This script will create two groups, based on the software title.
# AutoGroup-$softwareTitle-has - Mac/Windows systems that have the softwareTitle
# AutoGroup-$softwareTitle-missing - Mac/Windows systems that are missing the
# softwareTitle
#
# This script will search for software titles on Mac/Windows and return matches
# ex: Google Chrome on a system will match the $SoftwareTitle "Chrome" like the
# default example
#
# This script can be run multiple times. As systems update, they will be removed
# or added to the "has" or "missing" group depending on whether or not they have
# or do not have the software title in the $softwareTitle variable.
################################################################################

# Variables:
# Get Software on Systems - search by unique
$softwareTitle = "Chrome"
# Has Group Name
$hasGroupName = "AutoGroup-$softwareTitle-has"
# Missing Group Name
$missingGroupName = "AutoGroup-$softwareTitle-missing"

################################################################################
$allSystemGroups = Get-JcSdkSystemGroup
# Create groups if they do no exist
if (!($allSystemGroups.Name -match $hasGroupName)){
    # Create group
    New-JcSdkSystemGroup -Name $hasGroupName
}
if (!($allSystemGroups.Name -match $missingGroupName)) {
    # Create group
    New-JcSdkSystemGroup -Name $missingGroupName
}
# Get Group ID & Group Membership for each group
$hasGroup = Get-JCGroup -Type System -Name $hasGroupName
$missingGroup = Get-JCGroup -Type System -Name $missingGroupName
$hasGroupMembers = Get-JCSystemGroupMember -ById $hasGroup.id
$missingGroupMembers = Get-JCSystemGroupMember -ById $missingGroup.id

# query systems
$allSystems = Get-JcSdkSystem
foreach ($system in $allSystems) {
    # Get App List for each system
    if ($system.OS -eq 'Windows'){
        $programs = Get-JCSystemInsights -Table Program -SystemId $system.Id
        if (!($($programs.Name) -match $softwareTitle))
        {
            # If system does not contain software...
            Write-Host "$($system.hostname) does not contain $softwareTitle"
            # if system id is not in missing software group, add it
            if (!($($missingGroupMembers.to.id) -match $($system.id)))
            {
                Write-host "Adding $($system.hostname) to group: $missingGroupName"
                Set-JcSdkSystemGroupMember -Id $($system.id) -Op add -GroupId $($missingGroup.id)
            }
            # if system id is in has software group, remove it
            if (($($hasGroupMembers.to.id) -match $($system.id)))
            {
                Write-host "removing $($system.hostname) from group: $hasGroupName"
                Set-JcSdkSystemGroupMember -Id $($system.id) -Op remove -GroupId $($hasGroup.id)
            }
        }
        else
        {
            # If sysetm does contains software...
            Write-Host "$($system.hostname) contains $softwareTitle"
            if (!($($hasGroupMembers.to.id) -match $($system.id)))
            {
                Write-host "Adding $($system.hostname) to group $hasGroupName"
                Set-JcSdkSystemGroupMember -Id $($system.id) -Op add -GroupId $($hasGroup.id)
            }
            # if system id is in missing software group, remove it
            if (($($missingGroupMembers.to.id) -match $($system.id)))
            {
                Write-host "removing $($system.hostname) from group: $missingGroupName"
                Set-JcSdkSystemGroupMember -Id $($system.id) -Op remove -GroupId $($missingGroup.id)
            }
        }
    }
    if ($system.OS -eq 'Mac OS X'){
        $apps = Get-JCSystemInsights -Table App -SystemId $system.id
        if (!($($apps.Name) -match $softwareTitle)){
            # If sysetm does not contain software...
            Write-Host "$($system.hostname) does not contain $softwareTitle"
            # if system id is not in missing software group, add it
            if (!($($missingGroupMembers.to.id) -match $($system.id))){
                Write-host "Adding $($system.hostname) to group: $missingGroupName"
                Set-JcSdkSystemGroupMember -Id $($system.id) -Op add -GroupId $($missingGroup.id)
            }
            # if system id is in has software group, remove it
            if (($($hasGroupMembers.to.id) -match $($system.id))) {
                Write-host "removing $($system.hostname) from group: $hasGroupName"
                Set-JcSdkSystemGroupMember -Id $($system.id) -Op remove -GroupId $($hasGroup.id)
            }
        }
        else{
            # If sysetm does contains software...
            Write-Host "$($system.hostname) contains $softwareTitle"
            if (!($($hasGroupMembers.to.id) -match $($system.id))){
                Write-host "Adding $($system.hostname) to group $hasGroupName"
                Set-JcSdkSystemGroupMember -Id $($system.id) -Op add -GroupId $($hasGroup.id)
            }
            # if system id is in missing software group, remove it
            if (($($missingGroupMembers.to.id) -match $($system.id))) {
                Write-host "removing $($system.hostname) from group: $missingGroupName"
                Set-JcSdkSystemGroupMember -Id $($system.id) -Op remove -GroupId $($missingGroup.id)
            }
        }
    }
}
```