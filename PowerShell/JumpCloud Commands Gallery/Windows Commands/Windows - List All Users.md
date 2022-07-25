#### Name

Windows - List All Users | v1.0 JCCG

#### commandType

windows

#### Command

```
$UserAccounts = Get-WmiObject -Class Win32_UserAccount -Filter {LocalAccount = "True"} | select Name, Disabled 

Write-Output $UserAccounts
```

#### Description

Lists all user accounts on a Windows system and shows if the account is enabled or disabled

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/Windows%20Commands/Windows%20-%20List%20All%20Users.md"
```
