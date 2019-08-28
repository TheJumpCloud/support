## General - DISPLAY NAME

jc_account_association

## Script - SCRIPT CONTENTS

```bash
## Populate below variable before running command
JCAPIKey=''

## ------ MODIFY BELOW THIS LINE AT YOUR OWN RISK --------------
## Get the logged in user's username
username="$(/usr/bin/stat -f%Su /dev/console)"
echo "Currently logged in user is "$username

## Get JumpCloud SystemID
conf="$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'

if [[ $conf =~ $regex ]]; then
    systemKey="${BASH_REMATCH[@]}"
fi

regex='[a-zA-Z0-9]{24}'
if [[ $systemKey =~ $regex ]]; then
    systemID="${BASH_REMATCH[@]}"
    echo "JumpCloud systemID found SystemID: "$systemID
else
    echo "No systemID found"
    exit 1
fi

## Get JumpCloud UserID
userSearch=$(
    curl -s \
        -X 'POST' \
        -d '{"filter":[{"username":"'${username}'"}],"fields" : "username activated email"}' \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H 'x-api-key: '${JCAPIKey}'' \
        "https://console.jumpcloud.com/api/search/systemusers"
)

regex='[a-zA-Z0-9]{24}'
if [[ $userSearch =~ $regex ]]; then
    userID="${BASH_REMATCH[@]}"
    echo "JumpCloud userID for user "$username "found userID: "$userID
else
    echo "No JumpCloud user with username" "$username" "found."
    echo "Create a JumpCloud user with username:" "$username" "and try again."
    exit 1
fi

## Check users current permissions

if groups ${username} | grep -q -w admin; then
    echo "User is an an admin. User will be bound with admin permissions."
    admin='true'
else
    echo "User is not an admin. User will be bound with standard permissions"
    admin='false'
fi

## Checks if user is activated

regex='"activated":true'
if [[ $userSearch =~ $regex ]]; then
    activated="true"
    echo "JumpCloud account in active state for user: $username"

else
    activated="false"
    echo "JumpCloud account in pending state for user: $username"

fi

if [[ $activated == "true" ]]; then

    ## Capture current logFile
    logLinesRaw=$(wc -l /var/log/jcagent.log)
    logLines=$(echo $logLinesRaw | head -n1 | awk '{print $1;}')

    ## Bind JumpCloud user to JumpCloud system
    userBind=$(
        curl -s \
            -X 'POST' \
            -H 'Accept: application/json' \
            -H 'Content-Type: application/json' \
            -H 'x-api-key: '${JCAPIKey}'' \
            -d '{ "attributes": { "sudo": { "enabled": '${admin}',"withoutPassword": false}}   , "op": "add", "type": "user","id": "'${userID}'"}' \
            "https://console.jumpcloud.com/api/v2/systems/${systemID}/associations"
    )

    ## Checks and ensures user bound to system
    userBindCheck=$(
        curl -s \
            -X 'GET' \
            -H 'Accept: application/json' \
            -H 'Content-Type: application/json' \
            -H 'x-api-key: '${JCAPIKey}'' \
            "https://console.jumpcloud.com/api/v2/systems/${systemID}/associations?targets=user"
    )

    regex=''${userID}''

    if [[ $userBindCheck =~ $regex ]]; then
        userID="${BASH_REMATCH[@]}"
        echo "JumpCloud user "$username "bound to systemID: "$systemID
    else
        echo "error JumpCloud user not bound to system"
        exit 1
    fi

    ## Waits to see local account takeover

    updateLog=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)

    accountTakeOverCheck=$(echo ${updateLog} | grep "User updates complete")

    logoutTimeoutCounter='0'

    while [[ -z "${accountTakeOverCheck}" ]]; do
        Sleep 6
        updateLog=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)
        accountTakeOverCheck=$(echo ${updateLog} | grep "User updates complete")
        logoutTimeoutCounter=$((${logoutTimeoutCounter} + 1))
        if [[ ${logoutTimeoutCounter} -eq 10 ]]; then
            echo "Error during account takeover"
            echo "JCAgent.log: ${updateLog}"
            exit 1
        fi
    done
    echo "Account takeover occurred at" $(date +"%Y %m %d %H:%M")

else

    echo "Account not activated. Have user set a JumpCloud password to activate account and try again."

    exit 1

fi

exit 0
```


## Options

N/A

## Limitations

N/A
