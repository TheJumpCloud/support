#### Name

Windows - Schedule Automatic Updates  | v1.0 JCCG

#### commandType

windows

#### Command

```
## Schedules update script to run daily at 9 am under the task name "JC Windows Updates" log
 
## The log file named "JC_WinUpdate_Report_`$Env:ComputerName_`$DateStamp.txt" will be located within folder "C:\Windows\Temp\JC_ScheduledTasks"

## Change "09:00" to the time you wish to schedule the updates to run
## Times are in the systems local time

$RunTime = "09:00"

## Checks to see if the directory on local computer exists for JumpCloud Scheduled Tasks

if ( -not (Test-Path -path "C:\Windows\Temp\JC_ScheduledTasks"))
{
    New-Item -Path "C:\Windows\Temp\JC_ScheduledTasks" -ItemType directory
}


$FileName = 'JC_ScheduledWindowsUpdate.ps1'
$FilePath = "C:\Windows\Temp\JC_ScheduledTasks\"

# Here string with contents of the script for Windows Updates with logging

$FileContents = @"

`$ErrorActionPreference = "SilentlyContinue"
If (`$Error)
{
    `$Error.Clear()
}
`$Today = Get-Date
`$DateStamp = Get-Date -Format MMddyyTHHmmss


`$UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
`$Searcher = New-Object -ComObject Microsoft.Update.Searcher
`$Session = New-Object -ComObject Microsoft.Update.Session

`$Result = `$Searcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")

If (`$Result.Updates.Count -EQ 0)
{
    Write-Output "`t There are no applicable updates for this computer."
}
Else
{
    `$ReportFileName = "JC_WinUpdate_Report_`$Env:ComputerName_`$DateStamp.txt"
    `$ReportFile = "C:\Windows\Temp\JC_ScheduledTasks\`$ReportFileName" 
    New-Item `$ReportFile -Type File -Force -Value "Windows Update Report For Computer: `$Env:ComputerName`r`n" | Out-Null
    Add-Content `$ReportFile "Report Created On: `$Today`r"
    Add-Content `$ReportFile "==============================================================================`r`n"
    Add-Content `$ReportFile "List of Applicable Updates For This Computer`r"
    Add-Content `$ReportFile "------------------------------------------------`r"
    For (`$Counter = 0; `$Counter -LT `$Result.Updates.Count; `$Counter++)
    {
        `$DisplayCount = `$Counter + 1
        `$Update = `$Result.Updates.Item(`$Counter)
        `$UpdateTitle = `$Update.Title
        Add-Content `$ReportFile "`t `$DisplayCount -- `$UpdateTitle"
    }
    `$Counter = 0
    `$DisplayCount = 0
    Add-Content `$ReportFile "`r`n"
    Add-Content `$ReportFile "Initializing Download of Applicable Updates"
    Add-Content `$ReportFile "------------------------------------------------`r"
    `$Downloader = `$Session.CreateUpdateDownloader()
    `$UpdatesList = `$Result.Updates
    For (`$Counter = 0; `$Counter -LT `$Result.Updates.Count; `$Counter++)
    {
        `$UpdateCollection.Add(`$UpdatesList.Item(`$Counter)) | Out-Null
        `$ShowThis = `$UpdatesList.Item(`$Counter).Title
        `$DisplayCount = `$Counter + 1
        Add-Content `$ReportFile "`t `$DisplayCount -- Downloading Update `$ShowThis `r"
        `$Downloader.Updates = `$UpdateCollection
        `$Track = `$Downloader.Download()
        If ((`$Track.HResult -EQ 0) -AND (`$Track.ResultCode -EQ 2))
        {
            Add-Content `$ReportFile "`t Download Status: SUCCESS"
        }
        Else
        {
            Add-Content `$ReportFile "`t Download Status: FAILED With Error -- `$Error()"
            `$Error.Clear()
            Add-content `$ReportFile "`r"
        }	
    }
    `$Counter = 0
    `$DisplayCount = 0
    Add-Content `$ReportFile "`r`n"
    Add-Content `$ReportFile "Installation of Downloaded Updates"
    Add-Content `$ReportFile "------------------------------------------------`r"
    `$Installer = New-Object -ComObject Microsoft.Update.Installer
    For (`$Counter = 0; `$Counter -LT `$UpdateCollection.Count; `$Counter++)
    {
        `$Track = `$Null
        `$DisplayCount = `$Counter + 1
        `$WriteThis = `$UpdateCollection.Item(`$Counter).Title
        Add-Content `$ReportFile "`t `$DisplayCount -- Installing Update: `$WriteThis"
        `$Installer.Updates = `$UpdateCollection
        Try
        {
            `$Track = `$Installer.Install()
            Add-Content `$ReportFile "`t Update Installation Status: SUCCESS"
        }
        Catch
        {
            [System.Exception]
            Add-Content `$ReportFile "`t Update Installation Status: FAILED With Error -- `$Error()"
            `$Error.Clear()
            Add-content `$ReportFile "`r"
        }	
    }
}
"@ 

# Creates Windows Update Script file

New-Item -Path $FilePath -Name $FileName  -ItemType "file" -Value $FileContents

# Schedules update script to run daily at 9 am under the name "JC Windows Updates" log file named "JC_WinUpdate_Report_`$Env:ComputerName_`$DateStamp.txt" will be located within folder "C:\Windows\Temp\JC_ScheduledTasks"

SCHTASKS /create /tn "JCWindowsUpdates" /tr "powershell.exe -noprofile -executionpolicy Unrestricted -file $FilePath$FileName" /sc DAILY /st $RunTime /RU "NT AUTHORITY\SYSTEM"


```

#### Description

This commands places the "JC_ScheduledWindowsUpdate.ps1" script file on the target system in the  "C:\Windows\Temp\JC_ScheduledTasks\" directory.
This script file when called downloads and installs available windows updates and leaves a log file on the system which contains the results of the downloaded and installed updates.
A scheduled task is configured using SCHTASKS to call the "JC_ScheduledWindowsUpdate.ps1" to invoke Windows Updates daily at the $RunTime specified.
The default $RunTime is set to 9 am local time.
By modifying the $RunTime this command can be configured to schedule the automatic updates at the JumpCloud admins preference.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/jccg-Windows-ScheduleAutomaticUpdates'
```

#### Related Commands
