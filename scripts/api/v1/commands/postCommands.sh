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

#For Windows commands, commandType must be set to "windows" and the user to null, else linux commands require a valid user specified
curl \
  -X 'POST' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  -d '{ "command":"ANEWCOMMAND", "commandType" : "windows", "user" : null}  ' \
  "https://console.jumpcloud.com/api/commands"

}

readApiKey
