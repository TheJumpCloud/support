#### Name

Windows - Run Automatic Updates  | v1.0 JCCG

#### commandType

windows

#### Command

```
schtasks /run /I /tn "\JCWindowsUpdates"
```

#### Description

This command calls and runs the scheduled task named "\JCWindowsUpdates"

### Dependencies

This command can only be run after automatic updates are scheduled to be run under the task named "\JCWindowsUpdates".
Import and run the command [Windows - Schedule Automatic Updates](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20Updates/Windows%20-%20Schedule%20Automatic%20Updates.md) to configure this dependency. 

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-Windows-RunAutomaticUpdates'
```
#### Related Commands
