#!/usr/bin/env python
#The purpose of this script is to delete all users that have an attribute value that matches the value specified, then each user that has a value that matches is subsequently deleted.
import json
import requests
import sys
from tqdm import tqdm #tqdm is not necessary for this script to run properly; however, it provides a nice means of viewing the progress of the script.


apikey=input('Please enter your API key:  ')
attribute=input('Please input attribute search value:  ')

#This command goes and grabs the total count of ids that must eventually be run through
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

# This loops through and deletes each user based on the id built earlier. Further, this may be modified to run to make any change to users that meet the search attribute (e.g. adding users to a specific Group, Directory, etc.)
try:
    base_url = 'https://console.jumpcloud.com/api/systemusers/'
    for id in tqdm((user_ids)):
        response = requests.delete(base_url+id, headers = headers)
except:
    print('Failed to delete users')
