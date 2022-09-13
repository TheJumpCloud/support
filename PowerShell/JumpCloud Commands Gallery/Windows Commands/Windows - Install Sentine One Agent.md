#### Name

Windows - Install Sentinel One Agent| v1.0 JCCG

#### commandType

windows

#### Command

```
$siteToken="SITE TOKEN"
$installerURL="SENTINEL ONE INSTALLER URL"

############### Do Not Edit Below This Line ###############

$installerTempLocation="C:\Windows\Temp\SentinelOneAgentInstaller.exe"

if (Get-Service "SentinelOneService" -ErrorAction SilentlyContinue) {
    Write-Host "Sentinel One Agent already installed, nothing to do."
    exit 0
}
Write-Host "Sentinel One Agent not installed."

Write-Host "Downloading Sentinel One Agent installer now."
try {
    Invoke-WebRequest -Uri $installerURL -OutFile $installerTempLocation
}
catch {
    Write-Error "Unable to download Sentinel One Agent installer."
    exit 1
}
Write-Host "Finished downloading Sentinel One Agent installer."

Write-Host "Installing Sentinel One Agent now, this may take a few minutes."
try {
    ."$installerTempLocation" --dont_fail_on_config_preserving_failures -t $siteToken
}
catch {
    Write-Error "Failed to run Sentinel One Agent installer."
    exit 1
}
Write-Host "Sentinel One Agent installer returned $($installerProcess.ExitCode)."

exit $installerProcess.ExitCode

```

#### Description

This command will download and install the Sentinel One Agent to the device if it isn't already installed.

In order to use this command:

1. Download the Sentinel One Agent installer and host it at a URL that your devices can access.
2. Edit the first two lines of the script to include your Customer ID (with checksum value) and the URL where you are hosting the installer.
3. Extend the command timeout to a value that makes sense in your environment. The suggested command timeout for an environment with average network speeds on devices with average computing power is 10 minutes. Note that the command may timeout with a 124 error code in the command result window if not extended, but the script will continue to run.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Install%20%20Falcon%20Agent.md"
```
