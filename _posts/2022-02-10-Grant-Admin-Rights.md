---
layout: post
title: Grant System Administrator Right to User
description: Add/automate granting sudo/administrator right to user
tags:
  - powershell
  - settings
  - automation
---

This script prompts the user to enter username, system Id, and minutes of how long the user is going to be an admin/sudo. If no system Id is found, the script outputs a table of systems with hostname, id, and version that is bound to user. After granted admin status, the user will need to relogin to see the admin access change. The user is revoked admin status after x mins provided in the function. User must relogin to be demoted to standard user.

### Basic Usage

* The PowerShell Module is required to run this script
* Save the script to a location
* In a PowerShell terminal window, run the script `~/Path/To/Scrpt/filename.ps1`
* Follow the prompts to enter:
    * Username
    * System Id
    * Amount of minutes user is granted admin access
* User will need to re-login to be granted/revoked admin access

### Additional Information

This script will ask for username, system Id, minutes then 

### Script

```powershell
function Get-User {
    # Get users
    $users = Get-JcSdkUser
    #List of users with Id
    $userLst = @{}
    $UserName = Read-Host "Please enter in the JumpCloud Username of the target User you'd like to elevate to Sudo temporarily"
    #If UserName input is correct then get the UserId
    foreach ($user in $users) {
        #Create hash table that contains all users and their Id
        $userLst.Add($user.Username, $user.Id)
    }
    #Check if username/userId input in the JC
    if ($userLst.Contains($UserName)) {
        Write-Host "Id for username: $Username found: "$userLst.$UserName
        #Return if the username provided is correct
        return $userLst.$UserName
    }
    else {
        Do {
            $userInput = Read-Host "Username provided not found, please enter the correct username"
            if ($userInput -eq "exit") {
                break;
            }
        }
        Until ($userLst.Contains($userInput))
        Write-Host "User found: "$userInput
        return $userLst.$userInput
    }
}
function Get-SystemId {
    param (
        [Parameter()]
        [System.String]
        $UserId
    )
    $SystemId = Read-Host "Please enter the SystemID of the Device that needs Sudo/Admin privileges"
    # Get everyone from a group
    $systemAssociations = Get-JcSdkUserTraverseSystem -UserId $UserId
    #Systems bound to User
    $systemsBoundtoUser = @()
    foreach ($systemAssociation in $systemAssociations) {
        $systems = Get-JcSdkSystem -Id $systemAssociation.Id

        #Table of systems
        $devices = New-Object PSObject -property @{
            Hostname  = $systems.Hostname
            OS        = $systems.OS
            OSVersion = $systems.Version
            SystemId  = $systemAssociation.Id
        }
        $systemsBoundtoUser += $devices
    }
    if ($systemAssociations.Id.Contains($SystemId)) {
        Write-Host "Searched: " $SystemId "found in " $systemAssociations.Id
        return $SystemId
    } else {
        Write-Host ($systemsBoundtoUser | Out-String) -ForegroundColor Red
        Do {
            $systemInput = Read-Host "System Id provided not found. Please enter the hostname to grant admin rights" 
            if ($systemInput -eq "exit") {
                break;
            }
        }
        Until ($systemAssociations.Id.Contains($systemInput))
        Write-Host "System found: "$systemInput
        return $systemInput
    }
}
#Function to elevate permission in x amount of minutes then set the user back to its old permission
Function GrantElevatedPermissions {
    [CmdletBinding()]
    param (
        # The ID of the user to grant elevated permissions
        [Parameter()]
        [System.String]
        $UserId,
        # The ID of the system to grant a user elevated permissions
        [Parameter()]
        [System.String]
        $SystemId,
        # Minutes until the user's elevated permission is reverted
        [Parameter()]
        [System.Int32]
        $Mins
    )
    # If no sysId then print other systems linked to the User
    Write-Host "User with Id $UserId will be granted Admin permission on System with Id $SystemId"
    Write-Host "They will remain admin until $Mins minutes from now..."
    Write-Warning "Do not close this window until the script is finished or the user will remain admin!"
    # Calculate the seconds to sleep for 
    $SleepCalculated = $Mins * 60
    $attributes = [JumpCloud.SDK.V2.Models.IGraphOperationSystemAttributes]@{ 'sudo' = @{'enabled' = $true; 'withoutPassword' = $false } }
    # Set the user to admin
    Set-JcSdkSystemAssociation -systemid $SystemId -id $UserId -op 'update' -type 'user' -Attributes $attributes.AdditionalProperties
    # Sleep for x amount of minutes then sets the user back to old permissions
    Start-Sleep -Seconds $SleepCalculated
    # Sets the user back to old permissions
    Set-JcSdkSystemAssociation -systemid $SystemId -id $UserId -op 'update' -type 'user'
}
$user = Get-User($UserId)
$SysId = Get-SystemId -UserId $user
$Mins = Read-Host "How many minutes would you like to elevate this user for to Sudo/Admin for?"

GrantElevatedPermissions -Userid $user -systemid $SysId -mins $Mins
```