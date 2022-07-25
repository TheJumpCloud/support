#### Name

Mac - Prompt Users To Update Password With Expiration Date Logic | v1.0 JCCG

#### commandType

mac

#### Command

```
# Populate below variable before running command
JCAPIKey=''

#------- Do not modify below this line ------
user=$(ls -la /dev/console | cut -d " " -f 4)
echo "Signed in user: ${user}"

# Captures password expiration policy for organization
orgSettings=$(
    curl -s \
        -X 'GET' \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H 'x-api-key: '${JCAPIKey}'' \
        "https://console.jumpcloud.com/api/settings/"
)

regex='"passwordExpirationInDays":.*'

if [[ $orgSettings =~ $regex ]]; then
    unformattedExpirationDays1="${BASH_REMATCH[@]}"
    passwordExpirationPolicyInDays=$(echo $unformattedExpirationDays1 | cut -d : -f 2 | cut -d , -f 1)
fi

# Captures password expiration date for logged in user
passwordExpirationDate=$(
    curl -s \
        -X 'POST' \
        -d '{"filter":[{"username":"'${user}'"}],"fields" : "password_expiration_date"}' \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -H 'x-api-key: '${JCAPIKey}'' \
        "https://console.jumpcloud.com/api/search/systemusers"
)

regex=':".*T'
if [[ $passwordExpirationDate =~ $regex ]]; then
    unformattedDate1="${BASH_REMATCH[@]}"
    unformattedDate2=$(echo "${unformattedDate1:2}")
    expirationDay=${unformattedDate2%?}
    echo "Password_expiration_date: ${expirationDay}"
else
    echo "Could not locate password expiration date"
    exit 1
fi

Today="$(echo $(date -u +%Y-%m-%d))"

# Calculates days to expiration
daysToExpiration=$(echo $((($(date -jf %Y-%m-%d $expirationDay +%s) - $(date -jf %Y-%m-%d $Today +%s)) / 86400)))
echo "Days Until Password Expires: ${daysToExpiration} days"

# Compares days to expiration $passwordExpirationPolicyInDays variable
if [ "$daysToExpiration" -lt "$passwordExpirationPolicyInDays" ]; then
    userPrompt=$(sudo -u $user osascript -e 'display dialog "Please update your JumpCloud password immediately. \n\nClick on the JumpCloud icon in your menu bar to update your password." with title "Update Your JumpCloud Password Immediately" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 120' 2>/dev/null)

    if [ "$userPrompt" = "button returned:OK, gave up:false" ]; then
        echo "User input: button returned:Ok"
        echo "Password update: Pending"

    else
        echo "User input: $userPrompt"
        echo "Details: Timeout"
        echo "Password update: Pending"
        exit 1
    fi
else

    echo echo "Password update: Completed"

fi

exit 0

```

#### Description

If the signed in user has not reset their password on the day the command is run then a notification is sent to the user. **This logic allows the command to be set to run as a repeating on a set of target systems and will only re-prompt users who do not take action and update their passwords.**


Required Variables:
* JCAPIKEY - This must be populated with your API key.
* Password aging must be enabled in the JumpCloud Organization settings.

![Mac_PasswordUpdate_Notification](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Mac_PasswordUpdate_Notification.png?raw=true)

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Prompt%20Users%20To%20Update%20Password%20With%20Expiration%20Date%20Logic.md"
```
