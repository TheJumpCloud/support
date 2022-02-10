---
layout: post
title: Group Systems by MDM Enrollment Status
description: Automatically group systems by MDM Enrollment status
tags:
  - powershell
  - groups
  - mdm
---

This script will create two device groups: MacOS-MDM-Pending & MacOS-MDM-Approved. It can be run multiple times to update the membership of the two system groups. If systems are waiting on MDM user approval they will be added to the MacOS-MDM-Pending group. Systems enrolled in JumpCloud MDM and user approved are added to the MacOS-MDM-Approved group.

### Basic Usage

* The PowerShell Module is required to run this script
* Save the script to a location
* Run `Connect-JCOnline` before executing this script
* In a PowerShell terminal window, run the script `~/Path/To/Scrpt/filename.ps1`

### Additional Information

This script will create two system groups (if they do not already exist). (Optionally) Modify The `$mdmApproved` & `$mdmPending` variables to change the two system group names the script will create/update. It can be run multiple times to add new systems to groups.

### Expected Output

The terminal window in which this script is run should display systemsNames, SystemGroups and the UserApprovedMDM status in a table like the example below:

| SystemName                      | SystemGroup        | UserApprovedMDM |
|---------------------------------|--------------------|-----------------|
| mdm-system                      | MacOS-MDM-Approved | true            |
| defaultadmins-MacBook-Air       | MacOS-MDM-Approved | true            |
| Farmer367-MacBook-Air           | MacOS-MDM-Approved | true            |
| TamirD-ISR-PRO-Mac              | MacOS-MDM-Approved | true            |
| Farmer345-MacBook               | MacOS-MDM-Approved | true            |
| Farmer345-MacBookPro            | MacOS-MDM-Pending  | false           |
| BobFays-BigSur-VM               | MacOS-MDM-Pending  | false           |
| mdm-testing                     | MacOS-MDM-Pending  | false           |
| Farmer121-MacBookPro            | MacOS-MDM-Pending  | false           |

### Script

```powershell
################################################################################
# This script requires the JumpCloud PowerShell Module to run. Specifically, the
# JumpCloud PowerShell SDK Modules are required to run the system queries. To
# install the PowerShell Modules, enter the following line in a PWSH terminal:
# Install-Module JumpCloud
#
# This script will search for systems and add them to system groups if they are
# not currently members of that group. It is intended to group systems by MDM
# enrollment status.
#
# This script can be run multiple times. As systems are added to JumpCloud, they
# will then be added to the defined system groups.
################################################################################
# Get all mac systems
$allMacSystems = Get-JCSystem | Where-Object { $_.osFamily -eq "darwin" }
# system groups
$mdmApproved = "MacOS-MDM-Approved"
$mdmPending = "MacOS-MDM-Pending"
# IF the group names do not exist, create them...
if (-Not (Get-JCGroup -Type System -Name $mdmApproved)){
    New-JcSdkSystemGroup -name $mdmApproved
}
if (-Not (Get-JCGroup -Type System -Name $mdmPending)) {
    New-JcSdkSystemGroup -name $mdmPending
}
# Get id of the two system groups
$mdmApprovedId = Get-JCGroup -Type System -Name $mdmApproved | select-object id
$mdmPendingId = Get-JCGroup -Type System -Name $mdmPending | select-object id
# Create an empty list to track the systems with User Approved MDM (UAMDM)
$userApprovedMdm = @()
# Get the ids of the systems already in the system groups
$userApprovedMdmSystems = Get-JCSystemGroupMember -GroupName $mdmApproved | select-object SystemID
$pendingMdmApprovalSystems = Get-JCSystemGroupMember -GroupName $mdmPending | select-object SystemID

# For each mac system:
$trackingList = @()
foreach ($system in $allMacSystems)
{
    # If that system is user approved and using JumpCloud MDM
    if ($system.mdm.userApproved -eq $True -and $system.mdm.vendor -eq "internal")
    {
        if ($system._id -notin $userApprovedMdmSystems.SystemID) {
        # if system is not in the mdm approved group, add it
            Set-JcSdkSystemGroupMember -GroupId:$mdmApprovedId.id -Op:add -Id:$system._id
            $TrackingList += [PSCustomObject]@{
                SystemName      = $($system.hostname)
                SystemGroup     = $mdmApproved
                UserApprovedMDM = $True
            }
        }
        else {
            # Else just track it
            $TrackingList += [PSCustomObject]@{
                SystemName      = $($system.hostname)
                SystemGroup     = $mdmApproved
                UserApprovedMDM = $True
            }
        }
        # If system is in the pending group, remove it from that group
        if ($system._id -in $pendingMdmApprovalSystems.SystemID) {
            Set-JcSdkSystemGroupMember -GroupId:$mdmPendingId.id -Op:remove -Id:$system._id
        }
    }
    else{
        # If the system is no user approved and using JumpCloud MDM
        if ( $system._id -notin $pendingMdmApprovalSystems.SystemID) {
            # if system is not in the mdm pending group, add it
            Set-JcSdkSystemGroupMember -GroupId:$mdmPendingId.id -Op:add -Id:$system._id
            $TrackingList += [PSCustomObject]@{
                SystemName      = $($system.hostname)
                SystemGroup     = $mdmPending
                UserApprovedMDM = $False
            }
        }
        else {
            # Else just track it
            $TrackingList += [PSCustomObject]@{
                SystemName      = $($system.hostname)
                SystemGroup     = $mdmPending
                UserApprovedMDM = $False
            }
        }
        # If the system is in the approved MDM group, but it shouldn't be, remove it
        if ( $system._id -in $userApprovedMdmSystems.SystemID) {
            Set-JcSdkSystemGroupMember -GroupId:$mdmApprovedId.id -Op:remove -Id:$system._id
        }
    }
}
# Print Results
$trackingList | Sort-Object UserApprovedMDM -Descending | Format-Table | Out-Host
```