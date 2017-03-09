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
  -X 'GET' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  "https://console.jumpcloud.com/api/tags"

}

readApiKey
