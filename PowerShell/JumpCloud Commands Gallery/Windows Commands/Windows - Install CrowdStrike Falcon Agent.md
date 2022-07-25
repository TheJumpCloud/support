#### Name

Windows - Install CrowdStrike Falcon Agent | v1.0 JCCG

#### commandType

windows

#### Command

```
$CID="ENTER CID WITH CHECKSUM VALUE HERE"
$installerURL="ENTER URL TO FALCON AGENT INSTALLER HERE"

############### Do Not Edit Below This Line ###############

$installerTempLocation="C:\Windows\Temp\CSFalconAgentInstaller.exe"

if (Get-Service "CSFalconService" -ErrorAction SilentlyContinue) {
    Write-Host "Falcon Agent already installed, nothing to do."
    exit 0
}
Write-Host "Falcon Agent not installed."

Write-Host "Downloading Falcon Agent installer now."
try {
    Invoke-WebRequest -Uri $installerURL -OutFile $installerTempLocation
}
catch {
    Write-Error "Unable to download Falcon Agent installer."
    exit 1
}
Write-Host "Finished downloading Falcon Agent installer."

Write-Host "Installing Falcon Agent now, this may take a few minutes."
try {
    $args = @("/install","/quiet","/norestart","CID=$CID")
    $installerProcess = Start-Process -FilePath $installerTempLocation -Wait -PassThru -ArgumentList $args
}
catch {
    Write-Error "Failed to run Falcon Agent installer."
    exit 1
}
Write-Host "Falcon Agent installer returned $($installerProcess.ExitCode)."

exit $installerProcess.ExitCode

```

#### Description

This command will download and install the CrowdStrike Falcon Agent to the device if it isn't already installed.

In order to use this command:

1. Download the CrowdStrike Falcon Agent installer and host it at a URL that your devices can access.
2. Edit the first two lines of the script to include your Customer ID (with checksum value) and the URL where you are hosting the installer.
3. Extend the command timeout to a value that makes sense in your environment. The suggested command timeout for an environment with average network speeds on devices with average computing power is 10 minutes. Note that the command may timeout with a 124 error code in the command result window if not extended, but the script will continue to run.
4. It is recommended to set the Launch Event for the command to “Run As Repeating” with an interval of one hour.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/Windows%20Commands/Windows%20-%20Install%20CrowdStrike%20Falcon%20Agent.md"
```
