#### Name

Mac - List All Users | v1.0 JCCG

#### commandType

mac

#### Command

```
dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'
```

#### Description

Lists all users on a Mac
#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/Mac%20Commands/Mac%20-%20List%20All%20Users.md"
```
