#### Name

Windows - Run Once Template - Remove System From Associated System Group | v1.0 JCCG

#### commandType

windows

#### Command

```
# Populate systemGroupID and JumpCloudAPIKey variables before running the command

$systemGroupID=''
$JumpCloudAPIKey=''

#--------------------Enter command below this line--------------------


#--------------------Do not modify below this line--------------------

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$conf = Get-Content 'C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.conf'
$conf -match "systemKey`":`"(`\w+)`"" | Out-Null
$systemKey = $Matches[1]

$Request = @{

    Method    = "Post"
    Uri       = "https://console.jumpcloud.com/api/v2/systemgroups/$systemGroupID/members"
    Body      = @{op= "remove";type= "system";id= "$systemKey" } | ConvertTo-Json
    Header    = @{'Content-Type' = 'application/json'; 'Accept' = 'application/json'; 'X-API-KEY' = "$JumpCloudAPIKey" }
    UserAgent = 'JCCommand'
}

try
{
    Invoke-RestMethod @Request
    Write-Output "JumpCloud system: ${systemKey} removed from system group $systemGroupID"
}
catch
{
    Write-Output "Error:  $($_.ErrorDetails)"
}

```

#### Description

This template can be modified to satisfy use cases where admins wish to run a command once on a number of target systems and have the system automatically removed from the system group which associates the system with the command.

*Directly associating JumpCloud systems to JumpCloud commands? [No problem refer to this template for removing systems from a JumpCloud command]()*

Before running this command the variables **systemGroupID=''** and **JumpCloudAPIKey** must be populated.

To find the systemGroupID for a JumpCloud system group navigate to the "GROUPS" section of the JumpCloud admin portal and select the system group to bring up the system group details. Within the URL of the selected command the systemGroupID will be the 24 character string between 'system/' and '/details'. The JumpCloud PowerShell command [Get-JCGroup](https://github.com/TheJumpCloud/support/wiki/Get-JCGroup) can also be used to find the systemGroupID. The systemGroupID is the 'id' value which will be displayed for each JumpCloud group when Get-JCGroup is called.

![systemGroupID example](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/systemGroupID.png?raw=true)

Enter the payload of the command under the line '#--------------------Enter command below this line--------------------'

After the command is run the system is removed from the system group specified via the JumpCloud system context API. [Learn more about the JumpCloud system context API here](https://docs.jumpcloud.com/2.0/authentication-and-authorization/system-context). 

#### *Import This Command*

To import this command template into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL ''
```
