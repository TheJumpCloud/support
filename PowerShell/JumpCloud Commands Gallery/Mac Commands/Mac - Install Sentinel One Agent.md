#### Name

Mac - Install Sentinel One Agent | v1.0.1 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash

sentinelToken="YOURTOKEN"
DownloadURL="https://path/to/url.pkg"

############### Do Not Edit Below This Line ###############
set -e

filename="sentineloneagent.pkg"

# Check if already installed
if [[ -d /Applications/SentinelOne/ ]]
  then
    echo "Sentinel One Agent is Already Installed. Exiting..."
    exit 0
fi

# Create A Unique Temp Folder
#
UUID=$(uuidgen)
TempFolder="Download-$UUID"
mkdir /tmp/$TempFolder

# Navigate to Temp Folder
#
cd /tmp/$TempFolder

# Download Sentinel One file
curl --fail -o "$filename" "$DownloadURL"

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

# Check signature and install
check_pkg_sign=$(pkgutil --check-signature $PKGFile)
if [[ $check_pkg_sign == *"AYE5J54KN"* ]] && [[ $check_pkg_sign == *"Status: signed by a developer certificate issued by Apple"* ]] && [[ $check_pkg_sign == *"Notarization: trusted by the Apple notary service"* ]]
then
    echo "Package is signed. Installing..."

    # Install Agent
    /usr/sbin/installer -pkg /tmp/$TempFolder/$PKGFile -target /Applications
else
    echo "Package is unsigned. Exiting..."
    exit 1
fi

# Remove Temp Folder and download
rm -r /tmp/$TempFolder
echo "Deleted /tmp/$TempFolder"
```

#### Description

This command will download and install the Sentinel One Agent to the device if it isn't already installed.

Specifically for this command:

1. Download the Sentinel One Agent installer and host it at a URL that your devices can access. Set this URL to the "DownloadURL" of this script.
2. Extend the command timeout to a value that makes sense in your environment. The suggested command timeout for an environment with average network speeds on devices with average computing power is 10 minutes. Note that the command may timeout with a 124 error code in the command result window if not extended, but the script will continue to run.
#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Install%20Sentinel%20One%20Agent.md"
```
