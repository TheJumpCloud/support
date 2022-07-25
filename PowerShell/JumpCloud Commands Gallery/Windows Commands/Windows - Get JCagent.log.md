#### Name

Windows - Get JCagent.log | v1.0 JCCG

#### commandType

windows

#### Command

```
Get-content -Path 'C:\Windows\Temp\jcagent.log'
```

#### Description

Returns the jcagent.log from a Windows system. If the jcagent.log is larger than 1 MB the most recend 1 MB of data from the log will be returned.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Get%20JCagent.log.md"
```
