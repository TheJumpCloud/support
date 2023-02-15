###
# Windows - Uninstall Remote Assist | v1.0 JCCG
#
# This command will remove the JumpCloud Remote Assist app on a Windows device.
##

$legacyUninstallerPath="C:\Program Files\JumpCloud\Jumpcloud Assist App\Uninstall Jumpcloud Assist App.exe"
$uninstallerPath="C:\Program Files\JumpCloud Remote Assist\Uninstall JumpCloud Remote Assist.exe"

if ( Test-Path $legacyUninstallerPath ) {
    Write-Host "Uninstalling legacy JumpCloud Remote Assist at " $legacyUninstallerPath
    try {
        $uninstallerProcess = Start-Process -FilePath $legacyUninstallerPath -Wait -PassThru -ArgumentList "/S"
    }
    catch {
        Write-Error "Unable to uninstall legacy JumpCloud Remote Assist"
        Write-Error $_
        exit 1
    }
    Write-Host "Legacy JumpCloud Remote Assist uninstaller completed with exit code $($uninstallerProcess.ExitCode)"
}

if ( Test-Path $uninstallerPath ) {
    Write-Host "Uninstalling JumpCloud Remote Assist at " $uninstallerPath
    try {
        $uninstallerProcess = Start-Process -FilePath $uninstallerPath -Wait -PassThru -ArgumentList "/S"
    }
    catch {
        Write-Error "Unable to uninstall JumpCloud Remote Assist"
        Write-Error $_
        exit 1
    }
    Write-Host "JumpCloud Remote Assist uninstaller completed with exit code $($uninstallerProcess.ExitCode)"
}