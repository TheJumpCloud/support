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
  -X 'PUT' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  -d '{"phoneNumbers": [{"number": "+1 555-555-7777", "type": "home"}, {"number": "+1 555-555-6666", "type": "mobile"}, {"number": "+1 555-555-8888", "type": "work"}, {"number": "+1 555-555-9999", "type": "work_mobile"}, {"number": "+1 555-555-0000", "type": "work_fax"}], "addresses": [{"locality": "Boulder", "poBox": "26", "postalCode": "80304", "country": "USA", "type": "home", "region": "CO", "streetAddress": "123 Main"}, {"locality": "Boulder", "poBox": "3333", "postalCode": "80302", "country": "USA", "type": "work", "region": "CO", "streetAddress": "2040 14th St Ste. 200"}]}' \
  "https://console.jumpcloud.com/api/systemusers/:id"

}

readApiKey
