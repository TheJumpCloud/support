---
layout: post
title: Directory/System/Group Associations Audit (Python)
description: Gather the assigned Directories (GSuite/Office 365), Systems and Groups for your JumpCloud users
tags:
  - python
  - reports
  - automation
---

The purpose of this python script is to gather the assigned Directories (GSuite/Office 365), Systems and Groups for your JumpCloud users. The script will generate a CSV file containing the following fields that will allow the admin to sort/search based upon their needs:

```
'userId', 'username', 'groupMemberships', 'systemDisplayNames', 'systemHostnames', 'systemIds', 'directoryAssociation'
```

### Basic Usage

* Install the [JumpCloud Python SDK](https://github.com/TheJumpCloud/jcapi-python#installing-the-python-client)
* Python3 must be installed
* On line 15 of the script, please enter your organization's API key within the ""


### Additional Information

Run the script from your desired directory
The discovery.csv will be located in the directory the script was executed from

![script](https://user-images.githubusercontent.com/89030113/134062660-b9799190-9c8a-4484-b3ec-7b031ba125b9.gif)

![Screen Shot 2021-09-20 at 2 22 53 PM](https://user-images.githubusercontent.com/89030113/134062672-b80d54f8-663a-445c-8433-2551ce5cae56.png)

![Screen Shot 2021-09-20 at 2 23 33 PM](https://user-images.githubusercontent.com/89030113/134062682-969dd32a-0e0d-4193-9c6e-5060b0c7338a.png)

### Script

```python
from jcapiv2.configuration import Configuration
from jcapiv1.configuration import Configuration
import logging, sys
import jcapiv2
import jcapiv1
from jcapiv2.rest import ApiException
from jcapiv1.rest import ApiException as ApiExpectionV1
import csv
import itertools


# Change level to "logging.DEBUG" to output debug messages
logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

API_KEY = "<api_key>"

CONTENT_TYPE = "application/json"
ACCEPT = "application/json"

# Set up the configuration object with your API key for authorization
CONFIGURATION_V1 = jcapiv1.Configuration()
CONFIGURATION_V2 = jcapiv2.Configuration()
CONFIGURATION_V1.api_key['x-api-key'] = API_KEY
CONFIGURATION_V2.api_key['x-api-key'] = API_KEY

API_SYSTEM_INSTANCE = jcapiv1.SystemsApi(jcapiv1.ApiClient(CONFIGURATION_V1))
API_SYSTEMUSERS_INSTANCE = jcapiv1.SystemusersApi(jcapiv1.ApiClient(CONFIGURATION_V1))
API_USERS_INSTANCE = jcapiv2.UsersApi(jcapiv2.ApiClient(CONFIGURATION_V2))
API_USERGROUP_INSTANCE = jcapiv2.UserGroupsApi(jcapiv2.ApiClient(CONFIGURATION_V2))
API_GRAPH_INSTANCE = jcapiv2.GraphApi(jcapiv2.ApiClient(CONFIGURATION_V2))

def extract(lst):
    """Extract id and username from list 'lst'"""
    return [{"id": item.id, "username": item.username} for item in lst]

def get_jc_users():
    """Get all JC Users"""
    interval = 100
    limit = interval
    skip = 0
    get_users = True
    users = []
    try:
        while get_users:
            users_list = API_SYSTEMUSERS_INSTANCE.systemusers_list(CONTENT_TYPE, ACCEPT, limit=limit, skip=skip)
            users += users_list.results
            skip += interval
            if (len(users_list.results) != interval):
                get_users = False
        return users
    except ApiException as e:
        logging.debug("Exception when calling SystemusersApi->systemusers_list: %s\n" % e)

def get_jc_user_traverse_directory(user_id):
    try:
        response = API_GRAPH_INSTANCE.graph_user_traverse_directory(user_id, CONTENT_TYPE, ACCEPT)
        return response
    except ApiException as err:
        logging.debug("Exception when calling GraphApi->graph_user_traverse_directory: %s\n" % e)

def get_jc_user_member_of(user_id):
    try:
        response = API_GRAPH_INSTANCE.graph_user_member_of(user_id, CONTENT_TYPE, ACCEPT)
        return response
    except ApiException as e:
        logging.debug("Exception when calling GraphApi->graph_user_member_of: %s\n" % e)

def get_jc_user_group(group_id):
    try:
        response = API_USERGROUP_INSTANCE.groups_user_get(group_id, CONTENT_TYPE, ACCEPT)
        return response
    except ApiException as e:
        logging.debug("Exception when calling UserGroupsApi->groups_user_get: %s\n" % e)

def get_jc_user_system_associations(user_id):
    try:
        response = API_USERS_INSTANCE.graph_user_traverse_system(user_id, CONTENT_TYPE, ACCEPT, limit=100)
        return response
    except ApiException as e:
        logging.debug("Exception when calling UsersApi->graph_user_traverse_system: %s\n" % e)

def get_jc_system(system_id):
    try:
        response = API_SYSTEM_INSTANCE.systems_get(system_id, CONTENT_TYPE, ACCEPT)
        return response
    except ApiException as e:
        logging.debug("Exception when calling SystemsApi->systems_get: %s\n" % e)

if __name__ == "__main__":
    # Get List of all users
    users = get_jc_users()

    # Extract only the user's ID and username
    users = extract(users)

    # Set empty dict variable to hold final data
    finalUserInfo = {}

    # initiate an index for the above dict
    index = 0

    # total users
    totalUsers = len(users)

    # Loop through all users
    for user in users:
        logging.debug(f"Gathering user information [{index + 1} of {totalUsers}]...")

        # Set empty list variables to hold data
        userDirectoryAssociations = []
        userGroupMembership = []

        # Set the initial index to an empty dict
        finalUserInfo[index] = {}

        # Get the User's directory associations
        userDirectoryAssociation = get_jc_user_traverse_directory(user['id'])

        # Get the User's group memberships
        userGroupMembership = get_jc_user_member_of(user['id'])

        # Get the User's system associations
        userSystemAssociations = get_jc_user_system_associations(user['id'])

        # Start creating the user's dict
        finalUserInfo[index]['userId'] = user['id']
        finalUserInfo[index]['username'] = user['username']
        finalUserInfo[index]['groupMemberships'] = ""
        finalUserInfo[index]['systemIds'] = ""
        finalUserInfo[index]['systemHostnames'] = ""
        finalUserInfo[index]['systemDisplayNames'] = ""
        finalUserInfo[index]['directoryAssociation'] = userDirectoryAssociation
        
        # Loop through any system associations and return the system's ids, hostnames and displaynames
        for system in userSystemAssociations:
            systemInfo = get_jc_system(system.id)
            finalUserInfo[index]['systemIds'] += system.id + ";"
            finalUserInfo[index]['systemHostnames'] += systemInfo.hostname + ";"
            finalUserInfo[index]['systemDisplayNames'] += systemInfo.display_name + ";"

        # Loop through any memberships that the user has and return the Group's name instead of ID
        for group in userGroupMembership:
            groupInfo = get_jc_user_group(group.id)
            finalUserInfo[index]['groupMemberships'] += groupInfo.name + ";"
        
        logging.debug("Done...")

        # Increment the index
        index += 1

    logging.debug('Generating CSV file...')

    # Generate the CSV
    with open('discovery.csv', 'w') as csvfile:
        fields = ['no', 'userId', 'username', 'groupMemberships', 'systemDisplayNames', 'systemHostnames', 'systemIds', 'directoryAssociation']
        w = csv.DictWriter(csvfile, fields)
        w.writeheader()
        for key,val in finalUserInfo.items():
            row = {'no': key}
            row.update(val)
            w.writerow(row)

    logging.debug('CSV file generated...')
```