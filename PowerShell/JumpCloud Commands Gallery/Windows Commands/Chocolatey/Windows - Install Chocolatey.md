#### Name

Windows - Install Chocolatey | v1.0 JCCG

#### commandType

windows

#### Command

```
# Install Chocolatey

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Schedules JumpCloud Agent Restart (Required post Chocolatey install)

## Checks to see if the directory on local computer exists for JumpCloud Scheduled Tasks
if ( -not (Test-Path -path "C:\Windows\Temp\JC_ScheduledTasks"))
{
    New-Item -Path "C:\Windows\Temp\JC_ScheduledTasks" -ItemType directory
}

## Creates Agent restart script file
$FileDate = Get-Date -Format FileDateTime
$FileName = "JC_ScheduledWAgentRestart$FileDate.ps1"
$TaskName = "JC_ScheduledWAgentRestart$FileDate"
$FilePath = "C:\Windows\Temp\JC_ScheduledTasks\"

$FileContents = @"

    Stop-Service jumpcloud-agent -force
    Start-Sleep -Seconds 1
    Start-Service jumpcloud-agent
    SCHTASKS /Delete /tn "$TaskName" /F
    Remove-Item -LiteralPath `$MyInvocation.MyCommand.Path -Force

"@

New-Item -Path $FilePath -Name $FileName  -ItemType "file" -Value $FileContents

## Schedules task to run in 1 minute
$RunTime = (Get-Date).AddMinutes(1) | Get-Date -UFormat %R
SCHTASKS /create /tn "$TaskName" /tr "powershell.exe -noprofile -executionpolicy Unrestricted -file $FilePath$FileName" /sc ONCE /st $RunTime /RU "NT AUTHORITY\SYSTEM"
```

#### Description

Installs Chocolatey on a Windows system and then restarts the JumpCloud agent via a scheduled task. Prior to running any `choco install` commands from JumpCloud, the JumpCloud agent must be restarted. This schedule task runs 1 minute after Chocolatey install and the choco commands will not be available via JumpCloud commands until this task executes. After the task runs it deletes itself and cleans up the files.  This installs Chocolatey with the default options. For additional configuration, please see [here](https://chocolatey.org/docs/chocolatey-configuration#proxy).

System requirements:
- Windows 7+ / Windows Server 2003+
- PowerShell v2+
- .NET Framework 4+ (the installation will attempt to install .NET 4.0 if you do not have it installed)

For more information, see [here](https://chocolatey.org/install).

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/Je0G5'
```
