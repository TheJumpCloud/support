#!/bin/bash
# Notice this is for bash, change as needed for your shell
# This script requires the API key to function

apiKey=

# The dataFile should contain rows of two strings separated by a colon (:). the first string should be a systemuser id, second a system id
# E.g.: 
# 581a6ffba0e711603d7c2914:591a6feba0e612603d7c2914
# dataFile also needs to reside in the same path as this script, or specify the path.

dataFile=

# Form the API call to directly bind a systemuser to a system 
call() {

curl \
  -d '{ "add": ["'"${user}"'"], "remove" : [] }' \
  -X PUT \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apiKey}" \
  "https://console.jumpcloud.com/api/systems/${system}/systemusers"

}

# Parse the dataFile for the correct object id's and make the API call

bind() {

for rec in `cat "${dataFile}"`; do
        IFS=':' read -a arr <<< "$rec"
        user="${arr[0]}"
        system="${arr[1]}"
        call;
done
} 

bind
