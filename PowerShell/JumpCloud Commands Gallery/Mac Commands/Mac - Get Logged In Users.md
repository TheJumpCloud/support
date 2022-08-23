#### Name

Mac - Get logged in user | v1.0 JCCG 

#### commandType

mac

#### Command

```
stat -f "%Su" /dev/console
```

#### Description

The owner of the /dev/console file will reprepsent the currently logged in user to the OSX GUI. This command ouputs this user.
If the command returns **root** then no user has signed in and the machine is online at the login screen. 

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Get%20Logged%20In%20Users.md"
```
