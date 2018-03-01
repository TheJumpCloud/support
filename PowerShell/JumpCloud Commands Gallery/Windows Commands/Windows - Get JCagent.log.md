#### Name

Windows - Get JCagent.log

#### commandType

windows

#### Command

```
Get-content -Path 'C:\Windows\Temp\jcagent.log'
```

#### Description

Returns the JC agent log from a Windows system. If the jcagent.log is larger than 1 MB the most recend 1 MB of data from the log will be returned.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL ''
```
