#### Name

Mac - Send Notification Message | v1.1 JCCG

#### commandType

mac

#### Command

```
#!/bin/bash
# Enter the notification message
# Enter the message within the "" of Notification=""
Notification="Hello There"

#------- Do not modify below this line ------
sudo -u $(stat -f "%Su" /dev/console) osascript -e 'tell app "System Events" to display dialog "'"$Notification"'"'
```

#### Description

Administrators that wish to send notification messages to the current logged in user of the target Mac machines can use this command.

To use this command enter the text to display through the notification in the Notification="" variable.

Example: Notification="Fire drill on Monday at 10 am"

![Example Notification](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Notification%20Example.png?raw=true)

*Note* Systems running macOS Catalina and newer will likely need to apply a PPPC profile to the system prior to running this command to allow the JumpCloud Agent and Bash to interact with system events and post the notification message. An example PPPC profile is posted under the [Custom Configuration Profile documentation](https://github.com/TheJumpCloud/support/tree/master/MDM/Custom%20Configuration%20Profiles#example-pppc-profile-for-the-jumpcloud-agent)


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-mac-sendnotificationmessage'
```
