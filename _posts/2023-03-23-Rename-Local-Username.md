---
layout: post
title: Rename Local Username From CSV
description: This automation aims to help admins rename local user accounts on Windows and macOS hosts using a CSV file as reference.
tags:
  - powershell
  - bash
  - accounts
  - automation
---

Local user accounts in MacOS & Windows can be renamed with a remote automation. The requirements for these operating systems differ but the workflow detailed below is generally the same between the two.

In the macOS operating system workflow, users are logged out to the desktop, the automation runs the in the background and finally after a loginwindow refresh, the user whose account was renamed can login with their old password (local password)/ new password (JumpCloud Password)

In the Windows operating system workflow, users are simply renamed with the [rename-localUser cmdlet](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/rename-localuser?view=powershell-5.1). Their login username is refreshed after a successful login/ restart.

### Basic Usage

- The PowerShell Module is required to run this script
- Run a PowerShell script to determine what local user accounts are on each system, create a CSV with this data
- Manually edit this CSV file to determine which local user accounts should be renamed
- Validate this CSV file, create a new CSV file with stripped fields + upload to public location
- Create JumpCloud commands in the administrator portal
- Run the corresponding `renameLocalUser` commands on JumpCloud managed systems.

### Additional Information

To begin renaming local users, I've created a quick automation to help gather data about systems in a JumpCloud organization. This automation will produce a CSV with a systemID, renameUser & jumpcloudUser columns which we'll pass to the individual systems to kick off the rename scripts. ex:

| systemID | renameUser | jumpcloudUser |
| 609e98bd32a14f0f822e598d | Farmer_103 | farmer.103 |
| 60afdc5821a64317675f9f87 | Farmer_367 | farmer.367 |
| 60d347fab6a44816c875725c | Farmer_432 | farmer.432 |
| 610b255f8973970707a1e439 | Farmer_238 | farmer.238 |

JumpCloud systems run a script to download the CSV. Once downloaded, the script identifies the corresponding line containing it's systemID and attempts to migrate the `renameUser` to the `jumpcloudUser` username. Ex:

If a JumpCloud system with ID `60d347fab6a44816c875725c` runs the migration script:

- The host will download the entire CSV
- The script checks gets the JumpCloud systemID from a config.json file locally on the system.
- If the systemID matches a systemID in the CSV, the script notes the `renameUser:Farmer_432` username and attempts to migrate to `jumpCloudUser:farmer.432`
- If the script was able to rename the user, it'll bind the JumpCloud user to the system which will initiate an account takeover.

## Create the CSV

To get all the local username data about JumpCloud systems in an organization, we can run a powershell script to get each systems local username data

```powershell
# Get Data
$Data = Get-JCSystemInsights -Table User | Where-Object { ($_.Directory -match "C:\\Users*") -or ($_.Directory -match "/Users/*") -And ($_.username -ne "") } | Select-Object username, Directory, systemid
# Add column for jumpcloud username
$Data | Add-Member -Name 'jumpcloudUsername' -Value '' -MemberType NoteProperty
# export
$Data | Export-Csv -Path ./DiscoveryUsernames.csv
```

The code snippet above should generate a CSV similar to the following:

| Username | Directory | SystemId | jumpcloudUsername |
| totpuser | /Users/totpuser | 5e90f19ecc99d210ecb3406c | |
| defaultadmin | /Users/defaultadmin | 6010bf24471b3b196e81e888 | |
| Farmer_103 | /Users/Farmer_103 | 609e98bd32a14f0f822e598d | |
| Farmer_367 | /Users/Farmer_367 | 60afdc5821a64317675f9f87 | |

Manually iterate through each row and identify the systemsIDs/ usernames that need to be migrated. Add the JumpCloud Username of the users who should be migrated and delete the remaining rows. Only one unique systemID per CSV will work for this automation. I.e. the script can not migrate two users per system. Finally run this automation to validate and create the final CSV which we'll pass to systems before migration.

```powershell
# Get CSV
$data = Import-CSV -path ./DiscoveryUsernames.CSV
$dupes = $Data.SystemID | Group-Object
$dupeExit = $false
foreach ($line in $dupes) {
    if (($line.Count) -gt 1) {
        # If multiple entries are found for a given system, throw this error
        Write-Error "Multipe entries Found for SystemID: $($line.Name)"
        $dupeExit = $true
    }
}
if ($dupeExit) {
    Write-warning "exiting..."
    break
}

$newData = @()
foreach ($line in $data) {
    # $line
    # Validate User and JumpCLoudUserName Fields
    if ( [string]::IsNullOrEmpty($($line.Username)) ) {
        Write-Error "Missing username entry for SystemID: $($line.Name)"
        break
    }
    if ( [string]::IsNullOrEmpty($($line.jumpcloudUsername)) ) {
        Write-Error "Missing JumpCloud username entry for SystemID: $($line.Name)"
        break
    }
    if ( [string]::IsNullOrEmpty($($line.systemID)) ) {
        Write-Error "Missing systemID entry $($line)"
        break
    }
    # Finally create new CSV
    $newData += [PSCustomObject]@{
        systemID      = $line.systemID
        renameUser    = $line.Username
        jumpcloudUser = $line.jumpcloudUsername
    }
}
# Finally export the "MigrateUsers.CSV file
$newData | Export-Csv ./MigrateUsers.CSV

```

The resulting `MigrateUsers.CSV` from this script should be uploaded to a publicly accessible location.

## Add the scripts to JumpCloud

Create two commands in the JumpCloud console and copy the `renameLocalUsers.ps1` & the `reanmeLocalUsers.sh` code into Windows Powershell & MacOS commands (respectively).

Replace the variables in the commands:

Windows Powershell

```powershell
# Url where system/user CSV is stored:
$url = "https://path/to/example.csv"
# Your JumpCloud Administrator API Key; required to bind user
$jumpcloudAPIKey = 'yourJumpCloudAPIKey'
### Bind user as admin or standard user ###
# Admin user: admin="true"
# Standard user: admin="false"
$admin = $true
```

macOS

```bash
# Url where system/user CSV is stored:
url="https://path/to/example.csv"
# Your JumpCloud Administrator API Key; required to bind user
jumpcloudAPIKey='yourJumpCloudAPIKey'
### Bind user as admin or standard user ###
# Admin user: admin="true"
# Standard user: admin="false"
admin="true"
```

Run these commands on JumpCloud managed macOS and Windows systems. Test before mass deploying.

### Scripts

Windows Powershell

```powershell
################################################################################
# Update Variables Below
################################################################################

# Url where system/user CSV is stored:
$url = "https://path/to/example.csv"
# Your JumpCloud Administrator API Key; required to bind user
$jumpcloudAPIKey = 'yourAPIKey'
### Bind user as admin or standard user ###
# Admin user: admin="true"
# Standard user: admin="false"
$admin = $true

########## Do not edit below ##########

################################################################################
# Get the JumpCloud SystemID
################################################################################

$config = get-content 'C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.conf'
$regex = 'systemKey\":\"(\w+)\"'
$systemKey = [regex]::Match($config, $regex).Groups[1].Value
if ([string]::IsNullOrEmpty($systemKey)) {
    Write-Host "JumpCloud SystemID could not be verified, exiting..."
    exit 1
}
################################################################################
# Download CSV
################################################################################
$tempPath = "C:\Windows\Temp\users.csv"
# Download the Font to a Temp Location in C:
Invoke-WebRequest -Uri $url -OutFile $tempPath

$CSV = Get-Content -Path $tempPath | ConvertFrom-Csv
foreach ($line in $CSV) {
    <# $line is the current item #>
    if ($line.systemID -eq $systemKey) {
        Write-Host "SystemID: $($line.systemID)"
        Write-Host "UserToRename: $($line.renameUser)"
        Write-Host "JumpCloudUsername: $($line.jumpcloudUser)"
        $UserToRename = $($line.renameUser)
        $jumpcloudUsername = $($line.jumpcloudUser)
    }
}

if (([string]::IsNullOrEmpty($UserToRename)) -or ([string]::IsNullOrEmpty($jumpcloudUsername))) {
    Write-Host "User To Rename/ JumpCloud User/ System Record not found in CSV, exiting ..."
    exit 1
}

################################################################################
# Search for matching JumpCloud UserName
################################################################################
$jcUrl = "https://console.jumpcloud.com/api/search/systemusers"
$jcHeaders = @{
    "x-api-key"    = $jumpcloudAPIKey
    "Content-Type" = "application/json"
    "Accept"       = "application/json"
}

$jcBody = @{
    'filter' = "username:eq:$jumpcloudUsername"
    "fields" = "username"
} | ConvertTo-Json
Try {
    $response = Invoke-WebRequest -Uri $jcUrl -Headers $jcHeaders -body $jcBody -Method Post -UseBasicParsing
    $Results = $Response.Content | ConvertFrom-Json
    $StatusCode = $Response.StatusCode
} Catch {
    $StatusCode = $_.Exception.Response.StatusCode.value__
}
If ($StatusCode -ne 200) {
    Write-Host "JumpCloud username: $jumpcloudUsername not matched in directory"
    exit 1
}
If ($Results.totalCount -eq 1 -and $($Results.results[0].username) -eq $jumpcloudUsername) {
    Write-Host "Validated JumpCloud Username"
    $userID = $($Results.results._id)
}

################################################################################
# Gather User Variables
################################################################################

$users = Get-LocalUser
foreach ($user in $users) {
    if ($UserToRename -eq $user.Name) {
        Write-Host "Matched $UserToRename user found"
        $selectedUser = $UserToRename
    }
}
# If selectedUser is Null, exit
if ([string]::IsNullOrEmpty($selectedUser)) {
    Write-Host "Could not find user exiting... the following users exist:"
    Write-Host "$($users.Name)"
    exit 1
} else {
    Write-Host "$selectedUser will be renamed"
}


################################################################################
# Echo Status
################################################################################
Write-Host "###############################################"
Write-Host "### $selectedUser will be renamed to $jumpcloudUsername ###"
Write-Host "### $jumpcloudUsername is a jumpcloud user with userID: $userID ###"
Write-Host "### This system is jumpcloud bound with ID: $systemKey ###"
Write-Host "###############################################"

################################################################################
# migration script begin
################################################################################
# Rename Local User
Write-Host "Rename $selectedUser username to be $jumpcloudUsername"
Rename-LocalUser -Name $selectedUser -NewName $jumpcloudUsername

# Bind User Account
$jcUrl = "https://console.jumpcloud.com/api/v2/systems/$systemKey/associations"
$jcBody = @{
    'attributes' = @{
        'sudo' = @{
            'enabled'         = $admin
            'withoutPassword' = $false
        }
    }
    'op'         = 'add'
    'type'       = 'user'
    'id'         = $userID
} | ConvertTo-Json
Try {
    $responseBind = Invoke-WebRequest -Uri $jcUrl -Headers $jcHeaders -body $jcBody -Method Post
    $Results = $responseBind.Content | ConvertFrom-Json
    $StatusCode = $responseBind.StatusCode
} Catch {
    $StatusCode = $_.Exception.responseBind.StatusCode.value__
}
```

macOS Script

```bash
#!/bin/bash

################################################################################
# Update Variables Below
################################################################################

# Url where system/user CSV is stored:
url="https://path/to/example.csv"
# Your JumpCloud Administrator API Key; required to bind user
jumpcloudAPIKey='yourAPIKey'
### Bind user as admin or standard user ###
# Admin user: admin="true"
# Standard user: admin="false"
admin="true"

########## Do not edit below ##########

################################################################################
# Get the JumpCloud SystemID
################################################################################
conf="$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'
if [[ $conf =~ $regex ]]; then
    systemKey="${BASH_REMATCH[@]}"
fi
regex='[a-zA-Z0-9]{24}'
if [[ $systemKey =~ $regex ]]; then
    systemID="${BASH_REMATCH[@]}"
else
    echo "JumpCloud SystemID could not be verified, exiting..."
    exit 1
fi

################################################################################
# Download CSV
################################################################################
# Set temp location for user CSV
csv="/tmp/users.csv"
# Download the url of the users list to the temp location
curl -s -o "$csv" "$url"
# Read out lines in CSV, if match between CSV && SystemID, populate vars
while IFS="," read -r CSV_systemID CSV_UserToRename CSV_JumpCloudUser
do
    if [[ $CSV_systemID == "$systemID" ]];then
        echo "SystemID: $CSV_systemID"
        echo "UserToRename: $CSV_UserToRename"
        # strip whitespace if exists
        UserToRename=$(echo "$CSV_UserToRename" | xargs)
        echo "JumpCloudUsername: $CSV_JumpCloudUser"
        # strip whitespace if exists
        jumpcloudUsername=$(echo "$CSV_JumpCloudUser" | xargs)
        echo ""
    fi
done < $csv

################################################################################
# Get Local Accounts on system and see if UserToRename exists
################################################################################
# Get the localAccounts on the system
localAccounts=$(dscl . list /Users UniqueID | awk '$2>500{print $1}' | grep -v super.admin | grep -v _jumpcloudserviceaccount)

for usr in ${localAccounts};
do
    if [[ $usr == $UserToRename ]]; then
        echo "Matched $UserToRename user found"
        # selectedUser is the username we'll be renaming
        selectedUser=$UserToRename
    fi
done

# If selectedUser is Null, exit
if [[ $selectedUser == "" ]]; then
    echo "Could not find user exiting... the following users exist:"
    echo "$localAccounts"
    exit 1
else
    echo "$selectedUser will be renamed"
fi
################################################################################
# Search for matching JumpCloud UserName
################################################################################
userSearch=$(
    curl -s -X POST https://console.jumpcloud.com/api/search/systemusers \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "x-api-key: ${jumpcloudAPIKey}" \
  -d '{"filter":[{"username":"'$jumpcloudUsername'"}],"fields":["username"]}'
)
regex='[a-zA-Z0-9]{24}'
if [[ $userSearch =~ $regex ]]; then
    userID="${BASH_REMATCH[@]}"
else
    exit 1
fi

# Validate username
if [[ $userSearch == "" ]]; then
    echo "JumpCloud username: $jumpcloudUsername not matched in directory"
    exit 1
else
    echo "validated JumpCloud username"
fi

################################################################################
# Gather User Variables
################################################################################
# Capture active user username
loggedInUser=$( ls -l /dev/console | awk '{print $3}' )

# Captures active users ID && details about the selectedUser
UserUID=$( id -u "$loggedInUser" )
userRealName=$( /usr/bin/dscl . -read /Users/"${selectedUser}" | /usr/bin/grep RealName: | cut -c11- )
userRecordName=$( /usr/bin/dscl . -read /Users/"${selectedUser}" | /usr/bin/grep RecordName: | cut -c13- )
user_home_location=$( /usr/bin/dscl . -read /Users/"${selectedUser}" NFSHomeDirectory 2>/dev/null | /usr/bin/sed 's/^[^/]*//g' )

# Determine found admin status
if [[ $(/usr/bin/dsmemberutil checkmembership -U "${selectedUser}" -G admin) != *not* ]]; then
    userIsAdmin="yes"
else
    userIsAdmin="no"
fi

################################################################################
# Echo Status
################################################################################
echo "###############################################"
echo "### $selectedUser will be renamed to $jumpcloudUsername ###"
echo "### $jumpcloudUsername is a jumpcloud user with userID: $userID ###"
echo "### This system is jumpcloud bound with ID: $systemID ###"
echo "### $selectedUser is admin: $userIsAdmin ###"
# admin status:
if [[ $admin == 'false' && $userIsAdmin == 'no' ]]; then
    echo "Set Admin status False, Found status False"
    echo "User will remain standard"
elif [[ $admin == 'true' && $userIsAdmin == 'no' ]]; then
    echo "Set Admin status true, Found status False"
    echo "User will become admin"
elif [[ $admin == 'false' && $userIsAdmin == 'yes' ]]; then
    echo "Set Admin status false, Found status true"
    echo "User will be demoted from admin to standard"
elif [[ $admin == 'true' && $userIsAdmin == 'yes' ]]; then
    echo "Set Admin status true, Found status true"
    echo "User will be remain admin"
fi
echo "### $loggedInUser is currently logged in ###"
echo "###############################################"

################################################################################
# migration script begin
################################################################################
echo "Sleep for five seconds"
/bin/sleep 5
# Force logout
echo "Force logout ..."
/bin/ps -Ajc | /usr/bin/grep loginwindow | /usr/bin/awk '{print $2}' | /usr/bin/xargs /bin/kill -9
echo "Sleep for five seconds"
/bin/sleep 5

# Rename local username
echo "Change Local Username Home Directory"
dscl . -change "${user_home_location}" NFSHomeDirectory "${user_home_location}" "/Users/${jumpcloudUsername}"
if [[ $? -ne 0 ]]; then
	echo "Error: Could not rename the user's home directory pointer, aborting further changes! - err=$?"
	echo "Notice: Reverting Home Directory changes" 2>&1
	dscl . -change "/Users/${selectedUser}" NFSHomeDirectory "/Users/${jumpcloudUsername}" "${user_home_location}"
	exit 1
fi
# Rename home directory
echo "Renaming Home Directory"
mv "${user_home_location}" "/Users/${jumpcloudUsername}"
if [[ $? -ne 0 ]]; then
	echo "Error: Could not rename the user's home directory in /Users"
	echo "Notice: Reverting Home Directory changes"
	mv "/Users/${jumpcloudUsername}" "${user_home_location}"
	dscl . -change "/Users/${selectedUser}" NFSHomeDirectory "/Users/${jumpcloudUsername}" "${user_home_location}"
	exit 1
fi
# Rename Username
echo "Rename $selectedUser username to be $jumpcloudUsername"
dscl . -change "${user_home_location}" RecordName "${userRecordName}" "${jumpcloudUsername}"
if [[ $? -ne 0 ]]; then
	echo "Error: Could not rename the user's RecordName in dscl - the user should still be able to login, but with user name ${selectedUser}"
	echo "Notice: Reverting username change"
	dscl . -change "/Users/${selectedUser}" RecordName "${jumpcloudUsername}" "${selectedUser}"
	echo "Notice: Reverting Home Directory changes"
	mv "/Users/${jumpcloudUsername}" "${user_home_location}"
	dscl . -change "/Users/${selectedUser}" NFSHomeDirectory "/Users/${jumpcloudUsername}" "${user_home_location}"
	exit 1
fi
# Create local user account ...
echo "Takeover ${selectedUser} local account with JumpCloud Agent"
userBind=$(
    curl -s \
        -X 'POST' \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H 'x-api-key: '${jumpcloudAPIKey}'' \
        -d '{ "attributes": { "sudo": { "enabled": '${admin}',"withoutPassword": false}}   , "op": "add", "type": "user","id": "'${userID}'"}' \
        "https://console.jumpcloud.com/api/v2/systems/${systemID}/associations"
)

# wait a moment at login screen
# Wait for user updates to complete
# Get JCAgent.log to ensure user updates have been processes on the system
logLinesRaw=$(wc -l /var/log/jcagent.log)
logLines=$(echo $logLinesRaw | head -n1 | awk '{print $1;}')
groupSwitchCheck=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)
groupTakeOverCheck=$(echo ${groupSwitchCheck} | grep "User updates complete")

# Get current Time
now=$(date "+%y/%m/%d %H:%M:%S")
# Get last line of the JumpCloud Agent
lstLine=$(tail -1 /var/log/jcagent.log)
regexLine='([0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9])'
if [[ $lstLine =~ $regexLine ]]; then
    # Get the time form the agent log
    lstTime=${BASH_REMATCH[0]}
fi
echo "$(date "+%Y-%m-%d %H:%M:%S"): Current System Time       : $now"
echo "$(date "+%Y-%m-%d %H:%M:%S"): JCAgent Last Log Time     : $lstTime"
# convert to Epoch time
nowEpoch=$(date -j -f "%y/%m/%d %T" "${now}" +'%s')
jclogEpoch=$(date -j -f "%y-%m-%d %T" "${lstTime}" +'%s')
echo "$(date "+%Y-%m-%d %H:%M:%S"): Current System Epoch Time : $nowEpoch"
echo "$(date "+%Y-%m-%d %H:%M:%S"): Last JCAgent Epoch Time   : $jclogEpoch"
# get the difference in time
epochDiff=$(( (nowEpoch - jclogEpoch) ))
echo "$(date "+%Y-%m-%d %H:%M:%S"): Difference between logs is: $epochDiff seconds"

# Check the JCAgent log, it should check in under 180s
while [[ $epochDiff -le 180 ]]; do
    # wait a second and update all the variables
    Sleep 1
    groupSwitchCheck=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)
    groupTakeOverCheck=$(echo ${groupSwitchCheck} | grep "Processing user updates")
    lstLine=$(tail -1 /var/log/jcagent.log)
    regexLine='([0-9][0-9])-([0-9][0-9])-([0-9][0-9]) ([0-9][0-9]:[0-9][0-9]:[0-9][0-9])'
    if [[ $lstLine =~ $regexLine ]]; then
        lstTime=${BASH_REMATCH[0]}
    fi
    jclogEpoch=$(date -j -f "%y-%m-%d %T" "${lstTime}" +'%s')
            now=$(date "+%y/%m/%d %H:%M:%S")
            nowEpoch=$(date -j -f "%y/%m/%d %T" "${now}" +'%s')
            epochDiff=$(( (nowEpoch - jclogEpoch) ))
    # if the log is empty continue while loop
    if [[ -z $groupTakeOverCheck ]]; then
        echo "$(date "+%Y-%m-%d %H:%M:%S"): Waiting for log sync, JCAgent last log was: $epochDiff seconds ago"
        echo "$(date "+%Y-%m-%d %H:%M:%S"): JCAgent last line: $lstLine"
    else
        now=$(date "+%y/%m/%d %H:%M:%S")
        # log found, break out of the while loop
        echo "$(date "+%Y-%m-%d %H:%M:%S"): Log Synced! User Updates Complete $now"
        # echo "$(date "+%Y-%m-%d %H:%M:%S"): $groupTakeOverCheck" >>"$DEP_N_DEBUG"
        break
    fi
    # # if the time difference is greater than 90 seconds, restart the JumpCloud agent to begin logging again
    # if [[ $epochDiff -eq 90 ]]; then
    #     echo "$(date "+%Y-%m-%d %H:%M:%S"): JumpCloud not reporting local account takeover"
    #     echo "$(date "+%Y-%m-%d %H:%M:%S"): Waking the JumpCloud Agent"
    #     /opt/jc/bin/jumpcloud-agent
    # fi
done

# Links old home directory to new. Fixes dock mapping issue
ln -s "/Users/${jumpcloudUsername}" "${user_home_location}"

# restart login window
killall loginwindow
## End Script ##
exit 0
```
