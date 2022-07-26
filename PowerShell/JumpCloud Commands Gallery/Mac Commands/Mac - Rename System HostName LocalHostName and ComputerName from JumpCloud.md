#### Name

Mac - Rename System HostName, LocalHostName and ComputerName from JumpCloud | v2.0 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash
################################################################################
# This script will update the system hostname, localHostname & computerName to
# match the value of this systems displayName in the JumpCloud console.
# An API Key with read access is required to run this script.
################################################################################

# Set Read API KEY - Required to read "DisplayName" from console.jumpcloud.com
API_KEY="YourReadOnlyAPIKey"

# ------- Do not modify below this line ------
# Functions
function validateVariable() {
    var=$1
    if [[ -z "$var" ]]; then
        echo "[error] Required variable was null, exiting..."
        exit 1
    fi
} >&2
function validateLocalHostname() {
    var=$1
    # Validate LocalHostName is Alphanumeric, contains '-' and no spaces
    # Attempt to remove the space characters if they exist
    if [[ "$var" =~ \ |\' ]]; then
        echo "[debug] whitespace characters found in LocalHostName, removing..."
        var="${var//[[:blank:]]/}"
    fi
    # Check for special characters & length of 63 characters
    # does not begin or end with '-'
    if [[ "$var" =~ ^[^-][a-zA-Z0-9-]{1,63}[^-]$ ]]; then
        echo "[debug] LocalHostname appears to be valid: $var"
    else
        echo "[debug] special characters found in LocalHostname, removing..."
        # Attempt to remove special characters if they exist
        var=$(echo "$var" | sed "s/[^[:alnum:]-]//g")
        # Finally validate updated variable
        if [[ "$var" =~ ^[^-][a-zA-Z0-9-]{1,63}[^-]$ ]]; then
            echo "[debug] LocalHostname appears to be valid: $var"
        else
            echo "[error] LocalHostName could not be set, exiting"
            exit 1
        fi
    fi
    validatedHostname="$var"
}
# Get System Key
function getSystemKey() {
    conf="$(cat /opt/jc/jcagent.conf)"
    regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'
    if [[ $conf =~ $regex ]]; then
        systemKey="${BASH_REMATCH[@]}"
    fi
    # echo "$(date "+%Y-%m-%dT%H:%M:%S"): systemKey = $systemKey "
    regex='[a-zA-Z0-9]{24}'
    if [[ $systemKey =~ $regex ]]; then
        systemID="${BASH_REMATCH[@]}"
    fi
    # echo "$(date "+%Y-%m-%dT%H:%M:%S"): systemID = $systemID "
    echo "$systemID"
}
systemID=$(getSystemKey)
search=$(
    curl -s -f -X GET https://console.jumpcloud.com/api/systems/${systemID} \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "x-api-key: ${API_KEY}"
)
# regex pattern to search displayNames. This pattern selects the text after "displayName":" and before ",
regex='("displayName":")([^"]*)(",)'
if [[ $search =~ $regex ]]; then
    match="${BASH_REMATCH[2]}"
fi

# Get old system name
oldName=$(scutil --get HostName)
# If hostname is not set for any reason, try again with localHostName
if [[ "$oldName" == "" ]];then
    echo "[debug] HostName was not set, trying to get the LocalHostName"
    oldName=$(scutil --get LocalHostName)
fi
# Validate oldName, Match (new Name), systemID
validateVariable "$oldName"
validateVariable "$systemID"
validateVariable "$match"
echo "[status] Attempting to set ComputerName, LocalHostName & Hostname to: $match"
# Validate localHostName is alphanumeric, 63 chars in length & no special chars
validateLocalHostname "$match"
# if validatedHostname variable exists, continue
validateVariable "$validatedHostname"
echo "[debug] script variables were validated"
# set the hostname, LocalHostName and computer name
# hostname:
scutil --set HostName "$match"
if [[ $? -eq 0 ]]; then
    echo "[status] HostName Set: $(scutil --get HostName)"
else
    echo "[error] Hostname was not set"
    exit 1
fi


if validateVariable "$validatedHostname"; then
    # Set validated variable
    scutil --set LocalHostName "$validatedHostname"
    if [[ $? -eq 0 ]]; then
        echo "[status] LocalHostName Set: $(scutil --get LocalHostName)"
    else
        echo "[error] LocalHostName was not set"
        exit 1
    fi
else
    echo "[error] Could not validate LocalHostName"
    exit 1
fi
scutil --set ComputerName "$match"
if [[ $? -eq 0 ]]; then
    echo "[status] ComputerName Set: $(scutil --get ComputerName)"
else
    echo "[error] ComputerName was not set"
    exit 1
fi

echo "[status] $oldName was renamed to $match"
exit 0
```

#### Description

This script uses a read only API key to gather info about the current system. Using Regex, the code filters out the displayName of a given system and sets the system HostName, LocalHostName and ComputerName to the name set in the JumpCloud console.

Please note, there are specific rules for the LocalHostName value. LocalHostNames must:

* Be a maximum 63 characters in length
* Contain no whitespace characters
* Contain only alphanumeric characters and hyphens '-'
* Hyphens must not exist at the beginning or end of the string ex. '-system-1-' is not allowed

This script will attempt to strip whitespace and special characters before setting the system's LocalHostName. HostNames and ComputerNames are not modified as their requirements differ from the LocalHostName.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Rename%20System%20HostName%20LocalHostName%20and%20ComputerName%20from%20JumpCloud.md"
```
