#### Name

Windows - 64-Bit MultiLine Command | v1.0 JCCG

#### commandType

windows

#### Command

```
## Enter your command within the @' '@
## Use single quotes ' not double quotes " for all variables 
## Example multi-line command below

$64BitCommand = @'
$Hello = 'Howdy'
$World = 'World'
Write-Host "Well $Hello $World"
'@

#------ Do not modify below this line ---------------
& (Join-Path ($PSHOME -replace 'syswow64', 'sysnative') powershell.exe) -Command "& {$64BitCommand}"
```

#### Description

A template to use to execute a multiline PowerShell command in the 64-bit environment. By default, all JumpCloud PowerShell commands are executed in the 32-bit PowerShell environment. Some commands are only available for execution in the 64-bit environment. 

To determine if a command is 32 or 64-bit discovery can be done using the command Get-Command to find the module that a command is loaded in and then checking for that command in a 32-bit session.

The command Get-LocalUser is only available in the 64-bit environment.

We can see this by using the Get-Command function and passing in the Get-LocalUser command.

Example 
```PowerShell
Get-Command Get-LocalUser

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Cmdlet          Get-LocalUser                                      1.0.0.0    Microsoft.PowerShell.LocalAccounts

```
The Get-LocalUser command shows the source of the Get-LocalUser command is the **Microsoft.PowerShell.LocalAccounts** module.

When running Get-Module in the 32-bit environment, the output reveals that this module is not loaded and therefore any of the commands within the module are not accessible.

Example from **32-bit shell:**
```PowerShell
Get-Module | Select-Object ModuleType, Version, Name

ModuleType Version Name
---------- ------- ----
  Manifest 3.1.0.0 Microsoft.PowerShell.Management
  Manifest 3.1.0.0 Microsoft.PowerShell.Utility

```

When running the Get-Module command in the 64-bit environment we can see the **Microsoft.PowerShell.LocalAccounts**. 

Example from **64-bit shell:**
```PowerShell
Get-Module | Select-Object ModuleType, Version, Name

ModuleType Version        Name
---------- -------        ----
    Binary 1.0.0.0        Microsoft.PowerShell.LocalAccounts
  Manifest 3.1.0.0        Microsoft.PowerShell.Management
  Manifest 3.1.0.0        Microsoft.PowerShell.Utility
```

This demonstrates why the Get-LoacalUser command must be called in a 64-bit environment as templated above by using the [sysnative folder](http://www.samlogic.net/articles/sysnative-folder-64-bit-windows.htm). 

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-windows-64-bitmultilinecommand'
```
