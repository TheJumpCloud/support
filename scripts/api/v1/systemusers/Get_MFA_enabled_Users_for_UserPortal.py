#!/usr/bin/env python

# Use this script to return all users in your Organization that have MFA enabled for their User Portal.

import json
import sys
import requests

apikey=input('Please enter your API key:  ')

headers = {'Content-Type': 'application/json', 'Accept': 'application/json','x-api-key':''+apikey+''}
url = 'https://console.jumpcloud.com/api/search/systemusers'
payload={'filter': [{'enable_user_portal_multifactor' : 'true'}], 'fields' : 'name username email'}
response = requests.post(url, headers = headers, data=json.dumps(payload))
json_data =json.loads(response.text)
print(json_data)
