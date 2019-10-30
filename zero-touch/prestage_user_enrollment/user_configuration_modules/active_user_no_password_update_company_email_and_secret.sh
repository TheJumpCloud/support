#!/bin/bash

#*******************************************************************************
#       Module Type: user_configuration
#       Module Name: pending_or_active_user_company_email_and_secret
#       Module Version: 1.0
#
#       Details: This module can be used to takeover existing pending or active
#       users during the DEP enrollment process. The input fields "Company Email"
#       is used to query the "EMAIL" attribute for existing JumpCloud users.
#       The input field "Secret" is used to query the "employeeIdentifier".
#       The "employeeIdentifier" field for users must be populated with a value
#       for this workflow to succeed.The "employeeIdentifier" attribute is
#       required to be unique per user.
#
#
#      Questions or feedback on the jumpcloud_bootstrap workflow? Please
#      contact support@jumpcloud.com
#
#      Author: Scott Reed | scott.reed@jumpcloud.com
#
#*******************************************************************************

################################################################################
# DEPNotify PLIST Settings                                                     #
################################################################################
#<----Copy from below this line------------------------------------------------

defaults write "$DEP_N_CONFIG_PLIST" registrationMainTitle "Activate Your Account"
defaults write "$DEP_N_CONFIG_PLIST" registrationButtonLabel "Activate Your Account"

defaults write "$DEP_N_CONFIG_PLIST" textField1Label "Enter Your Company Email Address"
defaults write "$DEP_N_CONFIG_PLIST" textField1Placeholder "enter email in all lowercase characters"

defaults write "$DEP_N_CONFIG_PLIST" textField2Label "Enter Your Secret Word"
defaults write "$DEP_N_CONFIG_PLIST" textField2Placeholder "enter secret in all lowercase characters"

#<----To above this line-------------------------------------------------------
# Paste the above contents into the section "DEPNotify PLIST Settings" of the master
# 'jumpcloud_bootstrap_template.sh' file
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# END DEPNotify PLIST Settings                                                ~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

################################################################################
# User Configuration Settings                                                  #
################################################################################
#<----Copy from below this line------------------------------------------------

echo "Command: ContinueButtonRegister: ACTIVATE YOUR ACCOUNT" >>"$DEP_N_LOG"

sleep 1

while [ ! -f "$DEP_N_REGISTER_DONE" ]; do
    echo "$(date "+%Y-%m-%dT%H:%M:%S"): Waiting for user to fill in information." >>"$DEP_N_DEBUG"
    sleep 1
done

CompanyEmail=$(defaults read $DEP_N_USER_INPUT_PLIST "Enter Your Company Email Address")
Secret=$(defaults read $DEP_N_USER_INPUT_PLIST "Enter Your Secret Word")

LOCATED_ACCOUNT='False'

while [ "$LOCATED_ACCOUNT" == "False" ]; do

    userSearch=$(
        curl -s \
            -X 'POST' \
            -H 'Content-Type: application/json' \
            -H 'Accept: application/json' \
            -H "x-api-key: ${APIKEY}" \
            -d '{"filter":[{"employeeIdentifier":"'${Secret}'","email":"'${CompanyEmail}'"}],"fields":["username"]}' \
            "https://console.jumpcloud.com/api/search/systemusers"
    )

    regex='totalCount"*.*,"results"'
    if [[ $userSearch =~ $regex ]]; then
        userSearchRaw="${BASH_REMATCH[@]}"
    fi

    totalCount=$(echo $userSearchRaw | cut -d ":" -f2 | cut -d "," -f1)

    sleep 1

    if [ "$totalCount" == "1" ]; then
        echo "Status: Click CONTINUE" >>"$DEP_N_LOG"
        echo "Command: ContinueButton: CONTINUE" >>"$DEP_N_LOG"
        LOCATED_ACCOUNT='True'
    else

        echo "Status: Account Not Found" >>"$DEP_N_LOG"

        rm $DEP_N_REGISTER_DONE >/dev/null 2>&1

        echo "Command: ContinueButtonRegister: Try Again" >>"$DEP_N_LOG"

        sleep 1

        while [ ! -f "$DEP_N_REGISTER_DONE" ]; do
            echo "$(date "+%Y-%m-%dT%H:%M:%S"): Waiting for user to fill in information." >>"$DEP_N_DEBUG"
            sleep 1
        done

        CompanyEmail=$(defaults read $DEP_N_USER_INPUT_PLIST "Enter Your Company Email Address")
        Secret=$(defaults read $DEP_N_USER_INPUT_PLIST "Enter Your Secret Word")
    fi

done

# Capture userID
regex='[a-zA-Z0-9]{24}'
if [[ $userSearch =~ $regex ]]; then
    userID="${BASH_REMATCH[@]}"
    echo "$(date "+%Y-%m-%dT%H:%M:%S") JumpCloud userID found userID: "$userID >>"$DEP_N_DEBUG"
else
    echo "$(date "+%Y-%m-%dT%H:%M:%S") No JumpCloud userID found." >>"$DEP_N_DEBUG"
    exit 1
fi

echo "Status: JumpCloud User Account Located" >>"$DEP_N_LOG"

while [ ! -f "$DEP_N_DONE" ]; do
    echo "$(date "+%Y-%m-%dT%H:%M:%S"): Waiting for user to click CONTINUE" >>"$DEP_N_DEBUG"
    sleep 1
done

# DEPnotify rest
DEPNotifyReset

touch "$DEP_N_LOG"

WINDOW_TITLE='User Configuration'
FINAL_TITLE="Almost to the finish line!"
FINAL_TEXT='\n \n \n Working on account configuration'

echo "Command: QuitKey: x" >>"$DEP_N_LOG"
echo "Command: WindowTitle: $WINDOW_TITLE" >>"$DEP_N_LOG"
echo "Command: MainTitle: $FINAL_TITLE" >>"$DEP_N_LOG"
echo "Command: MainText: $FINAL_TEXT" >>"$DEP_N_LOG"
echo "Status: Activating Account" >>"$DEP_N_LOG"

sudo -u "$ACTIVE_USER" open -a "$DEP_N_APP" --args -path "$DEP_N_LOG" -fullScreen

## User creation

userUpdate=$(
    curl -s \
        -X 'PUT' \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -H "x-api-key: ${APIKEY}" \
        "https://console.jumpcloud.com/api/systemusers/${userID}"
)

#<----To above this line--------------------------------------------------------
# Paste the above contents into the section "User Configuration Settings " of
# the master 'jumpcloud_bootstrap_template.sh' file
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# END user_configuration Settings                                              ~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
