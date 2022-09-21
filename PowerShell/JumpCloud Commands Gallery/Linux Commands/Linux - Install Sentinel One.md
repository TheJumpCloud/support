#### Name

Linux - Install Sentinel One | v1.0 JCCG

#### commandType

linux

#### Command

```
#!/bin/bash
###################################################
sentinelToken=YOURTOKEN
filename=sentineloneagent.deb
DownloadURL=https://path/to/url.deb
###################################################


curl -o $filename $DownloadURL

apt install ./$filename -y

if [ -f /opt/sentinelone/bin/sentinelctl; then
    echo “/opt/sentinelone/bin/sentinelctl found!”
    /opt/sentinelone/bin/sentinelctl management token set $sentinelToken
    /opt/sentinelone/bin/sentinelctl control start
else
    echo “/opt/sentinelone/bin/sentinelctl not found!”
    exit 1
fi
```

#### Description

Install Sentinel One agent

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Linux%20Commands/Linux%20-%20Install%20Sentinel%20One.md"
```
