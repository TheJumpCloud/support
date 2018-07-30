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


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-windows-sendnotificationmessage'
```
