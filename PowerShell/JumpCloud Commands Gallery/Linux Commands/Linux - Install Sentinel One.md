#### Name

Linux - Install Sentinel One | v1.0 JCCG

#### commandType

linux

#### Command

```
wget SENTINELONEFILEURL

apt install ./SentinelAgentFileName.deb

/opt/sentinelone/bin/sentinelctl management token set site_token

/opt/sentinelone/bin/sentinelctl control start
```

#### Description

Install Sentinel One agent

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20Snap%20-%20Install%20Microsoft%20VS%20Code.md"
```
