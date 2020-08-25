#### Name

Windows - Set Agent Log Level to Default | v1.0 JCCG

#### commandType

Windows

#### Command

```
#Find jcagent install path
$configfiledefault = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\JumpCloud\JumpCloud Agent\ConfigFile\').'(default)'
$index = ($configfiledefault).IndexOf("Plugins")
$jcinstallpath = $default.Substring(0,$index)
#Remove loglevel.cache if exists
Remove-Item $jcinstallpath'Loglevel.cache' -ea ig

#Schedules JumpCloud Agent Restart
if ( -not (Test-Path -path "C:\Windows\Temp\JC_ScheduledTasks"))
{
    New-Item -Path "C:\Windows\Temp\JC_ScheduledTasks" -ItemType directory
}

#Creates Agent restart script file
$FileDate = (get-date -f yyyy-MM-dd-hh-mm)
$FileName = "JC_ScheduledWAgentRestart$FileDate.ps1"
$TaskName = "JC_ScheduledWAgentRestart$FileDate"
$FilePath = "C:\Windows\Temp\JC_ScheduledTasks\"
$FileContents = @"
    Stop-Service jumpcloud-agent -force
    Rename-Item -Path "C:\Windows\Temp\jcagent.log" -NewName "jcagent_$FileDate.log"
    Start-Sleep -Seconds 1
    Start-Service jumpcloud-agent
    SCHTASKS /Delete /tn "$TaskName" /F
    #Remove-Item -LiteralPath `$MyInvocation.MyCommand.Path -Force
"@
New-Item -Path $FilePath -Name $FileName  -ItemType "file" -Value $FileContents

## Schedules task to run in 30s
$RunTime = (Get-Date).AddSeconds(30) | Get-Date -UFormat %R
SCHTASKS /create /tn "$TaskName" /tr "powershell.exe -noprofile -executionpolicy Unrestricted -file $FilePath$FileName" /sc ONCE /st $RunTime /RU "NT AUTHORITY\SYSTEM"
```

#### Description

This command will set the JumpCloud Agent Log Level to Debug level. The Agent Log Level can also be set to Trace by changing the $loglevel variable from "DEBUG" to "TRACE". After the command is run, a shcheduled task triggers a second script that sets the Log Level, restarts the JumpCloud Agent and removes the itself.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-Win-Pulljcagent.log'
```
