#### Name

Windows - Set JumpCloud Password Manager's Release Channel | v1.0 JCCG

#### commandType

windows

#### Command

```
# Set $releaseChannel to beta OR dogfood OR public depending on your desired release channel
$releaseChannel = "public"
#------- Do not modify below this line ------

$allowed_values = @("beta", "dogfood", "public")

if (-not ($allowed_values -ccontains $releaseChannel)) {
    Write-Host "Error: Variable `$releaseChannel must be either 'beta', 'dogfood', or 'public'."
    exit 1
}

# Get the current user's SID (Security Identifier)
$loggedUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
$loggedUser = $loggedUser -replace '.*\\'

# Construct the Registry path using the user's SID
$userSID = (New-Object System.Security.Principal.NTAccount($loggedUser)).Translate([System.Security.Principal.SecurityIdentifier]).Value
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$userSID"
$loggedOnUserProfileImagePath = Get-ItemPropertyValue -Path $registryPath -Name 'ProfileImagePath'
$filePath = "$loggedOnUserProfileImagePath\AppData\Roaming\JumpCloud Password Manager\data\daemon\releaseChannel.txt"

$directory = Split-Path $filePath
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force
}

Set-Content -Path $filePath -Value $releaseChannel -NoNewline
```

#### Description

This command will set the desired release channel for JumpCloud's Password Manager in application's directory. The relesase channel options are beta, dogfood and public.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Set%20ReleaseChannel%20In%20JumpCloud%20Password%20Manager.md"
```
