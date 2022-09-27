#### Name

Linux - Rename System HostName, LocalHostName and ComputerName from JumpCloud | v2.0 JCCG

#### commandType

linux

#### Command

```
#!/bin/bash
################################################################################
# This script will update the system hostname, localHostname & computerName to
# match the value of this systems displayName in the JumpCloud console.
# An API Key with read access is required to run this script.
################################################################################

# Set Read API KEY - Required to read "DisplayName" from console.jumpcloud.com
API_KEY="yourReadWriteAPIKey"

# ------- Do not modify below this line ------

# Exit immediately on error
set -e
# Functions
function validateVariable() {
    var=$1
    if [[ -z "$var" ]]; then
        echo "Required variable was null, exiting..."
        exit 1
    else
        echo "Variable is set to '$var'"
    fi
} >&2
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
    curl -f -X GET https://console.jumpcloud.com/api/systems/${systemID} \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "x-api-key: ${API_KEY}"
)
# regex pattern to search displayNames. This pattern selects the text after "displayName":" and before ",
regex='("displayName":")([^"]*)(",)'
if [[ $search =~ $regex ]]; then
    new_hostname="${BASH_REMATCH[2]}"
fi

old_hostname=$( cat /etc/hostname )
hostnamectl set-hostname $new_hostname
sed -i -e "s/$old_hostname/$new_hostname/g" /etc/hosts

echo "$old_hostname was renamed to $new_hostname"

exit 0
```

#### Description

This script uses a read only API key to gather info about the current system. Using Regex, the code filters out the displayName of a given system and sets the system HostName, LocalHostName and ComputerName to the name set in the JumpCloud console.

Please note, there are specific rules for the LocalHostName value. LocalHostNames must:

- Be a maximum 63 characters in length
- Contain no whitespace characters
- Contain only alphanumeric characters and hyphens '-'
- Hyphens must not exist at the beginning or end of the string ex. '-system-1-' is not allowed

This script will attempt to strip whitespace and special characters before setting the system's LocalHostName. HostNames and ComputerNames are not modified as their requirements differ from the LocalHostName.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20Rename%20System%20HostName%2C%20LocalHostName%20and%20ComputerName%20from%20JumpCloud.md"
```
