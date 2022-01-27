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
    write-host("Falcon Agent already installed, nothing to do.")
    exit 0
}
write-host("Falcon Agent not installed.")

write-host("Downloading Falcon Agent installer now.")
try {
    $webClient = New-Object System.Net.WebClient 
    $webClient.DownloadFile($installerURL, $installerTempLocation)
}
catch [System.Net.WebException],[System.IO.IOException] {
    write-host("Unable to download Falcon Agent Installer")
    exit 1
}
catch {
    write-host("An unknown error occurred downloading the Falcon Agent Installer.")
    exit 1
}
write-host("Finished downloading Falcon Agent installer.")

write-host("Installing Falcon Agent now, this may take a few minutes.")
try {
    $args = @("/install","/quiet","/norestart","CID=$CID") 
    $installerProcess = Start-Process -FilePath $installerTempLocation -Wait -PassThru -ArgumentList $args
}
catch {
    write-error("Failed to run Falcon Agent installer.")
    exit 1
}
write-host("Falcon Agent installer returned $($installerProcess.ExitCode).")

exit $installerProcess.ExitCode

```

#### Description

This command will download and install the CrowdStrike Falcon Agent to the device if it isn't already installed.  In order to use this command, you must know your Customer ID (CID) and have a valid download URL for the Falcon Agent Installer.

### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://TODO.UPDATE.ONCE.MERGED.INTO.MASTER'
```
