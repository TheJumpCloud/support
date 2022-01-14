---
layout: post
title: Report on Users and associated Groups and Systems
description: Generate a CSV report for users that are associated to systems and user groups
tags: powershell reports automation
---
## Report on Users and associated Groups and Systems

### Description

A CSV report of user associations (Groups and Systems). This script will generate a "Report-UserToGroupAssociation.csv" file relative to the location this script is saved and ran.

### Basic Usage:

* Install the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Using-the-JumpCloud-PowerShell-Module)
* Save the contents of the script example to a file on a system.
  * EX: ~/Report-Users_Bound_To_Groups.ps1
* In a PowerShell terminal window run:
  * `~/Report-Users_Bound_To_Groups.ps1`
  * Follow prompts to enter your API Key & OrgID

### Script Example:

```powershell
# Get everyone from a group
$users = Get-JcSdkUser
# Initialize an empty list
$list = @()
# For each user
foreach ($user in $users)
{
    $userDetails = Get-jcsdkUser -Id $user.id
    # Get System Associations
    $systemAssociations = Get-JcSdkUserTraverseSystem -UserId $user.Id
    # Get Group Associations
    $groupAssociations = Get-JcSdkUserMember -UserId $user.Id
    # Clear variables
    $foundSystem = ""
    $foundGroup = ""
    # For each system association
    foreach ($systemAssociation in $systemAssociations)
    {
        $foundSystem += $systemAssociation.Id + ';'
    }
    # For each group association
    foreach ($groupAssociation in $groupAssociations)
    {
        $foundGroup += $groupAssociation.Id + ';'
    }
    # populate the rows
    $list += [PSCustomObject]@{
        userID            = $user.Id;
        username          = $userDetails.Username;
        userState         = $userDetails.State
        associatedSystems = $foundSystem
        associatedGroups  = $foundGroup
    }
}
# Write out the report
$list | ConvertTo-Csv | Out-File Report-UserToGroupAssociation.csv
```