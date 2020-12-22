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
#      REQUIRED: curl, jq, JumpCloud API Key
#      USAGE: This can be set to run as a cron, e.g., every hour at minute 0:
#
#      $ crontab -e
#      0 * * * * /opt/dhcpRadiusUpdate.sh > /var/log/radupdate.log 2>&1
#
###############################################################################

# Define Vars

apiKey=
radiusId=
newIp=$(curl -q http://ipecho.net/plain)

# If newIp can't be defined, bail

if [ $? -ne 0 ]; then
  echo "Unable to determine newIp, exiting..." && exit 1
fi

getCurrentIp() {

curl \
  -X 'GET' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  "https://console.jumpcloud.com/api/radiusservers/${radiusId}"

}

getRadiusId() {

curl \
  -X 'GET' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  "https://console.jumpcloud.com/api/radiusservers"

}

putRadius() {

curl \
  -X 'PUT' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  -d '{"networkSourceIp":"'"${newIp}"'", "name": "<YOUR RADIUS NAME>", "sharedSecret": "<YOUR SHARED SECRET"}' \
  "https://console.jumpcloud.com/api/radiusservers/${radiusId}"

}

if [ -z ${apiKey} ]; then
  echo "apiKey must be defined, exiting..." && exit 1
fi

if [ -z ${radiusId} ]; then # Use the radiusId and currentIp of the first record returned
  current=($(getRadiusId | jq '.results[0]._id, .results[0].networkSourceIp' | sed s/\"//g))
  radiusId=$(echo ${current[0]})
  currentIp=$(echo ${current[1]})
else # call the predefined radiusId and define currentIP
  currentIp=($(getCurrentIp | jq '.networkSourceIp' | sed s/\"//g))
fi

# Compare currentIp to newIp, bail if nothing's chainged

if [[ ${currentIp} == ${newIp} ]]; then
  echo "IP has not changed, have a nice day. ¯\_(ツ)_/¯" && exit 0
fi

putRadius
