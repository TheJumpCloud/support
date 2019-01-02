#### Name

Windows - Exclude JCAgent from Windows Defender | v1.0 JCCG

#### commandType

windows

#### Command

```
$64BitCommand = "Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\JumpCloud\jumpcloud-agent.exe'"

& (Join-Path ($PSHOME -replace 'syswow64', 'sysnative') powershell.exe) -Command "& {$64BitCommand}"
```

#### Description

This command will remove the jumpcloud-agent.exe from Windows Defender scheduled and real-time scanning.

The command Add-MpPreference is only available in the 64-bit environment and the JumpCloud agent operates in the 32-bit environment which is why sysnative is used.

### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-windows-excludejcagentfromwindowsdefender'
```
