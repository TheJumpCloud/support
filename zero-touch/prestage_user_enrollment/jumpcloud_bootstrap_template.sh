#!/bin/bash

#*******************************************************************************
#
#       Version 1.2 | See the CHANGELOG.md for version information
#
#       See the ReadMe file for detailed configuration steps.
#
#       The "jumpcloud_bootstrap_template.sh" is a template file. Populate the
#       variables in this template file and select and populate the input fields
#       with a user_configuration_modules. The modules provide optionality for the
#       zero-touch user account activation workflow.
#
#       Find a detailed description of each module within the ReadMe file.
#
#       Pick and choose from the available modules to create a zero-touch
#       bootstrap workflow that fits your orgs specific zero-touch requirements.
#
#       USAGE:
#
#       Search this template file for the text INSERT-CONFIGURATION
#       to find the input locations for configuration input sections.
#       Find the script blocks to insert here within your desired module in
#       the "user_configuration_modules" folder. Each module has all the required
#       configuration script blocks that must be inserted into the master
#       "jumpcloud_bootstrap_template.sh" file. Copy and paste the script
#       blocks from your chosen module into this master file.
#
#       After populating "jumpcloud_bootstrap_template.sh" with script blocks
#       from a module use munkipkg to create a signed PKG file. Deploy this PKG
#       file using a MDM and the "install_applications" command to implement your
#       zero-touch bootstrap workflow.
#
#       Questions or feedback on the JumpCloud bootstrap workflow? Please
#       contact support@jumpcloud.com
#
#       Authors: Scott Reed | scott.reed@jumpcloud.com
#               Joe Workman | joe.workman@jumpcloud.com
#
#*******************************************************************************

################################################################################
# General Settings - INSERT-CONFIGURATION - POPULATE THE BELOW VARIABLES       #
################################################################################

### Bind user as admin or standard user ###
# Admin user: admin='true'
# Standard user: admin='false'
admin='false'

### Minimum password length ###
minlength=8

### JumpCloud Connect Key ###
YOUR_CONNECT_KEY=''

### Encrypted API Key ###
## Use below SCRIPT FUNCTION: EncryptKey to encrypt key
ENCRYPTED_KEY=''

### Username of the JumpCloud user whose UID is used for decryption ###
DECRYPT_USER=''

### JumpCloud System Group ID For DEP Enrollment ###
DEP_ENROLLMENT_GROUP_ID=''

### JumpCloud System Group ID For DEP POST Enrollment ###
DEP_POST_ENROLLMENT_GROUP_ID=''

### DEPNotify Welcome Window Title ###
WELCOME_TITLE=""

### DEPNotify Welcome Window Text use //n for line breaks ###
WELCOME_TEXT=''

### Boolean to delete the enrollment user set through MDM ###
DELETE_ENROLLMENT_USERS=true

### Username of the enrollment user account configured in the MDM.
### This account will be deleted if the above boolean is set to true.
ENROLLMENT_USER=""

### NTP server, set to time.apple.com by default, Ensure time is correct ### 
NTP_SERVER="time.apple.com"

### Daemon Variable
daemon="com.jumpcloud.prestage.plist"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# END General Settings                                                         ~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#-------------------------------------------------------------------------------
# Script Functions                                                             -
#-------------------------------------------------------------------------------

# Used to create $ENCRYPTED_KEY
function EncryptKey() {
    # Usage: EncryptKey "API_KEY" "DECRYPT_USER_UID" "ORG_ID"
    local ENCRYPTION_KEY=${2}${3}
    local ENCRYPTED_KEY=$(echo "${1}" | openssl enc -e -base64 -A -aes-128-ctr -nopad -nosalt -k ${ENCRYPTION_KEY})
    echo "Encrypted key: ${ENCRYPTED_KEY}"
}

# Used to decrypt $ENCRYPTED_KEY
function DecryptKey() {
    # Usage: DecryptKey "ENCRYPTED_KEY" "DECRYPT_USER_UID" "ORG_ID"
    echo "${1}" | openssl enc -d -base64 -aes-128-ctr -nopad -A -nosalt -k "${2}${3}"
}

# Resets DEPNotify
function DEPNotifyReset() {
    ACTIVE_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
    rm /var/tmp/depnotify* >/dev/null 2>&1
    rm /var/tmp/com.depnotify.* >/dev/null 2>&1
    rm /Users/"$ACTIVE_USER"/Library/Preferences/menu.nomad.DEPNotify* >/dev/null 2>&1
    killall cfprefsd
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# END Script Functions                                                         ~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#-------------------------------------------------------------------------------
# Script Variables                                                             -
#-------------------------------------------------------------------------------

WINDOW_TITLE='Welcome'
DEP_N_DEBUG='/var/tmp/debug_depnotify.log'
DEP_N_APP='/Applications/Utilities/DEPNotify.app'
DEP_N_LOG='/var/tmp/depnotify.log'
DEP_N_REGISTER_DONE="/var/tmp/com.depnotify.registration.done"
DEP_N_DONE="/var/tmp/com.depnotify.provisioning.done"
# added by joe
DEP_N_GATE_INSTALLJC="/var/tmp/com.jumpcloud.gate.installjc"
DEP_N_GATE_SYSADD="/var/tmp/com.jumpcloud.gate.sysadd"
DEP_N_GATE_UI="/var/tmp/com.jumpcloud.gate.ui"
DEP_N_GATE_DONE="/var/tmp/com.jumpcloud.gate.done"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# END Script Variables                                                        ~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#*******************************************************************************
# Pre login bootstrap workflow                                                 *
#*******************************************************************************
# First condition - is JC installed
if [[ ! -f $DEP_N_GATE_INSTALLJC ]]; then

    # Install DEPNotify
    curl --silent --output /tmp/DEPNotify-1.1.4.pkg "https://s3.amazonaws.com/nomadbetas/DEPNotify-1.1.4.pkg" >/dev/null
    installer -pkg /tmp/DEPNotify-1.1.4.pkg -target /

    # Create DEPNotify log files
    touch "$DEP_N_DEBUG"
    touch "$DEP_N_LOG"

    # Configure DEPNotify General Settings
    # echo "Command: QuitKey: x" >>"$DEP_N_LOG"
    echo "Command: WindowTitle: $WINDOW_TITLE" >>"$DEP_N_LOG"
    echo "Command: MainTitle: $WELCOME_TITLE" >>"$DEP_N_LOG"
    echo "Command: MainText: $WELCOME_TEXT" >>"$DEP_N_LOG"
    echo "Status: Installing the JumpCloud agent" >>"$DEP_N_LOG"

    # Wait for active user session
    FINDER_PROCESS=$(pgrep -l "Finder")
    until [ "$FINDER_PROCESS" != "" ]; do
        echo "$(date "+%m-%d-%y_%H-%M-%S"): Finder process not found. User session not active." >>"$DEP_N_DEBUG"
        sleep 1
        FINDER_PROCESS=$(pgrep -l "Finder")
    done

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # END Pre login bootstrap workflow                                             ~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #*******************************************************************************
    # Post login active session workflow                                           *
    #*******************************************************************************

    # Capture active user username
    ACTIVE_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

    # Captures active users UID
    uid=$(id -u "$ACTIVE_USER")
    DEP_N_USER_INPUT_PLIST="/Users/$ACTIVE_USER/Library/Preferences/menu.nomad.DEPNotifyUserInput.plist"
    DEP_N_CONFIG_PLIST="/Users/$ACTIVE_USER/Library/Preferences/menu.nomad.DEPNotify.plist"
    defaults write "$DEP_N_CONFIG_PLIST" pathToPlistFile "$DEP_N_USER_INPUT_PLIST"

    ################################################################################
    # DEPNotify PLIST Settings - INSERT-CONFIGURATION                              #
    ################################################################################
    #<--INSERT-CONFIGURATION for "DEPNotify PLIST Settings" below this line---------

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # END DEPNotify PLIST Settings                                                 ~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # Launch DEPNotify full screen

    # Set ownership of the plist file
    chown "$ACTIVE_USER":staff "$DEP_N_CONFIG_PLIST"
    chmod 600 "$DEP_N_CONFIG_PLIST"
    sudo -u "$ACTIVE_USER" open -a "$DEP_N_APP" --args -path "$DEP_N_LOG" # -fullScreen

    # Download and install the JumpCloud agent
    # cat EOF can not be indented 
    curl --silent --output /tmp/jumpcloud-agent.pkg "https://s3.amazonaws.com/jumpcloud-windows-agent/production/jumpcloud-agent.pkg" >/dev/null
    mkdir -p /opt/jc
cat <<-EOF >/opt/jc/agentBootstrap.json
{
"publicKickstartUrl": "https://kickstart.jumpcloud.com:443",
"privateKickstartUrl": "https://private-kickstart.jumpcloud.com:443",
"connectKey": "$YOUR_CONNECT_KEY"
}
EOF

    # Below file created by POST install script using munkipkg
    # cat <<-EOF >/var/run/JumpCloud-SecureToken-Creds.txt
    # $ENROLLMENT_USER;$ENROLLMENT_USER_PASSWORD
    # EOF

    # Installs JumpCloud agent
    echo "$(date "+%Y-%m-%dT%H:%M:%S"): User $ACTIVE_USER is logged in, installing JC" >>"$DEP_N_DEBUG"
    installer -pkg /tmp/jumpcloud-agent.pkg -target /

    # Validate JumpCloud agent install
    JCAgentConfPath='/opt/jc/jcagent.conf'

    while [ ! -f "$JCAgentConfPath" ]; do
        echo "$(date "+%Y-%m-%dT%H:%M:%S"): Waiting for JC Agent to install" >>"$DEP_N_DEBUG"
        sleep 1
    done

    conf="$(cat /opt/jc/jcagent.conf)"
    regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'
    if [[ $conf =~ $regex ]]; then
        systemKey="${BASH_REMATCH[@]}"
    fi

    while [ -z "$systemKey" ]; do
        echo "$(date "+%Y-%m-%dT%H:%M:%S"): Waiting for systemKey to register" >>"$DEP_N_DEBUG"
        sleep 1
        conf="$(cat /opt/jc/jcagent.conf)"
        if [[ $conf =~ $regex ]]; then
            systemKey="${BASH_REMATCH[@]}"
        fi

    done

    echo "$(date "+%Y-%m-%dT%H:%M:%S"): JumpCloud agent installed!"

    Sleep 1

    echo "Status: JumpCloud agent installed!" >>"$DEP_N_LOG"
    
    # JumpCloud installed - add gate file
    touch $DEP_N_GATE_INSTALLJC
fi
# Check if the system has yet to be added to JumpCloud
if [[ ! -f $DEP_N_GATE_SYSADD ]]; then
    Sleep 1

    echo "Status: Pulling configuration settings from JumpCloud" >>"$DEP_N_LOG"

    # Add system to DEP_ENROLLMENT_GROUP_ID using System Context API Authentication
    conf="$(cat /opt/jc/jcagent.conf)"
    regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'

    if [[ $conf =~ $regex ]]; then
        systemKey="${BASH_REMATCH[@]}"
    fi

    echo "$(date "+%Y-%m-%dT%H:%M:%S"): systemKey = $systemKey " >>"$DEP_N_DEBUG"

    regex='[a-zA-Z0-9]{24}'
    if [[ $systemKey =~ $regex ]]; then
        systemID="${BASH_REMATCH[@]}"
    fi

    echo "$(date "+%Y-%m-%dT%H:%M:%S"): systemID = $systemID " >>"$DEP_N_DEBUG"

    now=$(date -u "+%a, %d %h %Y %H:%M:%S GMT")

    # create the string to sign from the request-line and the date
    signstr="POST /api/v2/systemgroups/${DEP_ENROLLMENT_GROUP_ID}/members HTTP/1.1\ndate: ${now}"

    # create the signature
    signature=$(printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n')

    DEPenrollmentGroupAdd=$(
        curl -s \
            -X 'POST' \
            -H 'Content-Type: application/json' \
            -H 'Accept: application/json' \
            -H "Date: ${now}" \
            -H "Authorization: Signature keyId=\"system/${systemID}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
            -d '{"op": "add","type": "system","id": "'${systemID}'"}' \
            "https://console.jumpcloud.com/api/v2/systemgroups/${DEP_ENROLLMENT_GROUP_ID}/members"
    )

    # create the GET string to sign from the request-list and the date
    signstr_check="GET /api/v2/systems/${systemID}/memberof HTTP/1.1\ndate: ${now}"

    # create the GET signature
    signature_check=$(printf "$signstr_check" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n')

    DEPenrollmentGroupGet=$(
        curl \
            -X 'GET' \
            -H 'Content-Type: application/json' \
            -H 'Accept: application/json' \
            -H "Date: ${now}" \
            -H "Authorization: Signature keyId=\"system/${systemID}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature_check}\"" \
            --url "https://console.jumpcloud.com/api/v2/systems/${systemID}/memberof"
    )

    # check if the system was added to the DEP ENROLLMENT GROUP in JumpCloud
    groupCheck=$(echo $DEPenrollmentGroupGet | grep $DEP_ENROLLMENT_GROUP_ID)

    # given the case that the above POST request fails, system would not be in the enrollment group
    # while the groupCheck variable is empty, attempt to add the system to the enrollment group
    # then check if the group was added, if the system is in the enrollment group, exit the loop

    # variable to ensure system time is set correctly, once during this loop
    timeSet=false
    echo "$(date "+%Y-%m-%dT%H:%M:%S"): groupcheck: $groupCheck" >>"$DEP_N_DEBUG"
    while [[ -z $groupCheck ]]; do
        # log note
        echo "$(date "+%Y-%m-%dT%H:%M:%S"): Waiting for system to be added to the DEP ENROLLMENT GROUP" >>"$DEP_N_DEBUG"
        sleep 10

        # if system is 10.12 or newer, this command should work to set the system time
        MacOSMinorVersion=$(sw_vers -productVersion | cut -d '.' -f 2)
        if [[ MacOSMinorVersion -ge 12 && $timeSet == false ]]; then
            sntp -sS $NTP_SERVER
            echo "$(date "+%Y-%m-%dT%H:%M:%S"): Setting the correct system time" >>"$DEP_N_DEBUG"
            # only run this once 
            timeSet=true
        fi

        # attempt to add system to enrollment group
        echo "$(date "+%Y-%m-%dT%H:%M:%S"): Attempting to add system to enrollment group again" >>"$DEP_N_DEBUG"
        now=$(date -u "+%a, %d %h %Y %H:%M:%S GMT")
        signstr="POST /api/v2/systemgroups/${DEP_ENROLLMENT_GROUP_ID}/members HTTP/1.1\ndate: ${now}"
        # create the signature with updated time and string
        signature=$(printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n')

        DEPenrollmentGroupAdd=$(
            curl -s \
                -X 'POST' \
                -H 'Content-Type: application/json' \
                -H 'Accept: application/json' \
                -H "Date: ${now}" \
                -H "Authorization: Signature keyId=\"system/${systemID}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
                -d '{"op": "add","type": "system","id": "'${systemID}'"}' \
                "https://console.jumpcloud.com/api/v2/systemgroups/${DEP_ENROLLMENT_GROUP_ID}/members"
        )
        
        # check if the system is in the enrollment group
        echo "$(date "+%Y-%m-%dT%H:%M:%S"): Checking Status" >>"$DEP_N_DEBUG"
        now=$(date -u "+%a, %d %h %Y %H:%M:%S GMT")
        signstr_check="GET /api/v2/systems/${systemID}/memberof HTTP/1.1\ndate: ${now}"
        signature_check=$(printf "$signstr_check" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n')
        DEPenrollmentGroupGet=$(
            curl \
                -X 'GET' \
                -H 'Content-Type: application/json' \
                -H 'Accept: application/json' \
                -H "Date: ${now}" \
                -H "Authorization: Signature keyId=\"system/${systemID}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature_check}\"" \
                --url "https://console.jumpcloud.com/api/v2/systems/${systemID}/memberof"
        )
    
        groupCheck=$(echo $DEPenrollmentGroupGet | grep $DEP_ENROLLMENT_GROUP_ID)
    done

    # Set the receipt for the system add gate. The system was added to JumpCloud at this stage
    touch $DEP_N_GATE_SYSADD
fi

# User interaction steps - check if user has completed these steps.
if [[ ! -f $DEP_N_GATE_UI ]]; then
    process=$(echo | ps aux | grep "[D]EP")
    echo $process
    if [[ -z $process ]]; then 
        FINDER_PROCESS=$(pgrep -l "Finder")
        until [ "$FINDER_PROCESS" != "" ]; do
            echo "$(date "+%m-%d-%y_%H-%M-%S"): Finder process not found. User session not active." >>"$DEP_N_DEBUG"
            sleep 1
            FINDER_PROCESS=$(pgrep -l "Finder")
        done
        sleep 2
        ACTIVE_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
        echo "$(date "+%Y-%m-%dT%H:%M:%S"): DEPnotify not running" >>"$DEP_N_DEBUG"
        sudo -u "$ACTIVE_USER" open -a "$DEP_N_APP" --args -path "$DEP_N_LOG"
    fi 
    # Waiting for DECRYPT_USER_ID to be bound to system
    echo "Status: Pulling Security Settings from JumpCloud" >>"$DEP_N_LOG"

    DECRYPT_USER_ID=$(dscl . -read /Users/$DECRYPT_USER | grep UniqueID | cut -d " " -f 2)

    while [ -z "$DECRYPT_USER_ID" ]; do
        echo "$(date "+%Y-%m-%dT%H:%M:%S"): Waiting for DECRYPT_USER_ID for user $DECRYPT_USER" >>"$DEP_N_DEBUG"
        sleep 1
        DECRYPT_USER_ID=$(dscl . -read /Users/$DECRYPT_USER | grep UniqueID | cut -d " " -f 2)
    done

    echo "Status: Security Settings Configured" >>"$DEP_N_LOG"

    # Gather OrgID
    conf="$(cat /opt/jc/jcagent.conf)"
    regex='\"ldap_domain\":\"[a-zA-Z0-9]*'
    if [[ $conf =~ $regex ]]; then
        ORG_ID_RAW="${BASH_REMATCH[@]}"
    fi

    ORG_ID=$(echo $ORG_ID_RAW | cut -d '"' -f 4)

    APIKEY=$(DecryptKey $ENCRYPTED_KEY $DECRYPT_USER_ID $ORG_ID)

    ### 
    # Recapture these variables - necessary if the system was restarted  
    DEP_N_USER_INPUT_PLIST="/Users/$ACTIVE_USER/Library/Preferences/menu.nomad.DEPNotifyUserInput.plist"
    DEP_N_CONFIG_PLIST="/Users/$ACTIVE_USER/Library/Preferences/menu.nomad.DEPNotify.plist"
    ACTIVE_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
    uid=$(id -u "$ACTIVE_USER")
    ###
    if [[ -z "${APIKEY}" ]]; then

        echo "Command: Notification: Oh no we ran into an error. Tell your Admin that your system could not decrypt the key!" >>"$DEP_N_LOG"

        echo "Command: ContinueButtonRegister: EXIT WITH ERROR" >>"$DEP_N_LOG"

        exit 1

    fi

    ################################################################################
    # User Configuration Settings - INSERT-CONFIGURATION                           #
    ################################################################################
    #<--INSERT-CONFIGURATION for "User Configuration Settings" below this line-------
 
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # END User Configuration Settings                                              ~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    # user interaction complete - add gate file
    touch $DEP_N_GATE_UI
fi
# Final steps to complete the install
if [[ ! -f $DEP_N_GATE_DONE ]]; then
    ## Get the JumpCloud SystemID
    conf="$(cat /opt/jc/jcagent.conf)"
    regex='\"systemKey\":\"[a-zA-Z0-9]{24}\"'

    if [[ $conf =~ $regex ]]; then
        systemKey="${BASH_REMATCH[@]}"
    fi

    regex='[a-zA-Z0-9]{24}'
    if [[ $systemKey =~ $regex ]]; then
        systemID="${BASH_REMATCH[@]}"
        echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud systemID found SystemID: "$systemID >>"$DEP_N_DEBUG"
    else
        echo "$(date "+%Y-%m-%dT%H:%M:%S") No systemID found" >>"$DEP_N_DEBUG"
        exit 1
    fi

    ## Capture current logFile
    logLinesRaw=$(wc -l /var/log/jcagent.log)

    logLines=$(echo $logLinesRaw | head -n1 | awk '{print $1;}')

    echo "Status: Creating System Account" >>"$DEP_N_LOG"

    ## Bind JumpCloud user to JumpCloud system
    userBind=$(
        curl -s \
            -X 'POST' \
            -H 'Accept: application/json' \
            -H 'Content-Type: application/json' \
            -H 'x-api-key: '${APIKEY}'' \
            -d '{ "attributes": { "sudo": { "enabled": '${admin}',"withoutPassword": false}}   , "op": "add", "type": "user","id": "'${userID}'"}' \
            "https://console.jumpcloud.com/api/v2/systems/${systemID}/associations"
    )

    #Check and ensure user bound to system
    userBindCheck=$(
        curl -s \
            -X 'GET' \
            -H 'Accept: application/json' \
            -H 'Content-Type: application/json' \
            -H 'x-api-key: '${APIKEY}'' \
            "https://console.jumpcloud.com/api/v2/systems/${systemID}/associations?targets=user"
    )

    regex=''${userID}''

    if [[ $userBindCheck =~ $regex ]]; then
        userID="${BASH_REMATCH[@]}"
        echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud user "$loggedInUser "bound to systemID: "$systemID >>"$DEP_N_DEBUG"
    else
        echo "$(date "+%Y-%m-%dT%H:%M:%S") error JumpCloud user not bound to system" >>"$DEP_N_DEBUG"
        exit 1
    fi

    #Wait to see local account takeover by the JumpCloud agent

    updateLog=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)

    Sleep 6

    echo "Status: Configuring System Account" >>"$DEP_N_LOG"

    accountTakeOverCheck=$(echo ${updateLog} | grep "User updates complete")

    logoutTimeoutCounter='0'

    while [[ -z "${accountTakeOverCheck}" ]]; do
        Sleep 6
        updateLog=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)
        accountTakeOverCheck=$(echo ${updateLog} | grep "User updates complete")
        logoutTimeoutCounter=$((${logoutTimeoutCounter} + 1))
        if [[ ${logoutTimeoutCounter} -eq 10 ]]; then
            echo "$(date "+%Y-%m-%dT%H:%M:%S") Error during JumpCloud agent local account takeover" >>"$DEP_N_DEBUG"
            echo "$(date "+%Y-%m-%dT%H:%M:%S") JCAgent.log: ${updateLog}" >>"$DEP_N_DEBUG"
            exit 1
        fi
    done

    echo "Status: System Account Configured" >>"$DEP_N_LOG"

    echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud agent local account takeover complete" >>"$DEP_N_DEBUG"

    # Remove from DEP_ENROLLMENT_GROUP and add to DEP_POST_ENROLLMENT_GROUP

    curl \
        -X 'POST' \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -H 'x-api-key: '${APIKEY}'' \
        -d '{"op": "remove","type": "system","id": "'${systemID}'"}' \
        "https://console.jumpcloud.com/api/v2/systemgroups/${DEP_ENROLLMENT_GROUP_ID}/members"

    echo "$(date "+%Y-%m-%dT%H:%M:%S") Removed from DEP_ENROLLMENT_GROUP_ID: $DEP_ENROLLMENT_GROUP_ID" >>"$DEP_N_DEBUG"

    curl \
        -X 'POST' \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -H 'x-api-key: '${APIKEY}'' \
        -d '{"op": "add","type": "system","id": "'${systemID}'"}' \
        "https://console.jumpcloud.com/api/v2/systemgroups/${DEP_POST_ENROLLMENT_GROUP_ID}/members"

    echo "$(date "+%Y-%m-%dT%H:%M:%S") Added to from DEP_POST_ENROLLMENT_GROUP_ID: $DEP_POST_ENROLLMENT_GROUP_ID" >>"$DEP_N_DEBUG"

    echo "Status: Applying Finishing Touches" >>"$DEP_N_LOG"

    FINISH_TEXT='This window will automatically close when onboarding is complete.\n\nYou will be taken directly to the log in screen. \n\n Log in with your new account! \n\n'

    echo "Command: MainText: $FINISH_TEXT" >>"$DEP_N_LOG"

    logLinesRaw=$(wc -l /var/log/jcagent.log)

    logLines=$(echo $logLinesRaw | head -n1 | awk '{print $1;}')

    groupSwitchCheck=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)

    groupTakeOverCheck=$(echo ${groupSwitchCheck} | grep "User updates complete")

    groupTimeoutCounter='0'

    while [[ -z "${groupTakeOverCheck}" ]]; do
        Sleep 1
        groupSwitchCheck=$(sed -n ''${logLines}',$p' /var/log/jcagent.log)
        groupTakeOverCheck=$(echo ${groupSwitchCheck} | grep "Processing user updates")
        groupTimeoutCounter=$((${groupTimeoutCounter} + 1))
        if [[ ${groupTimeoutCounter} -eq 90 ]]; then
            echo "$(date "+%Y-%m-%dT%H:%M:%S") Error during JumpCloud agent local account takeover" >>"$DEP_N_DEBUG"
            echo "$(date "+%Y-%m-%dT%H:%M:%S") JCAgent.log: ${groupSwitchCheck}" >>"$DEP_N_DEBUG"
            exit 1
        fi
        echo "$(date "+%Y-%m-%dT%H:%M:%S") Waiting for group switch :${groupTimeoutCounter} of 90" >>"$DEP_N_DEBUG"
    done

    FINISH_TITLE="All Done"

    # add gate file here before we remove the user potentially running the script
    touch $DEP_N_GATE_DONE

    if [[ $DELETE_ENROLLMENT_USERS == true ]]; then
        # delete the first logged in user
        Sleep 10
        echo "$(date "+%Y-%m-%dT%H:%M:%S") Deleting the first enrollment user: $ENROLLMENT_USER" >>"$DEP_N_DEBUG"
        dscl . -delete /Users/$ENROLLMENT_USER
        rm -rf /Users/$ENROLLMENT_USER
        echo "$(date "+%Y-%m-%dT%H:%M:%S") Deleting the decrypt user: $DECRYPT_USER" >>"$DEP_N_DEBUG"
        dscl . -delete /Users/$DECRYPT_USER
        rm -rf /Users/$DECRYPT_USER
    fi

    echo "Command: MainTitle: $FINISH_TITLE" >>"$DEP_N_LOG"
    echo "Status: Enrollment Complete" >>"$DEP_N_LOG"
    echo "$(date "+%Y-%m-%dT%H:%M:%S") Status: Enrollment Complete" >>"$DEP_N_DEBUG"

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # END Post login active session workflow                                       ~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fi
# final steps to check 
# this will initially fail at the end of the script, if we remove the welcome user
# the launchdaemon will be running as user null. However on next run, the script 
# will run as root and should have access to remove the launch daemon and remove 
# this script. The launchdaemon with status 127 will remain on the system until 
# reboot, it will be removed after reboot.
if [[ -f $DEP_N_GATE_DONE ]]; then
    sleep 10
    ACTIVE_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
    # echo "$(date "+%Y-%m-%dT%H:%M:%S") User: $ACTIVE_USER is Unloading LaunchDaemon" >>"$DEP_N_DEBUG"
    # launchctl unload /Library/LaunchDaemons/com.jumpcloud.prestage.plist
    echo "$(date "+%Y-%m-%dT%H:%M:%S") User: $ACTIVE_USER Status: Removing LaunchDaemon" >>"$DEP_N_DEBUG"
    rm -rf "/Library/LaunchDaemons/${daemon}"
    # Make script delete itself
    rm -- "$0"
fi
