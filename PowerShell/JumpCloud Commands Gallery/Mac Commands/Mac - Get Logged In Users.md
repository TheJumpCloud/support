#### Name

Mac - Get logged in user | JCCG 1.0

#### commandType

mac

#### Command

```
stat -f "%Su" /dev/console
```

#### Description

The owner of the /dev/console file will reprepsent the currently logged in user to the OSX GUI. This command ouputs this user. 

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-Mac-GetLoggedInUsers'
```
