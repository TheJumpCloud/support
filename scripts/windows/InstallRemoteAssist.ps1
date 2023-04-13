###
# Windows - Install Remote Assist | v1.0 JCCG
#
# This command will download and install the JumpCloud Remote Assist app on a Windows device.
##

$uninstallerPath="C:\Program Files\JumpCloud\Jumpcloud Assist App\Uninstall Jumpcloud Assist App.exe"
$installerURL="https://cdn02.jumpcloud.com/production/jumpcloud-remote-assist-agent.exe"
$JumpCloudThumbprint="B6ACC0000E31294E175A27509975131032B6A073"
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
