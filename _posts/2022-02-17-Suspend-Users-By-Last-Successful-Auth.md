---
layout: post
title: Suspend Users By Last Successful Authentication
description: Users are suspended based off of the time they last successfully authenticated
tags:
  - powershell
  - automation
  - users
  - authentication
---

To suspend users by their last known successful authentication we first need to know some data about the users. Directory Insights data contains infomration about a users last known authentication time. The `Get-JcLoginEvent` function is a streamlined function to help query users who have completed a successful authentication within a defined time period. This function returns a user's last known sucessful "radius_auth", "sso_auth", "login_attempt", "ldap_bind" and/or "user_login_attempt".

The `Suspend-InactiveUsers` function will suspend users who's last timestamp is greater (older) than the `daysSinceLogin` parameter (or if they have no known last authentication time)

Data is first gathered about users through the `Get-JcLoginEvent` function and then passed to `Suspend-InactiveUsers` if we want to suspend users from an organization.

### Running the function on a cadence

The function can be run on a cadence through a cron job or scheduled task to meet compliance. To invoke the function, first connect to a JumpCloud org with `Connect-JCOnline`

ex:

```powershell
function Suspend-InactiveUsers{
    ... # function contents
}
Connect-JCOnline -JumpCloudApiKey:("jsdaf892370asdfkljfdaslkjjsdaf892370asdf")
Get-JcLoginEvent -CsvPath:("~/suspension/authnticationTimestamps.csv") -StartDate((Get-Date).AddDays(-30))
Suspend-InactiveUsers -CsvPath:("~/suspension/authnticationTimestamps.csv") -DaysSinceLogin:(30) -ExcludeAttribute:('serviceAccount')
```

To enable all users who've been disabled:

```powershell
$users = Get-JCsdkUser
foreach ($user in $users) {
    $output = Set-JcSdkUser -id $user.Id -State "ACTIVATED"
}
```

### Suspend-InactiveUsers Function

The `Suspend-InactiveUsers` function will suspend users who have not successfully authenticated to a JumpCloud service between the current date and the date set when calling the function.

This function takes the CSV generated from `Get-JCLoginEvent` and suspends users who's last known login date is `DaysSinceLogin` (days) older than the date generated and saved in the `jc-login-suspend-last-run.txt` file.'

The following parameters can be used with this fucntion: `ReadOnly`, `CsvPath`, `ExcludeAttribute` and `DaysSinceLogin`

`ReadOnly` can be set to `$true`. Setting the parameter to true will will query users and print the users that would be suspended if the parameter was not set - this can be helpful for testing.

`CsvPath` should be set to the path of the .csv file generated from the `Get-JCLoginEvent` function

`ExcludeAttribute` can be set to a string. When this parameter is set the function will search users with custom attributes. If the name of a user's custom attribute matches the parameter and the value of that parameter is `true` then the user will be excluded from suspension. Ex. Setting `ExcludeAttribute` to `serviceAccount` will query users with the custom attribute name `serviceAccount` and value `true` if any users are found to match that custom attribute, they will be excluded from the list of suspended users even if they have not authenticated to a service in the `filterDate` window.

`DaysSinceLogin` is the integer value to query user known login times against. The number of days set in this parameter are used to generate the date which determines suspension. The suspension date threshold is the date generated in the `jc-login-suspend-last-run.txt` file subtracted by the number of days set in this parameter. For example. If the `Get-JCLoginEvent` function was ran at Friday, August 6th, 2021 at 12:30:00 pm and the `DaysSinceLogin` parameter was set to 30, users who have not authenticated after Wednesday, July 7, 2021 at 12:30:00 pm would be suspended.



## Script

```powershell
function Get-JcLoginEvent
{
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Set to true to print the number of users who would have been suspend, this will not suspend users")]
        [switch]
        $ReadOnly = $false,
        [Parameter(Mandatory = $true, HelpMessage = "Path to the CSV file. If no such CSV file exists, it will be created. If the CSV file does exist, it will be updated.")]
        [string]
        $CsvPath,
        [Parameter(Mandatory = $true, HelpMessage = "The DateTime value to begin filtering between. ex. (Get-Date.AddDays(-30)) ")]
        [datetime]
        $StartDate,
        [Parameter(Mandatory = $false, HelpMessage = "The DateTime value to end filtering between. Default: Get-Date (current date). ex. (Get-Date.AddDays(-30)) ")]
        [datetime]
        $EndDate
    )
    begin
    {
        # Write date of last execution to a file
        $CsvDirectory = Split-Path $CsvPath
        if ( [System.String]::IsNullOrEmpty($EndDate) )
        {
            $EndDate = Get-Date
        }
        New-Item -Path $CsvDirectory -Name "jc-login-suspend-last-run.txt" -Value $EndDate -Force

        # Check if CSV exists. If it does not, create an empty one.
        If (Test-Path -Path $CsvPath -PathType Leaf)
        {
            Write-Debug "File found at location: $($CsvPath)."
            [System.Collections.ArrayList]$CsvData = Import-Csv -Path $CsvPath
        }
        Else
        {
            Write-Debug "No file found at location: $($CsvPath). Creating file."
            [System.Collections.ArrayList]$CsvData = @()
        }

        $UserList = Get-JcSdkUser

        $DaysPerSpan = .5
        $Span = New-TimeSpan -Start $StartDate -End $EndDate

        $Spans = @()
        for ($i = 0; $i -lt $Span.Days; $i += ($DaysPerSpan))
        {
            $LoopStart = ($StartDate).AddDays($i)
            $LoopEnd = ($StartDate).AddDays($i + $DaysPerSpan)
            If ($LoopEnd -gt $EndDate)
            {
                $LoopEnd = $EndDate
            }
            $Spans += New-Object psobject -Property @{StartDate = $LoopStart; EndDate = $LoopEnd }
        }
        Write-Debug "$($Spans.Count) day interval(s) will be queried"
    }
    process
    {
        # Gather Directory Insights Data
        $EventTypes = (
            "radius_auth",
            "sso_auth",
            "login_attempt",
            "ldap_bind",
            "user_login_attempt"
        )
        $FilterFields = @(
            "success",
            "initiated_by",
            "event_type",
            "timestamp"
        )
        Write-Debug "Collecting Directory Insights data for the following event types: $($EventTypes). This may take a moment."
        #$DirectoryInsightsData = Get-JcSdkEvent -Service all -StartTime $StartDate -SearchTermOr @{ "event_type" = $EventTypes }

        $stopwatch = [system.diagnostics.stopwatch]::StartNew()
        $ObjectJobs = @()
        foreach ($span in $spans)
        {
            $Count = Get-JCEventCount -Service:('all') -StartTime:($($span.StartDate)) -endTime:($($span.EndDate)) -SearchTermOr @{ "event_type" = $EventTypes }
            if ($Count -ge 1)
            {
                Write-Host "Returning $Count events between: $($span.StartDate) - $($span.EndDate)"
                $ObjectJobs += start-ThreadJob -ScriptBlock:( { Param ($EventTypes, $span, $FilterFields)
                        $ErrorActionPreference = 'Continue';
                        $Result = Get-JCSDKEvent -Service:('all') -StartTime:($($span.StartDate)) -endTime:($($span.EndDate)) -SearchTermOr @{ "event_type" = $EventTypes } -Fields:($FilterFields)
                        Return $Result
                    }) -ArgumentList:($EventTypes, $span, $FilterFields) -StreamingHost:($Host) -ThrottleLimit:(30)
            }
        }
        $ObjectJobStatus = Wait-Job -Id:($ObjectJobs.Id)
        if ('Failed' -in $ObjectJobStatus.State)
        {
            # if failures in the jobs report & exit:
            Write-Error "failed to query all data from Directory Insights"
        }
        $DirectoryInsightsData += $ObjectJobStatus | Where-Object { $_.state -eq 'Completed' } | Receive-Job
        $stopwatch.Stop()
        $totalSecs = [math]::Round($stopwatch.Elapsed.TotalSeconds, 0)
        Write-host "Events query took $totalSecs seconds to run"

        ForEach ( $Event in $DirectoryInsightsData | Where-Object { ($_.success -eq 'true') -or ($Event.event_type -eq 'sso_auth') } )
        {
            # Check if the Event Type is "login_attempt". These events do not have the "username" as an initiated_by attribute and id must be used instead.
            If ( $Event.event_type -in "login_attempt", "ldap_bind" )
            {
                # if username in current userlist
                If ( $Event.initiated_by.username -in $UserList.username )
                {
                    # idIndex returns username from $event
                    $IdIndex = $UserList.username.IndexOf($Event.initiated_by.username)
                    # if event username matches existing username already in csv
                    If ( $Event.initiated_by.username -in $CsvData.username )
                    {
                        # returns username from $event
                        $RowIndex = $CsvData.username.IndexOf($Event.initiated_by.username)
                        # update the timestamp for this user (latest auth)
                        $CsvData[$RowIndex].timestamp = $Event.timestamp
                    }
                    else
                    {
                        # if new user to the csv
                        $CsvData.Add(
                            [PSCustomObject]@{
                                id        = $UserList[$IdIndex].id;
                                username  = $Event.initiated_by.username;
                                timestamp = $Event.timestamp
                            }
                        ) | Out-Null
                    }
                }
            }
            else
            {
                If ( $Event.initiated_by.id -in $CsvData.id )
                {
                    $RowIndex = $CsvData.id.IndexOf($Event.initiated_by.id)
                    $CsvData[$RowIndex].timestamp = $event.timestamp
                }
                else
                {
                    $CsvData.Add(
                        [PSCustomObject]@{
                            id        = $Event.initiated_by.id;
                            username  = $Event.initiated_by.username;
                            timestamp = $Event.timestamp
                        }
                    ) | Out-Null
                }
            }
        }
    }
    end
    {
        if ( $ReadOnly )
        {
            $CsvData
        }
        else
        {
            $CsvData | Export-Csv $CsvPath
        }
    }
}

function Suspend-InactiveUsers
{
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Set to true to print the number of users who would have been suspend, this will not suspend users")]
        [switch]
        $ReadOnly = $false,
        [Parameter(Mandatory = $true, HelpMessage = "Path to the CSV file. If no such CSV file exists, it will be created. If the CSV file does exist, it will be updated.")]
        [string]
        $CsvPath,
        [Parameter(HelpMessage = "Custom Attribute to Filter against, if the value of this custom attribute is true, this user will be excluded from suspension")]
        [string]
        $ExcludeAttribute,
        [Parameter(Mandatory = $true, HelpMessage = "The integer value to filter between the current date ex. (30) ")]
        [int]
        $DaysSinceLogin
    )
    begin
    {
        $SuspendedList = [System.Collections.ArrayList]@()
        $CsvDirectory = Split-Path $CsvPath
        $LastRunTimePath = $CsvDirectory + "/jc-login-suspend-last-run.txt"
        If ( Test-Path -Path $LastRunTimePath -PathType Leaf )
        {
            $LastRunTime = ( Get-Date ( Get-Content $LastRunTimePath ) )
            $SuspendDate = $LastRunTime.AddDays(-$DaysSinceLogin)
            Write-Debug "Searching for user's who's last known login time occured before: $SuspendDate"
        }
        else
        {
            Write-Error "ERROR: Unable to locate file at location: $($LastRunTimePath)."
        }

        # Check if CSV exists. If it does not, error out.
        If (Test-Path -Path $CsvPath -PathType Leaf)
        {
            Write-Debug "File found at location: $($CsvPath)."
            [System.Collections.ArrayList]$CsvData = Import-Csv -Path $CsvPath
        }
        Else
        {
            Write-Error "ERROR: Unable to locate CSV at location: $($CsvPath)."
        }

        $UserList = Get-JcSdkUser
        if ($ExcludeAttribute)
        {
            $exclusionUsers = @()
            foreach ($user in $UserList)
            {
                if ($user.Attributes | Where-Object { $_.Name -eq $ExcludeAttribute -and $_.Value -eq 'true' })
                {
                    # if user has custom attribute name w/ true value add it to the exclusion list.
                    $exclusionUsers += $user
                }
            }
            Write-Debug "Users found: $($UserList.count)"
            Write-Debug "Exclusion Users found: $($exclusionUsers.count)"
            $difference = $UserList | where-object { $_.username -notcontains $exclusionUsers.username }
            Write-Debug "Users w/o $ExcludeAttribute attribute found: $($difference.count)"
            # just set the users object to difference...
            $UserList = $difference
        }
    }
    process
    {
        ForEach ( $User in $CsvData )
        {
            # If the user has been deleted since the last run, remove them from the CSV
            If ( ($User.id -notin $UserList.id) -And ($User.id -notin $exclusionUsers.id ) )
            {
                Write-Debug "$($User.username) has been deleted. Removing from list."
                If (-not $ReadOnly)
                {
                    $CsvData.RemoveAt($CsvData.id.IndexOf($User.id))
                }
            }
            else
            {
                If ( ([datetime]$User.timestamp).ticks -lt $SuspendDate.ticks )
                {
                    Write-Debug "Suspending user: $($User.username). Last login: $($User.timestamp)."
                    $SuspendedUser = Get-JcSdkUser -Id $User.Id
                    $SuspendedList.Add([PSCustomObject]@{
                        Username      = $SuspendedUser.Username;
                        Firstname     = $SuspendedUser.Firstname;
                        Lastname      = $SuspendedUser.Lastname;
                        Email         = $SuspendedUser.Email;
                        LastLoginDate = $User.timestamp;
                        Id            = $SuspendedUser.Id;
                        Manager       = ( $SuspendedUser.Attributes | ? { $_.Name -eq "Manager" } ).Value;
                    }) | Out-Null
                    If ( -not $ReadOnly )
                    {
                        Set-JcSdkUser -Id $User.id -State "SUSPENDED" | Out-Null
                        $CsvData.RemoveAt($CsvData.id.IndexOf($User.id))
                    }
                }
            }
        }
        # For each user not found in the csv, they don't have a recorded last login
        ForEach ($User in $UserList)
        {
            if ($User.id -notin $CsvData.id)
            {
                # Check if user is still inactive - don't disable if they are not
                if ( $User.Activated )
                {
                    # suspend
                    Write-Debug "Suspending user: $($User.username). Last login: N/A."
                    $SuspendedList.Add([PSCustomObject]@{
                        Username      = $User.Username;
                        Firstname     = $User.Firstname;
                        Lastname      = $User.Lastname;
                        Email         = $User.Email;
                        LastLoginDate = "N/A";
                        Id            = $User.Id;
                        Manager       = ( $User.Attributes | ? { $_.Name -eq "Manager" } ).Value;
                    }) | Out-Null
                    If ( -not $ReadOnly )
                    {
                        Set-JcSdkUser -Id $User.id -State "SUSPENDED" | Out-Null
                    }
                }
            }
        }
    }
    end
    {
        if ( -not $ReadOnly )
        {
            $CsvData | Export-Csv $CsvPath
        }
        $SuspendedList
    }
}
```