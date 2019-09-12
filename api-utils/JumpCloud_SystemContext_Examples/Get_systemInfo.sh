#!/bin/bash

##
## This example demonstrates how to make a System Context API request
## This example fetches the system record by doing a GET on the /api/systems/${systemID} endpoint
##

# Parse the systemKey from the conf file.
conf="$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'
JCUrlBasePath='https://console.jumpcloud.com'

if [[ $conf =~ $regex ]]; then
    systemKey="${BASH_REMATCH[@]}"
fi

regex='[a-zA-Z0-9]{24}'
if [[ $systemKey =~ $regex ]]; then
    systemID="${BASH_REMATCH[@]}"
fi

# Get the current time.
now=$(date -u "+%a, %d %h %Y %H:%M:%S GMT")

# create the string to sign from the request-line and the date
signstr="GET /api/systems/${systemID} HTTP/1.1\ndate: ${now}"

# create the signature

signatureRaw=$(printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key)

signature=$(printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n')

curl \
    -X 'GET' \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -H "Date: ${now}" \
    -H "Authorization: Signature keyId=\"system/${systemID}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
    "$JCUrlBasePath/api/systems/${systemID}" | python -mjson.tool
