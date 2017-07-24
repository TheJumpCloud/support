#!/bin/bash

###############################################################################
#
# dhcpRadiusUpdate.sh - This script will use ipecho.net to compare the reported
#      IP address with the current IP address defined in a JumpCloud radius
#      server. It is recommended to define radiusId manually, but if not, it
#      will query the first returned record from the API and check if it needs
#      to update it. If there's only 1 record, this is fine. 
#
#      *** If there are multiple RADIUS Ids, this is potentially destructive.  
#      Know which record is being updated.***
#
#      REQUIRED: root, wget, curl, jq, JumpCloud API Key
#      USAGE: This can be set to run as a cron, e.g., every hour at minute 0:
#      
#      $ crontab -e
#      0 * * * * /opt/dhcpRadiusUpdate.sh > /var/log/radupdate.log 2>&1
#
###############################################################################

# Got root?

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" && exit 1
fi

# Define Vars
apiKey=
radiusId=
newIp=$(wget http://ipecho.net/plain -O - -q)

# Check if newIp exited 0

if [ $? -ne 0 ]; then
    echo "Unable to determine newIp, exiting..." && exit 1
fi

# Get the currentIp

getCurrentIp() {

curl \
  -X 'GET' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  "https://console.jumpcloud.com/api/radiusservers/${radiusId}"

}

# Get the RADIUS Id

getRadiusId() {

curl \
  -X 'GET' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  "https://console.jumpcloud.com/api/radiusservers"

}

# Update the RADIUS IP

putRadius() {

curl \
  -X 'PUT' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  -d '{"networkSourceIp":"'"${newIp}"'"}' \
  "https://console.jumpcloud.com/api/radiusservers/${radiusId}"

}

# Got apiKey?

if [ -z ${apiKey} ]; then
    echo "apiKey must be defined, exiting..." && exit 1
fi

# Got radiusId?

if [ -z ${radiusId} ]; then
    current=($(getRadiusId | jq '.results[0]._id, .results[0].networkSourceIp' | sed s/\"//g))
    radiusId=$(echo ${current[0]})
    currentIp=$(echo ${current[1]}) # if radiusId is undefined, define currentIp at the same time
else # call the predefined radiusId and define currentIP
    currentIp=($(getCurrentIp | jq '.networkSourceIp' | sed s/\"//g))
fi

# Compare current to new

if [[ ${currentIp} == ${newIp} ]]; then
    echo "IP has not changed, have a nice day. ¯\_(ツ)_/¯" && exit 0
fi

putRadius
