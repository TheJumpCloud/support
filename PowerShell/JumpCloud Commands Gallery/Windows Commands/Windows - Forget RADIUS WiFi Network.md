#### Name

Windows - Forget RADIUS WiFi Network | v1.0 JCCG


#### commandType

windows

#### Command

```
# Enter the SSID of the Radius network
$RadiusSSID = ''

# Change Overwrite to $true if you would like to re-create existing Scheduled Tasks
# This should only be used if redistributing this command to devices
$Overwrite = $false


# DO NOT EDIT BELOW THIS LINE #
$removeWifips1 = @"
function Get-WifiProfile {
    [cmdletbinding()]
    param
    (
         [System.Array]`$Name = `$NULL
    )
    Begin {
        `$list = ((netsh.exe wlan show profiles) -match '\s{2,}:\s') -replace '.*:\s' , ''
        `$ProfileList = `$List | Foreach-object { [pscustomobject]@{Name = `$_ } }
    }
    Process {
         Foreach (`$WLANProfile in `$Name) {
            `$ProfileList | Where-Object { `$_.Name -match `$WLANProfile }
         }

    }
    End {
         If (`$Name -eq `$NULL) {
            `$Profilelist
         }
    }
}
function Remove-WifiProfile {
    [cmdletbinding()]
    param
    (
         [System.Array]`$Name = `$NULL
    )
    begin {}
    process {
         Foreach (`$item in `$Name) {
            `$Result = (netsh.exe wlan delete profile `$item)
              If (`$Result -match 'deleted') {
                   "WifiProfile : `$Item Deleted"
              } else {
                   "WifiProfile : `$Item NotFound"
              }
         }
    }
}

Remove-WifiProfile "$($RadiusSSID)"
"@
function Distribute-JCScheduledTask {
    param (
        [boolean]$Overwrite
    )
    # Get Current User for JC Commmand
    $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    # Scheduled Task XML Configuration
    $ScheduledTaskXML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Settings>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
  </Settings>
  <Triggers>
    <EventTrigger>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-WLAN-AutoConfig/Operational"&gt;&lt;Select Path="Microsoft-Windows-WLAN-AutoConfig/Operational"&gt;*[System[Provider[@Name='Microsoft-Windows-WLAN-AutoConfig'] and Task = 24010 and (EventID=8002)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Actions Context="Author">
    <Exec>
      <Command>"C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"</Command>
      <Arguments>-ExecutionPolicy ByPass -File "C:\scripts\removeWifi.ps1"</Arguments>
    </Exec>
  </Actions>
</Task>
"@
    # Check if the scheduled task exists, skip unless Overwrite is specified
    $scheduledTask = Get-ScheduledTask -TaskName "JumpCloud - Remove WiFi Failure" -ErrorAction SilentlyContinue
    if ($scheduledTask) {
        Write-Output "[status] JumpCloud - Remove WiFi Failure scheduled task already exists"
        if ($Overwrite) {
            # Save the removeWifi.ps1 file to C:\scripts\removeWifi.ps1
            if (!(Test-Path -Path C:\scripts)) {
                New-Item -Path "C:\" -Name "scripts" -ItemType "directory"
            }
            $removeWifips1 | Out-File -FilePath C:\scripts\removeWifi.ps1 -force
            # Overwrite specified, unregister existing task and recreate
            Unregister-ScheduledTask -TaskPath '\JumpCloud RADIUS\' -TaskName 'JumpCloud - Remove Wifi Failure' -Confirm:$false
            Write-Output "[status] Removed existing 'JumpCloud - Remove WiFi Failure' Scheduled Task"
            Register-ScheduledTask -xml $ScheduledTaskXML -TaskName "JumpCloud - Remove WiFi Failure" -TaskPath "\JumpCloud RADIUS\" -User $CurrentUser –Force
            Write-Output "[status] Distributed 'JumpCloud - Remove WiFi Failure' Scheduled Task"
        }
    } else {
        # Save the removeWifi.ps1 file to C:\scripts\removeWifi.ps1
        if (!(Test-Path -Path C:\scripts)) {
            New-Item -Path "C:\" -Name "scripts" -ItemType "directory"
        }
        $removeWifips1 | Out-File -FilePath C:\scripts\removeWifi.ps1
        # Create the Scheduled Task
        Register-ScheduledTask -xml $ScheduledTaskXML -TaskName "JumpCloud - Remove WiFi Failure" -TaskPath "\JumpCloud RADIUS\" -User $CurrentUser –Force
        Write-Output "[status] Distributed 'JumpCloud - Remove WiFi Failure' Scheduled Task"
    }
}
Distribute-JCScheduledTask -Overwrite $Overwrite
```

#### Description

The purpose of this script is to resolve an issue when a user changes their JumpCloud password after connecting to a JumpCloud backed Radius network they will never be able to connect unless they forget the existing network.

In order to accomplish this, the command will create a scheduled task on the workstation that looks for 8002 errors when attempting to connect to the specified Radius SSID. If an error is detected, a PowerShell script will be initiated that will forget the network for the user which will allow them to attempt to connect again and prompt for their updated credentials


#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Forget%20RADIUS%20WiFi%20Network.md"