---
layout: post
title: Create Local Groups based off of JumpCloud User Groups
description: Generates local user groups on workstations based off of existing JumpCloud User Groups
tags:
  - powershell
  - windows
  - groups
  - automation
---

This script was made for the purpose of creating local user groups based off of existing JumpCloud User Groups. A usage example would be creating local network shares on a workstation/server

### Basic Usage

* The PowerShell Module is required to run this script
* Save the script to a location
* Edit the `$userGroupName` and `$api_key` variables with your desired group name and organization API key
* In a PowerShell terminal window, run the script `~/Path/To/Scrpt/filename.ps1`

### Additional Information

This script strictly adds users to the local user groups, it does not check if previous users that were added are no longer in the group.

### Script

```powershell
$userGroupName = "UserGroupName"

# Input organization's API key
$api_key = "apiKeyHere"

# Validate the script is being run with admin permissions
Write-Host "Checking for elevated permissions..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
          [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
    Break
}
else {
    Write-Host "Code is running as administrator — go on executing the script..." -ForegroundColor Green
}

# Connect to PowerShell module
Connect-JCOnline -force $api_key

# Gets the User Group information based off of inputted name
try {
    $userGroup = Get-JCGroup -type User -Name $userGroupName
}
catch {
    Write-Host "An error occurred:"
    Write-Host $_
    Break
}


# Create a local group using the JumpCloud's UserGroup's description and name
if (Get-LocalGroup -Name $userGroupName -erroraction 'silentlycontinue') {
    Write-Host "The local group $($userGroup.name) already exists on the local machine `n" -ForegroundColor Green
}else {
    New-LocalGroup -Name $userGroup.name
    Write-Host "Created new Local Group $($userGroup.name) `n" -ForegroundColor Green
}

# Gets list of members of the specified user group
$userGroupMembers = $userGroup | Get-JCUserGroupMember

# Logging variables
$successUsers = "The following users were successfully added to $($userGroup.name): "
$existingUsers = "The following users already exist in local group $($userGroup.name): "
$failedUsers = "The following users were unable to be added with associated reason(s): "

# Add users to created Local Group
try {
    $userGroupMembers | 
    ForEach-Object { 
        # Validate the local user exists
        if (Get-LocalUser -Name $_.Username -erroraction 'silentlycontinue') {
            # Validate if the local user already belongs to the local group
            if (Get-LocalGroupMember -Group $userGroup.name -Member $_.Username -erroraction 'silentlycontinue') {
                $existingUsers += "`n $($_.Username)"
            }else {
                # Add the local user to the local group
                Add-LocalGroupMember -Group $userGroup.name -Member $_.Username
                $successUsers += "`n $($_.Username)"
            }
        }else {
            $failedUsers += "`n $($_.Username) - not bound to the local machine"
        }
    }
    $successUsers + "`n"
    $existingUsers + "`n"
    $failedUsers + "`n"
}
catch {
    Write-Host "An error occurred:"
    Write-Host $_
}
```