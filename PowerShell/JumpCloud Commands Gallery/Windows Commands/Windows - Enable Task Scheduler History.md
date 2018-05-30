#### Name

Windows - Enable Task Scheduler History  | v1.0 JCCG

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


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'Create and enter Git.io URL'
```
