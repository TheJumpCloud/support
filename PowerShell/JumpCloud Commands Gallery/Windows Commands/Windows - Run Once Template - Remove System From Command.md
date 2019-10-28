#### Name

Windows - Run Once Template - Remove System From Command | v1.0 JCCG

#### commandType

windows

#### Command

```
# Populate commandID and JumpCloudAPIKey variables before running the command

$commandID=''
$JumpCloudAPIKey=''

#--------------------Enter command below this line--------------------


#--------------------Do not modify below this line--------------------

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$conf = Get-Content 'C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.conf'
$conf -match "systemKey`":`"(`\w+)`"" | Out-Null
$systemKey = $Matches[1]

$Request = @{

    Method    = "Post"
    Uri       = "https://console.jumpcloud.com/api/v2/commands/$commandID/associations"
    Body      = @{type = "system"; op = "remove"; id = $systemKey } | ConvertTo-Json
    Header    = @{'Content-Type' = 'application/json'; 'Accept' = 'application/json'; 'X-API-KEY' = "$JumpCloudAPIKey" }
    UserAgent = 'JCCommand'
}

try
{
    Invoke-RestMethod @Request
    Write-Output "JumpCloud system: ${systemKey} removed from command target list"
}
catch
{
    Write-Output "Error:  $($_.ErrorDetails)"
}

```

#### Description

This template can be used to satisfy use cases where admins wish to run a command once on a number of target systems and have the system automatically removed from the commands system target list after the command is run.

*Using a system group for associating systems with JumpCloud commands? [No problem refer to this template for removing systems from a JumpCloud command from an associated JumpCloud system group]().*

Before running this command the variables **commandID=''** and **JumpCloudAPIKey** must be populated.

![commanID example](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/commandID.png?raw=true)

To find the commandID within the JumpCloud admin console select the command to expand the command details. Within the URL of the selected command the commandID will be the 24 character string between 'commands/' and '/details'. The JumpCloud PowerShell command [Get-JCCommand](https://github.com/TheJumpCloud/support/wiki/Get-JCCommand) can also be used to find the commandID which will reveal the commandID in the '_id' field.

Enter the payload of the command under the line '#--------------------Enter command below this line--------------------'

#### *Import This Command*

To import this command template into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JeulE'
```
