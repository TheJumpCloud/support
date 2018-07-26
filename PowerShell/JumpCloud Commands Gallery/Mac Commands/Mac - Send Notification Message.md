#### Name

Mac - Send Notification Message | JCCG v1.0

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


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'Create and enter Git.io URL'
```
