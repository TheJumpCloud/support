#!/bin/bash


##
## This API call fetches the system record.
##

# Parse the systemKey from the conf file.
# The conf file is JSON and can be parsed using JSON.parse() in a supported language.
conf="`cat /opt/jc/jcagent.conf`"
regex='\"systemKey\":\"([a-zA-Z0-9_]+)\"'

if [[ ${conf} =~ $regex ]] ; then
  systemKey="${BASH_REMATCH[1]}"
fi

# Get the current time.
now=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`;

# create the string to sign from the request-line and the date
signstr="GET /api/systems/${systemKey} HTTP/1.1\ndate: ${now}"

# create the signature
signature=`printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n'` ;

# make the api call passing the signature in the authorization header
curl -iq \
  -H "Accept: application/json" \
  -H "Date: ${now}" \
  -H "Authorization: Signature keyId=\"system/${systemKey}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
  --url https://console.jumpcloud.com/api/systems/${systemKey}