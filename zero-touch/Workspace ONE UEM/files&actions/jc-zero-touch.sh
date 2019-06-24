# Create as action Type "Run" and pass in two arguments "Your_JumpCloud_Connect_Key" "Your_JumpCloud_API_Key"
# Example . /tmp/jc-zero-touch.sh "Your_JumpCloud_Connect_Key" "Your_JumpCloud_API_Key"

# Log file creation
touch /tmp/jc-zero-touch_log.txt

# Gets the logged in user
loggedInUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

echo "$(date "+%Y-%m-%dT%H:%M:%S") Logged in user: $loggedInUser" >>/tmp/jc-zero-touch_log.txt

# Installs JumpCloud Agent Install
curl -o /tmp/jumpcloud-agent.pkg "https://s3.amazonaws.com/jumpcloud-windows-agent/production/jumpcloud-agent.pkg"
mkdir -p /opt/jc
cat <<-EOF >/opt/jc/agentBootstrap.json
{
"publicKickstartUrl": "https://kickstart.jumpcloud.com:443",
"privateKickstartUrl": "https://private-kickstart.jumpcloud.com:443",
"connectKey": "$1"
}
EOF
installer -pkg /tmp/jumpcloud-agent.pkg -target /

Sleep 8

# Get the logged in user uid
uid=$(id -u "$loggedInUser")
echo "$(date "+%Y-%m-%dT%H:%M:%S") Logged in user uid: $uid" >>/tmp/jc-zero-touch_log.txt
# Prompts user to tell them the JumpCloud agent is intalled
agentInstalledPrompt=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "JumpCloud agent installed!" with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)

echo "$(date "+%Y-%m-%dT%H:%M:%S") Agent installed prompt input: $agentInstalledPrompt" >>/tmp/jc-zero-touch_log.txt

Sleep 8

# logged in user auto-association to JumpCloud account

# Prompts user to tell them about association
autoAssociationPrompt=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "Associating account with system in JumpCloud. This can take up to 60 seconds." with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)

echo "$(date "+%Y-%m-%dT%H:%M:%S") Account association prompt input: $autoAssociationPrompt" >>/tmp/jc-zero-touch_log.txt

## Get JumpCloud SystemID
conf="$(cat /opt/jc/jcagent.conf)"
regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'

if [[ $conf =~ $regex ]]; then
    systemKey="${BASH_REMATCH[@]}"
fi

regex='[a-zA-Z0-9]{24}'
if [[ $systemKey =~ $regex ]]; then
    systemID="${BASH_REMATCH[@]}"
    echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud systemID found SystemID: "$systemID >>/tmp/jc-zero-touch_log.txt
else
    echo "$(date "+%Y-%m-%dT%H:%M:%S") No systemID found" >>/tmp/jc-zero-touch_log.txt
    exit 1
fi

## Get JumpCloud UserID
userSearch=$(
    curl -s \
        -X 'POST' \
        -d '{"filter":[{"username":"'${loggedInUser}'"}],"fields" : "username activated email"}' \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H 'x-api-key: '${2}'' \
        "https://console.jumpcloud.com/api/search/systemusers"
)

regex='[a-zA-Z0-9]{24}'
if [[ $userSearch =~ $regex ]]; then
    userID="${BASH_REMATCH[@]}"
    echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud userID for user "$loggedInUser "found userID: "$userID >>/tmp/jc-zero-touch_log.txt
else
    echo "$(date "+%Y-%m-%dT%H:%M:%S") No JumpCloud user with username" "$loggedInUser" "found." >>/tmp/jc-zero-touch_log.txt
    echo "$(date "+%Y-%m-%dT%H:%M:%S") Create a JumpCloud user with username:" "$loggedInUser" "and try again." >>/tmp/jc-zero-touch_log.txt
    exit 1
fi

## Check users current system account permissions

if groups ${loggedInUser} | grep -q -w admin; then
    echo "$(date "+%Y-%m-%dT%H:%M:%S") User is an an admin. User will be bound with admin permissions." >>/tmp/jc-zero-touch_log.txt
    admin='true'
else
    echo "$(date "+%Y-%m-%dT%H:%M:%S") User is not an admin. User will be bound with standard permissions" >>/tmp/jc-zero-touch_log.txt
    admin='false'
fi

## Checks if user is activated

regex='"activated":true'
if [[ $userSearch =~ $regex ]]; then
    activated="true"
    echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud account in active state for user: $loggedInUser" >>/tmp/jc-zero-touch_log.txt

else
    activated="false"
    echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud account in pending state for user: $loggedInUser" >>/tmp/jc-zero-touch_log.txt

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
            -H 'x-api-key: '${2}'' \
            -d '{ "attributes": { "sudo": { "enabled": '${admin}',"withoutPassword": false}}   , "op": "add", "type": "user","id": "'${userID}'"}' \
            "https://console.jumpcloud.com/api/v2/systems/${systemID}/associations"
    )

    #Check and ensure user bound to system
    userBindCheck=$(
        curl -s \
            -X 'GET' \
            -H 'Accept: application/json' \
            -H 'Content-Type: application/json' \
            -H 'x-api-key: '${2}'' \
            "https://console.jumpcloud.com/api/v2/systems/${systemID}/associations?targets=user"
    )

    regex=''${userID}''

    if [[ $userBindCheck =~ $regex ]]; then
        userID="${BASH_REMATCH[@]}"
        echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud user "$loggedInUser "bound to systemID: "$systemID >>/tmp/jc-zero-touch_log.txt
    else
        echo "$(date "+%Y-%m-%dT%H:%M:%S") error JumpCloud user not bound to system" >>/tmp/jc-zero-touch_log.txt
        exit 1
    fi

    #Wait to see local account takeover by the JumpCloud agent

    updateLog=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)

    Sleep 6

    accountTakeOverCheck=$(echo ${updateLog} | grep "User updates complete")

    logoutTimeoutCounter='0'

    while [[ -z "${accountTakeOverCheck}" ]]; do
        Sleep 6
        updateLog=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)
        accountTakeOverCheck=$(echo ${updateLog} | grep "User updates complete")
        logoutTimeoutCounter=$((${logoutTimeoutCounter} + 1))
        if [[ ${logoutTimeoutCounter} -eq 10 ]]; then
            echo "$(date "+%Y-%m-%dT%H:%M:%S") Error during JumpCloud agent local account takeover" >>/tmp/jc-zero-touch_log.txt
            echo "$(date "+%Y-%m-%dT%H:%M:%S") JCAgent.log: ${updateLog}" >>/tmp/jc-zero-touch_log.txt
            exit 1
        fi
    done

    echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud agent local account takeover complete" >>/tmp/jc-zero-touch_log.txt
    autoAssociationSuccessPrompt=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "Association complete!" with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)
    echo "$(date "+%Y-%m-%dT%H:%M:%S") Account association success prompt input: $autoAssociationSuccessPrompt" >>/tmp/jc-zero-touch_log.txt

else

    echo "$(date "+%Y-%m-%dT%H:%M:%S") Account not activated. Have user set a JumpCloud password to activate account and try again." >>/tmp/jc-zero-touch_log.txt

    exit 1

fi

### Logout prompts to inform user of log out process

logoutInfo1=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "Preparing to log out. Log back in to complete onboarding." with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)

if [ "$logoutInfo1" = "button returned:OK, gave up:false" ]; then
    logoutInfo2=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "During login you will be asked to enter a PREVIOUS PASSWORD and a PASSWORD." with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)
else

    logoutInfo2=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "During login you will be asked to enter a PREVIOUS PASSWORD and a PASSWORD." with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)

fi

echo "$(date "+%Y-%m-%dT%H:%M:%S") Logout prompt 1 input: $logoutInfo1" >>/tmp/jc-zero-touch_log.txt

if [ "$logoutInfo2" = "button returned:OK, gave up:false" ]; then
    logoutInfo3=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "Enter your current password into both the PREVIOUS PASSWORD and PASSWORD fields." with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)
else

    logoutInfo3=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "Enter your current password into both the PREVIOUS PASSWORD and PASSWORD fields." with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)

fi

echo "$(date "+%Y-%m-%dT%H:%M:%S") Logout prompt 2 input: $logoutInfo2" >>/tmp/jc-zero-touch_log.txt

if [ "$logoutInfo3" = "button returned:OK, gave up:false" ]; then
    logoutInfo4=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "Logging out" with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)
else

    logoutInfo4=$(launchctl asuser "$uid" /usr/bin/osascript -e 'display dialog "Logging out" with title "JumpCloud Onboarding" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 8' 2>/dev/null)

fi

echo "$(date "+%Y-%m-%dT%H:%M:%S") Logout prompt 3 input: $logoutInfo3" >>/tmp/jc-zero-touch_log.txt

if [ "$logoutInfo4" = "button returned:OK, gave up:false" ]; then
    continue
else
    Sleep 8
fi

echo "$(date "+%Y-%m-%dT%H:%M:%S") Logout prompt 4 input: $logoutInfo4" >>/tmp/jc-zero-touch_log.txt

### Account Logout
user=$(ls -la /dev/console | cut -d " " -f 4)

echo "$(date "+%Y-%m-%dT%H:%M:%S") Logging out user $user" >>/tmp/jc-zero-touch_log.txt

# Gets logged in user login window
loginCheck=$(ps -Ajc | grep ${user} | grep loginwindow | awk '{print $2}')
timeoutCounter='0'
while [[ "${loginCheck}" ]]; do
    # Logs out user if they are logged in
    sudo launchctl bootout gui/$(id -u ${user})
    Sleep 8
    loginCheck=$(ps -Ajc | grep ${user} | grep loginwindow | awk '{print $2}')
    timeoutCounter=$((${timeoutCounter} + 1))
    if [[ ${timeoutCounter} -eq 4 ]]; then
        echo "$(date "+%Y-%m-%dT%H:%M:%S") Timeout unable to log out ${user} account." >>/tmp/jc-zero-touch_log.txt
        exit 1
    fi
done
echo "$(date "+%Y-%m-%dT%H:%M:%S") Log out complete" >>/tmp/jc-zero-touch_log.txt

exit 0
