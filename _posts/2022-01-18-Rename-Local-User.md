---
layout: post
title: Rename Windows Local User
description: Rename local users on Windows workstations in situations where the workstation was provisioned with a local admin account
tags:
  - powershell
  - automation
  - windows
  - users
---

The purpose of this script is to rename local users on Windows workstations in situations where the workstation was provisioned with a local admin account

### Basic Usage

1. Create the following System Groups (these will be used for logging purposes):
  * beforeRename
  * afterRename
  * failedRename

2. A CSV is generated containing the following fields:
```csv
localAccount	systemID	systemOS	systemHostname	systemDisplayname	provisionerID	provisionerUsername	userID	potentialUsers	localUsersOnSystem	UserToRename
```
Example:
![image](https://user-images.githubusercontent.com/89030113/138946524-6ff8df53-1d4d-43e1-9355-087de742f0ea.png)

3. Add all systems that you would like to run the script against to the ``beforeRename`` System Group.

## Directions
#### Edit the variables between lines 7 and 22 with the appropriate values for your environment

```powershell
$systems = Import-Csv 'C:\Windows\Temp\renameWindowsUsers.csv'

# API KEY
$JumpCloudApiKey = '<JCAPIKey>'
# Get System Key
$config = get-content 'C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.conf'
$regex = 'systemKey\":\"(\w+)\"'
$systemKey = [regex]::Match($config, $regex).Groups[1].Value

# System Group IDs
# Before account rename group
$beforeRenameGroupID = '<beforeRenameGroupID>'
# After account rename group
$afterRenameGroupID = '<afterRenameGroupID>'
# Failure Group
$failureGroupID = '<failedRenameGroupID>'
```

#### Configure your Command similar to the following:
![image](https://user-images.githubusercontent.com/89030113/138946001-40420158-55ca-4c7f-8e19-67bf9a743d2b.png)
![image](https://user-images.githubusercontent.com/89030113/138946089-4cdfde53-6282-439b-a0a5-16485b7047fa.png)

### Script

```powershell
################################################################################
# This script will pull the provisionerID from the JumpCloud console and rename
# the specified user account to the matching username in JumpCloud. This script
# will not rename or remap the user's home directory.
################################################################################

$systems = Import-Csv 'C:\Windows\Temp\renameWindowsUsers.csv'

# API KEY
$JumpCloudApiKey = '<JCAPIKey>'
# Get System Key
$config = get-content 'C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.conf'
$regex = 'systemKey\":\"(\w+)\"'
$systemKey = [regex]::Match($config, $regex).Groups[1].Value

# System Group IDs
# Before account rename group
$beforeRenameGroupID = '<beforeRenameGroupID>'
# After account rename group
$afterRenameGroupID = '<afterRenameGroupID>'
# Failure Group
$failureGroupID = '<failedRenameGroupID>'

foreach ($system in $systems)
{
    if ($systemKey -match $system.SystemID)
    {
        # User to match and rename (case insensitive)
        $UserToRename = $system.UserToRename
        $ProvisionerID = $system.provisionerID
        $systemID = $system.SystemID
        $ProvisionerUsername = $system.provisionerUsername
    }
}
# "UserToRename ProvisionerID systemID ProvisionerUsername" is not null or empty
if ([System.String]::IsNullOrEmpty($UserToRename))
{
    throw "UserToRename is null"
    exit 1
}
elseif ([System.String]::IsNullOrEmpty($ProvisionerID))
{
    throw "ProvisionerID is null"
    exit 1
}
elseif ([System.String]::IsNullOrEmpty($systemID))
{
    throw "SystemID is null"
    exit 1
}
elseif ([System.String]::IsNullOrEmpty($ProvisionerUsername))
{
    throw "ProvisionerUsername is null"
    exit 1
}

Write-Host "User Found : $UserToRename"
Write-Host "System Found: $systemID"

################################################################################
# Get Local Accounts on system and see if UserToRename exists
################################################################################

$localUsers = Get-LocalUser
foreach ($username in $localUsers.name)
{
    if ($username -match $UserToRename)
    {
        # Set Selected Username Variable
        write-host "Matched $UserToRename user found"
        $SelectedUser = $username
    }
}
if ([System.String]::IsNullOrEmpty($SelectedUser))
{
    throw "$UserToRename was not found on the system"
    # Add system to failure group & remove from before rename group
    $headers = @{
        Accept      = "application/json";
        'x-api-key' = $JumpCloudApiKey;
    }
    $body = @{
        'id'   = "$systemKey"
        'op'   = "add"
        'type' = "system"
    } | ConvertTo-Json
    Invoke-WebRequest -Method Post -Uri "https://console.jumpcloud.com/api/v2/systemgroups/$failureGroupID/members" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
    $headers = @{
        Accept      = "application/json";
        'x-api-key' = $JumpCloudApiKey;
    }
    $body = @{
        'id'   = "$systemKey"
        'op'   = "remove"
        'type' = "system"
    } | ConvertTo-Json
    Invoke-WebRequest -Method Post -Uri "https://console.jumpcloud.com/api/v2/systemgroups/$beforeRenameGroupID/members" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
    exit
}
################################################################################
# Now try to match the Provisioner User from the System Record in JumpCloud
################################################################################

# exit if this is null
if ([System.String]::IsNullOrEmpty($ProvisionerUsername))
{
    throw "ProvisionerUsername does not exist for this system record"
    # Add system to failure group & remove from before rename group
    $headers = @{
        Accept      = "application/json";
        'x-api-key' = $JumpCloudApiKey;
    }
    $body = @{
        'id'   = "$systemKey"
        'op'   = "add"
        'type' = "system"
    } | ConvertTo-Json
    $groupAdd = Invoke-WebRequest -Method Post -Uri "https://console.jumpcloud.com/api/v2/systemgroups/$failureGroupID/members" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
    # Finally add system to the completed group
    $headers = @{
        Accept      = "application/json";
        'x-api-key' = $JumpCloudApiKey;
    }
    $body = @{
        'id'   = "$systemKey"
        'op'   = "remove"
        'type' = "system"
    } | ConvertTo-Json
    $groupRemove = Invoke-WebRequest -Method Post -Uri "https://console.jumpcloud.com/api/v2/systemgroups/$beforeRenameGroupID/members" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
    exit
}

write-host "######## User Details ########"
write-host "UserID: $ProvisionerID"
write-host "UserName: $ProvisionerUsername"
write-host "##############################"

################################################################################
# Finally attempt to change the username to ProvisionerUsername
################################################################################

# Change the local username to the new user
rename-localuser -name $SelectedUser -newname $ProvisionerUsername -ErrorVariable errortext
if ($errortext)
{
    throw "Could not set username, exiting..."
    $body = @{
        'id'   = "$systemKey"
        'op'   = "add"
        'type' = "system"
    } | ConvertTo-Json
    $groupAdd = Invoke-WebRequest -Method Post -Uri "https://console.jumpcloud.com/api/v2/systemgroups/$failureGroupID/members" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
    # Finally add system to the completed group
    $headers = @{
        Accept      = "application/json";
        'x-api-key' = $JumpCloudApiKey;
    }
    $body = @{
        'id'   = "$systemKey"
        'op'   = "remove"
        'type' = "system"
    } | ConvertTo-Json
    $groupRemove = Invoke-WebRequest -Method Post -Uri "https://console.jumpcloud.com/api/v2/systemgroups/$beforeRenameGroupID/members" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
    exit
}
else
{
    write-host "$SelectedUser renamed to $ProvisionerUsername"
}

################################################################################
# Group assignment
################################################################################

# If script was successful, remove from the command assignment group
$headers = @{
    Accept      = "application/json";
    'x-api-key' = $JumpCloudApiKey;
}
$body = @{
    'id'   = "$systemKey"
    'op'   = "remove"
    'type' = "system"
} | ConvertTo-Json
$groupRemove = Invoke-WebRequest -Method Post -Uri "https://console.jumpcloud.com/api/v2/systemgroups/$beforeRenameGroupID/members" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
# Finally add system to the completed group
$headers = @{
    Accept      = "application/json";
    'x-api-key' = $JumpCloudApiKey;
}
$body = @{
    'id'   = "$systemKey"
    'op'   = "add"
    'type' = "system"
} | ConvertTo-Json
$groupAdd = Invoke-WebRequest -Method Post -Uri "https://console.jumpcloud.com/api/v2/systemgroups/$afterRenameGroupID/members" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing

# Bind the user to the system
$headers = @{
    Accept      = "application/json";
    'x-api-key' = $JumpCloudApiKey;
}
$body = @{
    'id'   = "$ProvisionerID"
    'op'   = "add"
    'type' = "user"
} | ConvertTo-Json
$userBind = Invoke-WebRequest -Method Post -Uri "https://console.jumpcloud.com/api/v2/systems/${systemKey}/associations" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
# After reboot the username and fullname fields should be set in the UI
# After first login the FullName Field for the account should be set.
```