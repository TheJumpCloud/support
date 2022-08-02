#### Name

Windows - Install Remote Assist | v1.0 JCCG

#### commandType

windows

#### Command

```
$installerURL="https://cdn.awsstg.jumpcloud.com/TheJumpCloud/jumpcloud-remote-assist-agent/latest/jumpcloud-assist-app.exe"
$JumpCloudThumbprint="7A4844FBF481047BEDBB7A8054069C50E449D355"
$installerTempLocation="C:\Windows\Temp\JumpCloudRemoteAssistInstaller.exe"

Write-Host "Downloading JumpCloud Remote Assist installer now."
try {
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -Uri $installerURL -OutFile $installerTempLocation
}
catch {
    Write-Error "Unable to download JumpCloud Remote Assist installer."
    exit 1
}
Write-Host "Finished downloading JumpCloud Remote Assist installer."

try {
    Write-Host "Verifying Authenticode Signature"
    $authenticode = Get-AuthenticodeSignature "$installerTempLocation"
    if ( $authenticode.Status -ne "Valid" )
    {
        Write-Error "No valid Authenticode signature found, aborting installation"
        exit 1
    }

    if ( $authenticode.SignerCertificate.Thumbprint -ne $JumpCloudThumbprint )
    {
        Write-Error "No valid Authenticode signature found, aborting installation"
        exit 1
    }

    try {
        Get-Process "JumpCloud Assist App" -ErrorAction Stop | Stop-Process
    }
    catch [Microsoft.PowerShell.Commands.ProcessCommandException] {
        # Not a problem if the app isn't already running
    }
    catch {
        Write-Error "Failed to stop the running JumpCloud Remote Assist App."
        exit 1
    }

    Write-Host "Installing JumpCloud Remote Assist now, this may take a few minutes."
    try {
        $installerProcess = Start-Process -FilePath $installerTempLocation -Wait -PassThru
    }
    catch {
        Write-Error "Failed to run JumpCloud Remote Assist installer."
        exit 1
    }

    Write-Host "JumpCloud Remote Assist installer returned $($installerProcess.ExitCode)."

    exit $installerProcess.ExitCode
}
finally {
    Remove-Item "$installerTempLocation"
}
```

#### Description

This command will download and install the JumpCloud Remote Assist app on a Windows device.

### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'TODO'
```
