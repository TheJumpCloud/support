#### Name

Windows - Enable Task Scheduler History | v1.0 JCCG

#### commandType

windows

#### Command

```
## Enables the windows event log for the task scheduler
## Equivalent to checking the box "Enable All Task History" within task scheduler

$TaskScheduler = 'Microsoft-Windows-TaskScheduler/Operational'
$TaskSchedulerLog = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $TaskScheduler
$TaskSchedulerLog.IsEnabled = $true
$TaskSchedulerLog.SaveChanges()
```

#### Description

This command will enable windows task schedule history on remote systems.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Enable%20Task%20Scheduler%20History.md"
```
