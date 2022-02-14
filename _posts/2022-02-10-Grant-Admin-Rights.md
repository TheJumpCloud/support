---
layout: post
title: Grant Administrator Right to User
description: Grant sudo/administrator right to user and its bound systems
tags:
  - powershell
  - settings
  - automation
---
The purpose of this script is to grant admin access to a JumpCloud user to a bound system.
This script prompts the user to enter username, system Id, and minutes of how long the user is going to be an admin/sudo. After granted admin status, the user will need to re-login if on Windows machine to see the admin access change. The user is revoked admin status after x mins. User must re-login if on Windows machine to be demoted to standard user. 

### Basic Usage

* The PowerShell Module is required to run this script
* Save the script to your desired location
* In a PowerShell terminal window, run the script `~/Path/To/Scrpt/filename.ps1`
* Follow the prompts to enter:
    * Username
    * System Id
    * Amount of minutes user is granted admin access
* User will need to re-login if on Windows Machine to be granted/revoked admin access

### Additional Information

* Run the script from your desired directory
* Mac and Linux machines will not need to re-login

* Powershell prompts to grant admin rights
![Grant admin prompts](./../../../images/grantAdminPrompts.gif)


* JumpCloud portal permission change
![Grant admin Jc portal](./../../../images/grantAdminJcPortal.gif)
### Script

```powershell
function Get-User 
{
    $Username = Read-Host "Please enter the target JumpCloud User you'd like to elevate to admin/sudo temporarily"

    # Get users
    $users = Get-JCUser -UserName $UserName
    #Check if username/userId input in the JC
    if ($users) {
        Write-Host "User found" -ForegroundColor Yellow
        #Return if the username provided is correct
        return $users.Id
    }
    else 
    {
        Do 
        {
            $UserName = Read-Host "Username provided not found, please enter the correct username"
            if ($UserName -eq "exit") 
            {
                break;
            }
           $users = Get-JCUser -UserName $UserName
        }
        Until ($users)
        Write-Host "User found" -ForegroundColor Yellow
        return $users.Id
    }
}
function Get-SystemId 
{
    param (
        [Parameter()]
        [System.String]
        $UserId
    )
    # Get everyone from a group
    $systemAssociations = Get-JcSdkUserTraverseSystem -UserId $UserId
    # Systems bound to User
    $systemsBoundtoUser = @()
    foreach ($systemAssociation in $systemAssociations) 
    {
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

    # Output the systems bound to user
    Write-Host "Systems that are bound to user" ($systemsBoundtoUser | Out-String) -ForegroundColor Blue
    $SystemId = Read-Host "Please enter the SystemId that needs sudo/admin privileges"
    if ($systemAssociations.Id.Contains($SystemId)) 
    {
        Write-Host "System Id found" -ForegroundColor Yellow
        return $SystemId
    } 
    else
     {
        Do 
        {
            $systemInput = Read-Host "System Id provided not found. Please enter the system id to grant admin rights" 
            if ($systemInput -eq "exit") 
            {
                break;
            }
        }
        Until ($systemAssociations.Id.Contains($systemInput))
        Write-Host "System found" -ForegroundColor Yellow
        return $systemInput
    }
}
#Function to elevate permission in x amount of minutes then revokes admin right to user
Function GrantElevatedPermissions 
{
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
    # Admin attributes
    $attributes = [JumpCloud.SDK.V2.Models.IGraphOperationSystemAttributes]@{ 'sudo' = @{'enabled' = $true; 'withoutPassword' = $false } }
    # Set the user to admin
    Set-JcSdkSystemAssociation -systemid $SystemId -id $UserId -op 'update' -type 'user' -Attributes $attributes.AdditionalProperties
    # Sleep for x amount of minutes then sets the user back to old permissions
    Start-Sleep -Seconds $SleepCalculated
    # Sets the user back to old permissions
    Set-JcSdkSystemAssociation -systemid $SystemId -id $UserId -op 'update' -type 'user'
    Write-Warning "Please re-login if on Windows machine to update admin rights"
}
$user = Get-User
$SysId = Get-SystemId -UserId $user
$Mins = Read-Host "How many minutes would you like to elevate this user for to Sudo/Admin for?"

GrantElevatedPermissions -Userid $user -systemid $SysId -mins $Mins
```
