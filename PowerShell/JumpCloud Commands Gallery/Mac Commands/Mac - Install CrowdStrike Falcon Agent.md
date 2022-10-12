#### Name

Mac - Install CrowdStrike Falcon Agent | v2.0 JCCG

#### commandType

mac

#### Command

```bash
#!/bin/bash
CSBaseAddress=""
CSClientID=""
CSClientSecret=""

############### Do Not Edit Below This Line ###############

# API Base URL and the various endpoints we need
oauthtoken="$CSBaseAddress/oauth2/token"

# Define which version we want to get.
# 0 means latest. 1 is N-1, 2 is N-2 and so on.
version="0"

# Now define the API query we need
sensorlist="$CSBaseAddress/sensors/combined/installers/v1?offset=$version&limit=1&filter=platform%3A%22mac%22"
sensordl="$CSBaseAddress/sensors/entities/download-installer/v1"

# Request bearer access token using the API
token=$( /usr/bin/curl -s -X POST "$oauthtoken" -H "accept: application/json" -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=$CSClientID&client_secret=$CSClientSecret" )

# Extract the bearer token from the json output above
BEARER_REGEX_PATTERN='\"access_token\":\ \"(.+)\",'

if [[ $token =~ $BEARER_REGEX_PATTERN ]]; then
    bearer="${BASH_REMATCH[1]}"
    echo "Connected to CrowdStrike"
else
    echo "Could not find bearer token"
    exit 1
fi

# Work out the CrowdStrike installer, grab the SHA256 hash and use that to download that installer
sensorv=$( /usr/bin/curl -s -X GET "$sensorlist" -H "accept: application/json" -H "authorization: Bearer $bearer" )

SHA256_REGEX_PATTERN='\"sha256\":\ "([^"]*)"'

if [[ $sensorv =~ $SHA256_REGEX_PATTERN ]]; then
    sensorsha="${BASH_REMATCH[1]}"
else
    echo "Could not find sha256 hash"
    exit 1
fi

# Create Temp Folder
fileName="FalconSensor.pkg"
DATE=$(date '+%Y-%m-%d-%H-%M-%S')
TempFolder="Download-$DATE"
mkdir /tmp/$TempFolder
echo "Creating /tmp/$TempFolder..."

# Navigate to Temp Folder
cd /tmp/$TempFolder

# Download the client.
echo "Beginning CrowdStrike Sensor Download..."
download=$( /usr/bin/curl -H "Accept: application/octet-stream" -H "Authorization: bearer $bearer" -o "$fileName" "$sensordl?id=$sensorsha")
res=$?

if [[ "$res" != "0" ]]; then
    echo "Download failed with: $res"
    echo "Cleaning up files..."
    rm -r /tmp/$TempFolder
    echo "Deleted /tmp/$TempFolder"
    exit 1
fi

installer -verboseR -package "/tmp/$TempFolder/$fileName" -target /

# Validate the install and license status
stats=$(/Applications/Falcon.app/Contents/Resources/falconctl stats > /dev/null 2>&1)
statsStatus=$?
if [[ $statsStatus == 0 ]]; then
    echo "License was applied successfully"
else
    echo "License was not applied, please verify that the CrowdStrike Falcon MDM Settings profile is applied to this device"
    exit 1
fi

# Remove Temp Folder and download
rm -r /tmp/$TempFolder
echo "Deleted /tmp/$TempFolder"
```

#### Description

This command will download and install the CrowdStrike Falcon Agent to the device if it isn't already installed. The command will leverage CrowdStrike's API to find and download the latest version of the Falcon Agent onto the local machine.

In order to use this command, follow the instructions from the [Installing the CrowdStrike Falcon Agent KB](https://support.jumpcloud.com/s/article/Installing-the-Crowdstrike-Falcon-Agent)

Specifically for this command:

1. Create a CrowdStrike API Client with the "SENSOR DOWNLOAD" Read scope and make note of the ClientID and ClientSecret. Refer to CrowdStrike's article [Getting Access to the CrowdStrike API](https://www.crowdstrike.com/blog/tech-center/get-access-falcon-apis/) for further information
2. Set the 3 variables (CSBaseAddress, CSClientID, CSClientSecret) to their respective values for your CrowdStrike API Client
3. Extend the command timeout to a value that makes sense in your environment. The suggested command timeout for an environment with average network speeds on devices with average computing power is 10 minutes. Note that the command may timeout with a 124 error code in the command result window if not extended, but the script will continue to run.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Install%20CrowdStrike%20Falcon%20Agent.md"
```
