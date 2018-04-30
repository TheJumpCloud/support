#!/usr/bin/env python

# Use this script to return all systems in your Organization that have MFA enabled.
# This script works in Python3 only.

import json
import sys
import requests

apikey=input('Please enter your API key:  ')

headers = {'Content-Type': 'application/json', 'Accept': 'application/json','x-api-key':''+apikey+''}
url = 'https://console.jumpcloud.com/api/search/systems'
payload={'filter': [{'allowMultiFactorAuthentication' : 'true'}], 'fields' : 'os hostname displayname'}
response = requests.post(url, headers = headers, data=json.dumps(payload))
json_data =json.loads(response.text)
print(json_data)
