#### Name

Windows - Get Windows Defender Exclusions | v1.0 JCCG

#### commandType

windows

#### Command

```
$64BitCommand = "Get-MpPreference"

& (Join-Path ($PSHOME -replace 'syswow64', 'sysnative') powershell.exe) -Command "& {$64BitCommand}"
```

#### Description

This command will return the Window Defender Exclusion settings

The command Get-MpPreference is only available in the 64-bit environment and the JumpCloud agent operates in the 32-bit environment which is why sysnative is used.

### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-windows-getwindowsdefenderexclusions'
```
