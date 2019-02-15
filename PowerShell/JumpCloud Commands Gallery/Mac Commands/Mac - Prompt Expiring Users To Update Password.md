#### Name

Mac - Prompt Expiring Users To Update Their Password | v1.0 JCCG

#### commandType

mac

#### Command

```
## Populate below variable before running command
JCAPIKey=''

## alertDaysThreshold set to '7' by default.
## Users whose passwords will expire in 7 days or less will receive a prompt to update.
## Update the value of the variable alertDaysThreshold=''to modify the threshold.
alertDaysThreshold='7'

#------- Do not modify below this line ------
user=$(ls -la /dev/console | cut -d " " -f 4)

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
    echo "${user} password_expiration_date: ${expirationDay}"
else
    echo "Could not locate the password expiration date for user ${user}."
    echo "Is ${user} enabled for password_never_expires?"
    echo "If so users enabled with password_never_expires have no password expiration date."
    exit 1
fi

Today="$(echo $(date -u +%Y-%m-%d))"

daysToExpiration=$(echo $((($(date -jf %Y-%m-%d $expirationDay +%s) - $(date -jf %Y-%m-%d $Today +%s)) / 86400)))
echo "${user} password will expire in ${daysToExpiration} days"

if [ "$daysToExpiration" -le "$alertDaysThreshold" ]; then
    echo "${daysToExpiration} within alertDaysThreshold of ${alertDaysThreshold} prompting user"
    userPrompt=$(sudo -u $user osascript -e 'display dialog "Your JumpCloud password will expire in '"${daysToExpiration}"' days.\nClick on the JumpCloud icon in your menu bar ↑ and reset your password, so you do not lose access to critical resources." with title "JumpCloud Password Expiration Warning" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns"' 2>/dev/null)
    echo "$userPrompt"

else
    echo "${daysToExpiration} NOT within alertDaysThreshold of ${alertDaysThreshold} NOT prompting user"

fi

exit 0
```

#### Description

Queries the current signed in user's password expiration date and determines if this date is set to expire within the threshold set for the variable `alertDaysThreshold='7'`.

By default this value is set to 7 days.

If it is determined that the users password will expire within the alert days threshold then a notification is displayed to the user.

![Mac_PasswordExpiration_Notification](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Mac_PasswordExpiration_Notification?raw=true)

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/fh5qZ'
```
