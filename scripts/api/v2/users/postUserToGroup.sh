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

# valid values for "op" are add,remove
# requires valid values for "systemuser_id" and "group_id"

curl \
  -X 'POST' \
  -d '{ "op" : "remove", "type" : "user", "id": "systemuser_id" }' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  "https://console.jumpcloud.com/api/v2/usergroups/group_id/members"
}

readApiKey
