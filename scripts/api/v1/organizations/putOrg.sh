#!/bin/bash

if [[ -z "${1}" ]]; then
  echo "Usage: ./putOrg.sh <Organization ID>"
  exit 1
fi

org="${1}"

# Require API Key to run

readApiKey() {
echo -n "Enter your API Key: "
        read apiKey;
if [ -z "$apiKey" ]
        then
                echo "Input cannot be null"; readApiKey;
        else apiCall;
fi
}

# API call example
apiCall() { 

curl  \
  -X 'PUT' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  -d '{"settings":{ "disableLdap": false }} ' \
  "https://console.jumpcloud.com/api/organizations/${org}"

}

readApiKey
