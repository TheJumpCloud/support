#### Name

Mac - Install CrowdStrike Falcon Agent | v1.0 JCCG

#### commandType

mac

#### Command

```bash
#!/bin/bash
DownloadUrl="https://path/to/url.pkg"
CID="ENTER CID WITH CHECKSUM VALUE HERE"

############### Do Not Edit Below This Line ###############

fileName="FalconSensor.pkg"
# Create Temp Folder
DATE=$(date '+%Y-%m-%d-%H-%M-%S')

TempFolder="Download-$DATE"

mkdir /tmp/$TempFolder

# Navigate to Temp Folder
cd /tmp/$TempFolder

# Download File into Temp Folder
curl -o "$fileName" "$DownloadUrl"

installer -verboseR -package "/tmp/$TempFolder/$fileName" -target /

sudo /Applications/Falcon.app/Contents/Resources/falconctl license $CID
echo "Validated license with CID & checksum value: $CID"

# Remove Temp Folder and download
rm -r /tmp/$TempFolder
echo "Deleted /tmp/$TempFolder"

```

#### Description

This command will download and install the CrowdStrike Falcon Agent to the device if it isn't already installed.

In order to use this command, follow the instructions from the [Installing the CrowdStrike Falcon Agent KB](https://support.jumpcloud.com/s/article/Installing-the-Crowdstrike-Falcon-Agent)

Specifically for this command:

1. Download the CrowdStrike Falcon Agent installer and host it at a URL that your devices can access. Set this URL to the "DownloadURL" of this script.
2. Extend the command timeout to a value that makes sense in your environment. The suggested command timeout for an environment with average network speeds on devices with average computing power is 10 minutes. Note that the command may timeout with a 124 error code in the command result window if not extended, but the script will continue to run.
3. It is recommended to set the Launch Event for the command to “Run As Repeating” with an interval of one hour.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Install%20CrowdStrike%20Falcon%20Agent.md"
```
