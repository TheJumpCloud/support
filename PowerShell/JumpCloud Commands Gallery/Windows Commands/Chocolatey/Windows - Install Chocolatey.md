#### Name

Windows - Install Chocolatey | v1.0 JCCG

#### commandType

windows

#### Command

```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

#### Description

Installs Chocolatey on a Windows system. Prior to running any `choco install` commands from JumpCloud, the system must be rebooted or the PowerShell environment refreshed. This installs Chocolatey with the default options. For additional configuration, please see [here](https://chocolatey.org/docs/chocolatey-configuration#proxy).

System requirements:
- Windows 7+ / Windows Server 2003+
- PowerShell v2+
- .NET Framework 4+ (the installation will attempt to install .NET 4.0 if you do not have it installed)

For more information, see [here](https://chocolatey.org/install).

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL {{Create importable link using git.io after uploaded command to repo (This is just a URL shortener)}}
```
