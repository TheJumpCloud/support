#### Name

Windows - Install Remote Assist | v1.0 JCCG

#### commandType

windows

#### Command

```
$uninstallerPath="C:\Program Files\JumpCloud\Jumpcloud Assist App\Uninstall Jumpcloud Assist App.exe"
$installerURL="https://cdn.jumpcloud.com/TheJumpCloud/jumpcloud-remote-assist-agent/latest/jumpcloud-remote-assist.exe"
$JumpCloudThumbprint="7A4844FBF481047BEDBB7A8054069C50E449D355"
$installerTempLocation=Join-Path $([System.IO.Path]::GetTempPath()) JumpCloudRemoteAssistInstaller.exe

Write-Host "Downloading JumpCloud Remote Assist installer"
try {
    [Net.ServicePointManager]::SecurityProtocol="Tls12,Tls13"
}
catch {
    Write-Host "Warning: TLS1.3 is not supported on this operating system, falling back to TLS1.2"
    [Net.ServicePointManager]::SecurityProtocol="Tls12"
}

try {
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -Uri $installerURL -OutFile $installerTempLocation
}
catch {
    Write-Error "Unable to download JumpCloud Remote Assist installer"
    Write-Error $_
    exit 1
}
Write-Host "Download complete"

if ( Test-Path $uninstallerPath ) {
    Write-Host "Uninstalling legacy JumpCloud Remote Assist at " $uninstallerPath
    try {
        $uninstallerProcess = Start-Process -FilePath $uninstallerPath -Wait -PassThru -ArgumentList "/S"
    }
    catch {
        Write-Error "Unable to uninstall legacy JumpCloud Remote Assist"
        Write-Error $_
        exit 1
    }
    Write-Host "Legacy JumpCloud Remote Assist uninstaller completed with exit code $($uninstallerProcess.ExitCode)"
}

try {
    Write-Host "Verifying installer signature"
    $authenticode = Get-AuthenticodeSignature "$installerTempLocation"
    if ( $authenticode.Status -ne "Valid" )
    {
        Write-Error "Installer lacks a valid signature, aborting installation"
        exit 1
    }

    if ( $authenticode.SignerCertificate.Thumbprint -ne $JumpCloudThumbprint )
    {
        Write-Error "Installer lacks a valid signature, aborting installation"
        exit 1
    }

    Write-Host "Installing JumpCloud Remote Assist"
    try {
        $installerProcess = Start-Process -FilePath $installerTempLocation -Wait -PassThru -ArgumentList "/S"
    }
    catch {
        Write-Error "Failed to run JumpCloud Remote Assist installer"
        Write-Error $_
        exit 1
    }

    Write-Host "JumpCloud Remote Assist installer completed with exit code $($installerProcess.ExitCode)"

    exit $installerProcess.ExitCode
}
finally {
    Remove-Item "$installerTempLocation"
}
```

#### Description

This command will download and install the JumpCloud Remote Assist app on a Windows device.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Install%20Remote%20Assist.md'
```
