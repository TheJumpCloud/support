#### Name

Windows - Remove Extra Bitlocker Recovery Passwords | v1.0 JCCG

#### commandType

windows

#### Command

```powershell
function Get-OsVolumeLetter {
  return Get-WmiObject -Class Win32_OperatingSystem -Property SystemDrive | Select-Object -ExpandProperty SystemDrive
}

function Remove-NonMatchingBitLockerRecoveryPasswords {
  try {
    $osVolumeLetter = Get-OsVolumeLetter
    $bitLockerVolume = Get-BitLockerVolume -MountPoint $osVolumeLetter

    if(!$bitLockerVolume) {
      Write-Host "$osVolumeLetter Volume does not have an associated BitLocker volume."
      exit 1
    }

    $passwords = $bitLockerVolume.KeyProtector.Where({$_.KeyProtectorType -eq "RecoveryPassword"})

    if(!$passwords) {
      Write-Host "The System Drive $osVolumeLetter does not have an available Recovery Key."
      exit 1
    }

    $recoveryKey = $passwords[0].RecoveryPassword

    # Get all recovery keys that do not match the passed in key.
    $nonMatchingpswds = $bitLockerVolume.KeyProtector.Where({$_.RecoveryPassword -ne "$recoveryKey" -and $_.KeyProtectorType -eq "RecoveryPassword"})

    foreach($pswd in $nonMatchingpswds) {
      $recoveryPasswords = $bitLockerVolume.KeyProtector.Where({$_.KeyProtectorType -eq "RecoveryPassword"})
      $numPasswords = [int]$recoveryPasswords.count

      if($numPasswords -gt 1) {
        # Remove all non-matching keys.
        Remove-BitLockerKeyProtector -MountPoint $osVolumeLetter -KeyProtectorId $pswd.KeyProtectorId -ErrorAction Stop
      }
    }
  }
  catch {
    Write-Host "$_"
    exit 1
  }
}

Remove-NonMatchingBitLockerRecoveryPasswords
```

#### Description

WARNING: This script attempts to remove extra Bitlocker Recovery passwords. Ideal use of this script would be at a time when there is a low chance of the device rebooting.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Remove%20Extra%20Bitlocker%20Recovery%20Passwords.md"
```
