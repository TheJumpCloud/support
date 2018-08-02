#### Name

Mac - Send Notification Message | v1.0 JCCG 

#### commandType

mac

#### Command

```
# Enter the notification message
# Enter the message within the "" of Notification=""

Notification=""

------- Do not modify below this line ------
user=`ls -la /dev/console | cut -d " " -f 4`
sudo -u $user osascript -e 'tell application (path to frontmost application as text) to display dialog "'"$Notification"'" buttons {"OK"} with icon stop'
```

#### Description

Administrators that wish to send notification messages to the current logged in user of the target Mac machines can use this command. 

To use this command enter the text to display through the notification in the Notification="" variable.

Example: Notification="Fire drill on Monday at 10 am"

![Example Notification](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Notification%20Example.png?raw=true)


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-mac-sendnotificationmessage'
```
