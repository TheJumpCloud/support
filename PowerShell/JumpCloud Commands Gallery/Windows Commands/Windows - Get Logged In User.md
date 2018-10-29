#### Name

Windows - Get Logged In User | v1.0 JCCG

#### commandType

windows

#### Command

```
Get-WMIObject -class Win32_ComputerSystem | select-object -expandproperty username
```

#### Description

Get current logged in user

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL ''
```
