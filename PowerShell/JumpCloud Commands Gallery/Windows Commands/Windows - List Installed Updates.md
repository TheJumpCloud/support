#### Name

Windows - List Installed Updates | v1.0 JCCG


#### commandType

windows

#### Command

```
get-hotfix | Format-Table -wrap
```

#### Description

The Get-Hotfix cmdlet gets hotfixes (also called updates) that have been installed by Windows Update, Microsoft Update, or Windows Server Update Services; the command also gets hotfixes or updates that have been installed manually by users.

The Get-Hotfix command is only avaliable on Windows machines running PowerShell version 5 or greater. If you're unsure of the PowerShell version on your windows machines see the [Windows - Get Installed PowerShell version.md](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Get%20Installed%20PowerShell%20version.md) command

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-Windows-ListInstalledUpdates'
```
