#### Name

Windows - Install CrowdStrike Falcon Agent | v1.0 JCCG

#### commandType

windows

#### Command

```
$CID="ENTER CID HERE"
$installerURL="ENTER URL TO FALCON AGENT INSTALLER HERE"

##### Do Not Edit Below This Line #####

$installerTempLocation="C:\Windows\Temp\CSFalconAgentInstaller.exe"

if(Get-Service "CSFalconService" -ErrorAction SilentlyContinue) {
    Write-Host("Falcon Agent already installed, nothing to do.")
    exit 0
}
Write-Host("Falcon Agent not installed.")

Write-Host("Downloading Falcon Agent installer now.")
try {
    Invoke-WebRequest -Uri $installerURL -OutFile $installerTempLocation
}
catch {
    Write-Error("Unable to download Falcon Agent installer.".)
    exit 1
}
Write-Host("Finished downloading Falcon Agent installer.")

Write-Host("Installing Falcon Agent now, this may take a few minutes.")
try {
    $args = @("/install","/quiet","/norestart","CID=$CID") 
    $installerProcess = Start-Process -FilePath $installerTempLocation -Wait -PassThru -ArgumentList $args
}
catch {
    Write-Error("Failed to run Falcon Agent installer.")
    exit 1
}
Write-Host("Falcon Agent installer returned $($installerProcess.ExitCode).")

exit $installerProcess.ExitCode

```

#### Description

This command will download and install the CrowdStrike Falcon Agent to the device if it isn't already installed.  In order to use this command, you must know your Customer ID (CID) and have a valid download URL for the Falcon Agent Installer.

### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://TODO.UPDATE.ONCE.MERGED.INTO.MASTER'
```
