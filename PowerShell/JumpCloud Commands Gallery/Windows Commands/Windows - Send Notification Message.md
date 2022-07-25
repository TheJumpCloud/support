#### Name

Windows - Send Notification Message | JCCG v1.0

#### commandType

windows

#### Command

```
# Enter the notification message
# Enter the message within the "" of $Notification=""

$Notification=""

# ------- Do not modify below this line ------

Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $Notification"
```

#### Description
Administrators that wish to send notification messages to the current logged in user of the target Windows machines can use this command. 

To use this command enter the text to display through the notification in the $Notification="" variable.

Example: $Notification="Fire drill at 10 am on Monday"

![Example Notification](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Windows%20notification.png?raw=true)


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/Windows%20Commands/Windows%20-%20Send%20Notification%20Message.md"
```
