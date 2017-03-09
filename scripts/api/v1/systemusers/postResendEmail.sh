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

curl \
  -X 'POST' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  -d '{"isSelectAll":false,"models":[{"_id":"SYSTEM_USER_ID"}]}' \
  "https://console.jumpcloud.com/api/systemusers/reactivate"

}

readApiKey
