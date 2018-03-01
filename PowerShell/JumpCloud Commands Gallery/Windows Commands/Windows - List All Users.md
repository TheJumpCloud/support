#### Name

Windows - List All Users

#### commandType

windows

#### Command

```
$UserAccounts = Get-WmiObject -Class Win32_UserAccount -Filter {LocalAccount = "True"} | select Name, Disabled 

Write-Output $UserAccounts
```

#### Description

Lists all users from a Windows system

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL ''
```
