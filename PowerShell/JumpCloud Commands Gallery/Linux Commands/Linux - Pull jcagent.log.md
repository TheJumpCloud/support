#### Name

Linux - Pull jcagent.log | v1.0 JCCG

#### commandType

linux

#### Command

```
cat /var/log/jcagent.log
```

#### Description

Pulls the JC agent log from a Linux system. If the jcagent.log is larger than 1 MB the most recend 1 MB of data from the log will be returned.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/Linux%20Commands/Linux%20-%20Pull%20jcagent.log.md"
```
