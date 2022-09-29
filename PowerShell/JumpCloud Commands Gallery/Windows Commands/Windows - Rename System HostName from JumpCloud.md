#### Name

Windows - Rename System HostName from JumpCloud | v2.0 JCCG

#### commandType

windows

#### Command

```
################################################################################
# This script will update the system hostname to
# match the value of this systems displayName in the JumpCloud console.
# An API Key with read access is required to run this script.
################################################################################

# Set Read API KEY - Required to read "DisplayName" from console.jumpcloud.com
$JCApiKey = "YourReadOnlyAPIKey"

# ------- Do not modify below this line ------
$config = get-content 'C:\Program Files\JumpCloud\Plugins\Contrib\jcagent.conf'
$regex = 'systemKey\":\"(\w+)\"'
$systemKey = [regex]::Match($config, $regex).Groups[1].Value
$headers = @{
    Accept      = "application/json"
    'x-api-key' = $JCApiKey
    ContentType = 'application/json'
}
try {
    $content = Invoke-RestMethod -Method GET -Uri "https://console.jumpcloud.com/api/systems/$($systemKey)" -ContentType 'application/json' -Headers $headers -UseBasicParsing
}
catch [System.Net.WebException] {
    Write-Host "Caught Web Exception"
    try {
        $content = Invoke-WebRequest -Method GET -Uri "https://console.jumpcloud.com/api/systems/$($systemKey)" -ContentType 'application/json' -Headers $headers -UseBasicParsing
        Write-Host "Resolving: Https://console.jumpcloud.com"
        Write-Host "StatusCode: $($content.statusCode)"
        $content = $content.Content | ConvertFrom-Json
    }
    catch {
        "Could Not Resolve"
        exit 1
    }
}
$oldName = hostname
$newName = $($content.DisplayName)
if ($newName -ne $oldName) {
    Write-Host "New Hostname Found: $($content.DisplayName)"
    Rename-Computer -NewName $newName -Force
    Write-Host "$oldName was renamed to $newName"
    Write-Host "The changes will take effect after you restart the computer"
}
if ([System.String]::IsNullOrEmpty($newName)) {
    Write-Host "Could not find hostname from JumpCloud Console"
    exit 1
}
```

#### Description

This script uses a read only API key to gather info about the current system. Using Regex, the code filters out the displayName of a given system and sets the system HostName to the name set in the JumpCloud console.

Please note, there are specific rules for the hostname value. Hostnames must:

- Be a maximum 63 characters in length
- Contain no whitespace characters or periods
- Contain only alphanumeric characters and hyphens '-'

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Rename%20System%20HostName%20from%20JumpCloud.md"
```
