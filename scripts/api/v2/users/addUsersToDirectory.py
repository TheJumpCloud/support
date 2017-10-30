#!/usr/bin/env python
# The purpose of this script is to allow you to add a large number of users to a particular directory (G Suite, Office 365, and LDAP) based on their attribute value.
import json
import sys
import requests
from tqdm import tqdm #tqdm is not necessary for this script to run properly; however, it provides a nice means of viewing the progress of the script.


# This section captures the company's API Key, Attribute, and Directory
apikey=input('Please enter your API key:  ')
attribute=input('Please input attribute search value:  ')

Directory =input("""Please enter the number that corresponds with the directory that you would like to associate users to:
1 - G Suite
2 - Office 365
3 - LDAP
""")

# Performs a GET against the Directories endpoint to determine the IDs of the Directory noted in the next section
headers = {'Content-Type': 'application/json', 'Accept': 'application/json','x-api-key':''+apikey+''}
url = 'https://console.jumpcloud.com/api/v2/directories'
response = requests.get(url, headers = headers)
json_data =json.loads(response.text)

id=''

# This section runs through to set both the Directory value to append to the add_user_url as well as the id for that URL
if Directory == '1':
    Directory = 'gsuites'
    for dir in (json_data):
        if (dir['type']) == 'g_suite':
            id = dir['id']
            print(id)
            break
elif Directory == '2':
        Directory= 'office365s'
        for dir in (json_data):
            if (dir['type']) == 'office_365':
                id = dir['id']
                print(id)
                break
elif Directory == '3':
    Directory= 'ldapservers'
    for dir in (json_data):
        if (dir['type']) == 'ldap_server':
            id = dir['id']
            print(id)
            break
else:
    print('invalid entry')

# Validates the API Key and captures the total count of users to append in the next section
try:
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json','x-api-key':''+apikey+''}
    url = 'https://console.jumpcloud.com/api/systemusers?limit=1&filter=attributes.value:eq:'+attribute+''
    response = requests.get(url, headers = headers)
    json_data=json.loads(response.text)
    total_count=(json_data['totalCount'])
except json.JSONDecodeError as jde:
    print("Failed to gather users, please ensure attributes value and API Key are valid")
    sys.exit()

limit= 100
skip= 0
user_ids=[]

# This while loop runs through and builds an array of all users ids that apply for the filter being applied for later use
while skip < total_count:
    try:
        limiturl = 'https://console.jumpcloud.com/api/systemusers?sort=type,name&skip='+str(skip)+'&limit='+str(limit)+'&filter=attributes.value:eq:'+attribute+''
        response = requests.get(limiturl, headers = headers)
        json_data=json.loads(response.text)
        for user in (json_data['results']):
            user_ids.append(user['_id'])
        skip = skip + limit #adds the limit value to skip while length < total_count
    except:
        print('Failed to gather users')

add_user_url='https://console.jumpcloud.com/api/v2/'+Directory+'/'+id+'/associations'

# This runs through and adds each user captured to the Directory specified earlier.
try:
    for user_id in tqdm((user_ids)):
        payload={'op': 'add', 'type': 'user', 'id': ''+user_id+''}
        response = requests.post(add_user_url, headers = headers, data=json.dumps(payload))
except:
    print(response.text)
