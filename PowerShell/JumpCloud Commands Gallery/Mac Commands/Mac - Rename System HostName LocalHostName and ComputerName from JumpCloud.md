#### Name

Mac - Rename System HostName, LocalHostName and ComputerName from JumpCloud | v1.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash
conf="$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'

if [[ $conf =~ $regex ]]; then
    systemKey="${BASH_REMATCH[@]}"
fi

echo "$(date "+%Y-%m-%dT%H:%M:%S"): systemKey = $systemKey "

regex='[a-zA-Z0-9]{24}'
if [[ $systemKey =~ $regex ]]; then
    systemID="${BASH_REMATCH[@]}"
fi

echo "$(date "+%Y-%m-%dT%H:%M:%S"): systemID = $systemID "

now=$(date -u "+%a, %d %h %Y %H:%M:%S GMT")

# create the string to sign from the request-line and the date
signstr="GET /api/systems/${systemID} HTTP/1.1\ndate: ${now}"

# create the signature
signature=$(printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n')

search=$(
    curl \
        -X 'GET' "https://console.jumpcloud.com/api/systems/${systemID}" \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -H "Date: ${now}" \
        -H "Authorization: Signature keyId=\"system/${systemID}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
)

# regex pattern to search displayNames. This pattern selects the text after "displayName":" and before ",
regex='("displayName":")([^"]*)(",)'
if [[ $search =~ $regex ]]; then
    match="${BASH_REMATCH[2]}"
fi

echo $match

# set the hostname, localhostname and computer name
scutil --set HostName "$match"
scutil --set LocalHostName "$match"
scutil --set ComputerName "$match"

# print out the names
echo "HostName:" && scutil --get HostName
echo "LocalHostName:" && scutil --get LocalHostName
echo "ComputerName:" && scutil --get ComputerName
```

#### Description

This script uses the system context API to gather info about the current system. Using Regex, the code filters out the displayName of a given system and sets the system HostName, LocalHostName and ComputerName to the name set in the JumpCloud console.

The current regex pattern attempts to select the text between "displayName":" and ", of the returned results if a displayName contains quotes or commas, this script may not run as intended.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JvFq6'
```
