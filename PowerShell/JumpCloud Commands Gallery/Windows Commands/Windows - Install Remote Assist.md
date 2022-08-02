#### Name

Windows - Install Remote Assist | v1.0 JCCG

#### commandType

windows

#### Command

```
$installerURL="https://cdn.awsstg.jumpcloud.com/TheJumpCloud/jumpcloud-remote-assist-agent/latest/jumpcloud-assist-app.exe"

############### Do Not Edit Below This Line ###############

$JumpCloudThumbprint="7A4844FBF481047BEDBB7A8054069C50E449D355"
$installerTempLocation="C:\Windows\Temp\JumpCloudRemoteAssistInstaller.exe"

Write-Host "Downloading JumpCloud Remote Assist installer now."
try {
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
        Write-Host "No valid Authenticode signature found, aborting installation"
        exit 1
    }

    if ( $authenticode.SignerCertificate.Thumbprint -ne $JumpCloudThumbprint )
    {
        Write-Host "No valid Authenticode signature found, aborting installation"
        exit 1
    }

    Write-Host "Installing JumpCloud Remote Assist now, this may take a few minutes."
    try {
        $installerProcess = Start-Process -FilePath $installerTempLocation -Wait
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
