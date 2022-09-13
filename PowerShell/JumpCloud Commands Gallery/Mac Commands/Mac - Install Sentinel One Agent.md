#### Name

Mac - Install Sentinel One Agent | v1.0 JCCG

#### commandType

mac

#### Command

```bash
#!/bin/bash

# VARS
###################################################
export sentinelToken=YOURTOKEN
export filename=sentineloneagent.pkg
export DownloadURL=YOURDOWNLOADURL
###################################################

# Test if already installed
if [[ -d /Applications/SentinelOne/ ]]
  then
    echo "Sentinel One Agent is Already Installed. Exiting..."
    exit 0
fi

# Create Temp Folder
#
DATE=$(date '+%Y-%m-%d-%H-%M-%S')
TempFolder="Download-$DATE"
mkdir /tmp/$TempFolder

# Navigate to Temp Folder
#
cd /tmp/$TempFolder

# Download Sentinel One file
curl -o $filename $DownloadURL


DownloadFile="$(ls)"
echo "Downloaded $DownloadFile to /tmp/$TempFolder"

# Verifies PKG File
#
regex='\.pkg$'
if [[ $DownloadFile =~ $regex ]]; then
    PKGFile="$(echo "$DownloadFile")"
    echo "PKG File Found: $PKGFile"
else
    echo "File: $DownloadFile is not a PKG"
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1
fi

#Set Token
echo $sentinelToken > /tmp/$TempFolder/com.sentinelone.registration-token

#Install Agent
/usr/sbin/installer -pkg /tmp/$TempFolder/$PKGFile -target /Applications

# Remove Temp Folder and download
#
rm -r /tmp/$TempFolder
echo "Deleted /tmp/$TempFolder"
```

#### Description

This command will download and install the Sentinel One Agent to the device if it isn't already installed.

In order to use this command, follow the instructions from the [Installing the Sentinel One Agent KB](https://support.jumpcloud.com/s/article/Installing-the-SentinelOne-Falcon-Agent)

Specifically for this command:

1. Download the Sentinel One Agent installer and host it at a URL that your devices can access. Set this URL to the "DownloadURL" of this script.
2. Extend the command timeout to a value that makes sense in your environment. The suggested command timeout for an environment with average network speeds on devices with average computing power is 10 minutes. Note that the command may timeout with a 124 error code in the command result window if not extended, but the script will continue to run.
#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Install%20Sentinel One%20Falcon%20Agent.md"
```
