#### Name

Windows - Remove Extra Bitlocker Recovery Passwords | v1.0 JCCG

#### commandType

windows

#### Command

```powershell
# Set this variable to the password recovery key to PRESERVE.  All keys other than this key will be deleted.
$RecoveryKey = 'RECOVERY KEY TO PRESERVE'

function Get-OsVolumeLetter {
  return Get-WmiObject -Class Win32_OperatingSystem -Property SystemDrive | Select-Object -ExpandProperty SystemDrive
}

function Remove-NonMatchingBitLockerRecoveryPasswords {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNull()]
    [string] $RecoveryKey
  )

  try {
    $osVolumeLetter = Get-OsVolumeLetter
    $bitLockerVolume = Get-BitLockerVolume -MountPoint $osVolumeLetter

    if(!$bitLockerVolume) {
      Write-Host "$osVolumeLetter Volume does not have an associated BitLocker volume."
      exit 1
    }

    # Find key that matches the passed in key.
    $matchingpswd = $bitLockerVolume.KeyProtector.Where({$_.RecoveryPassword -eq "$RecoveryKey" -and $_.KeyProtectorType -eq "RecoveryPassword"})

    if(!$matchingpswd) {
      Write-Host "$osVolumeLetter Volume does not have the following password: $RecoveryKey"
      exit 1
    }

    # Get all recovery keys that do not match the passed in key.
    $nonMatchingpswds = $bitLockerVolume.KeyProtector.Where({$_.RecoveryPassword -ne "$RecoveryKey" -and $_.KeyProtectorType -eq "RecoveryPassword"})

    foreach($pswd in $nonMatchingpswds) {
      # Remove all non-matching keys.
      Remove-BitLockerKeyProtector -MountPoint $osVolumeLetter -KeyProtectorId $pswd.KeyProtectorId -ErrorAction Stop
    }
  }
  catch {
    Write-Host "$_"
    exit 1
  }
}

Remove-NonMatchingBitLockerRecoveryPasswords $RecoveryKey
```

#### Description

WARNING: Incorrect usage of this command can result in unintended Recovery Passwords being removed and the drive potentially unusable.

This command removes extra Bitlocker Recovery Passwords. The $RecoveryKey variable must be set to the recovery password that is to be PRESERVED.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Remove%20Extra%20Bitlocker%20Recovery%20Passwords.md"
```
