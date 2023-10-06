#### Name

Mac - Refresh Login Window  12345 |  v1.0 JCCG

#### commandType

mac

#### Command

```
loginWindowProccess="$(ps -Ajc | grep loginwindow | awk '{print $2}')"
kill -9 $loginWindowProccess
```

#### Description

Refreshes the Mac login window by restarting the login window process. This can be used to reveal a user who was locked out on a Mac machine but has been unlocked without restarting the machine.

**Warning** if run when a user is signed in this command will sign them out and bring them to the login screen.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Refresh%20Login%20Window.md"
```
