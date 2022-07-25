#### Name

Windows - Software Restriction Policy | v1.0 JCCG

#### commandType

windows

#### Command

```
$RestrictedDirectory = @("%UserProfile%\Downloads\", "C:\Windows\Temp\")
$ExecutableTypes = @("ADE","ADP","BAS","BAT","CHM","CMD","COM","CPL","CRT","EXE","HLP","HTA","INF","INS","ISP","LNK","MDB","MDE","MSC","MSI","MSP","MST","OCX","PCD","PIF","REG","SCR","SHS","URL","VB","WSC")

if((Test-Path -LiteralPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer") -eq $true) {Remove-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer" -Recurse};
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer";
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers";
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers\0";
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers\0\Paths";
New-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers' -Name 'authenticodeenabled' -Value 0 -PropertyType DWord;
New-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers' -Name 'DefaultLevel' -Value 262144 -PropertyType DWord;
New-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers' -Name 'TransparentEnabled' -Value 1 -PropertyType DWord;
New-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers' -Name 'PolicyScope' -Value 0 -PropertyType DWord;
New-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers' -Name 'ExecutableTypes' -Value $ExecutableTypes -PropertyType MultiString;

foreach ($Directory in $RestrictedDirectory){
    $pathguid = [guid]::newguid()
    $newpathkey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers\0\Paths\{" + $pathguid + "}"
    if((Test-Path -LiteralPath $newpathkey) -ne $true) {New-Item $newpathkey};
    New-ItemProperty -LiteralPath $newpathkey -Name 'SaferFlags' -Value 0 -PropertyType DWord;
    New-ItemProperty -LiteralPath $newpathkey -Name 'ItemData' -Value $Directory -PropertyType ExpandString;
}
```

#### Description

Adds a software restriction policy to windows. This policy will restrict the execution of any matching file type in the restricted directory.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/Windows%20Commands/Windows%20-%20Software%20Restriction%20Policy.md"
```
