#### Name

Mac - Prompt Users To Update Their Password | v1.0 JCCG

#### commandType

mac

#### Command

```
user=$(ls -la /dev/console | cut -d " " -f 4)

echo "Signed in user: ${user}"

userPrompt=$(sudo -u $user osascript -e 'display dialog "Please update your JumpCloud password immediately. \n\nClick on the JumpCloud icon in your menu bar to update your password." with title "Update Your JumpCloud Password Immediately" with icon file "Applications:Jumpcloud.app:Contents:Resources:AppIcon.icns" giving up after 120' 2>/dev/null)

if [ "$userPrompt" = "button returned:OK, gave up:false" ]; then
    echo "User input: button returned:Ok"

else
    echo "User input: $userPrompt"
    echo "Details: Timeout"
    exit 1
fi
```

#### Description

Displays a notification to the signed in user and informs them to update their password using the JumpCloud Menubar app.

![Mac_PasswordUpdate_Notification](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Mac_PasswordUpdate_Notification.png?raw=true)

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Prompt%20Users%20To%20Update%20Password.md"
```
