---
layout: post
title: Report on Systems and Users
description: Generate a CSV report for systems and their associated users
tags:
  - powershell
  - reports
  - automation
---

A CSV report of systems and their user associations (inactive and active). This script will generate a "Report-SystemToUserAssociation.csv" file relative to the location this script is saved and ran.

### Basic Usage:

* Install the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Using-the-JumpCloud-PowerShell-Module)
* Save the contents of the script example to a file on a system.
  * EX: ~/Report-Systems_To_User_Associations.ps1
  * Edit the the `Global Configuration - Start` section with your APIKey, report file name, and user associations
* In a PowerShell terminal window run:
  * `~/Report-Systems_To_User_Associations.ps1`

### Additional Information

This script will post a warning message when it finds an inactive user.

### Expected Output

A table should be generated for systems and their associated users. If inactive users are bound to the system they'll appear in the `inactiveUser` column.

|systemID|systemHostname|systemDisplayname|systemSerialNumber|systemVendor|systemModel|systemCpuBrand|systemCpuType|systemDiskSizeGB|systemPhysicalMemGB|systemLastContact|systemCreated|uptimeHours|activeUser|inactiveUser|systemJumpCloudDetails
| - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |
|63923eb5664f0d6d7ec123e2|KENMARANION8C95|KENMARANION8C95|564d7c09a935b5e5b340e9c5fd329e7d|VMware, Inc.|VMware7,1|AMD Ryzen 5 5600X 6-Core Processor|x86\_64|256|6|12/12/2022 6:35:09 PM|12/8/2022 7:44:53 PM|5.53|testUser3;testUser2;|testUser1;|https://console.jumpcloud.com/#/devices/63923eb5664f0d6d7ec123e2/details|

### Script Example:

```powershell
###################### Global Configuration - Start ######################
$jc_api_key = 'YOURAPIKEY'
$report_file_name_prefix = 'Report-Systems_To_User_Associations'
$user_association = $false
####################### Global Configuration - End #######################

################ DO NOT CHANGE ANY LINES BELOW THIS LINE! ################

##### START OF SCRIPT #####

## Connect to JumpCloud
Connect-JCOnline -JumpCloudApiKey $jc_api_key -Force
$timestamp_utc = $(((get-date).ToUniversalTime()).ToString("yyyyMMdd_HHmmss"))
$report_file_name = ($report_file_name_prefix + '-' + $timestamp_utc)
$result = New-Object System.Collections.Generic.List[PSCustomObject]
$count = 0
$timer = [System.Diagnostics.Stopwatch]::StartNew()

## Get All Systems
$systems = Get-JcSdkSystem

## Interate on Systems and Enrich with System Insights and User Association
foreach ($system in $systems)
{
    $count++
    Write-Progress -Activity ("Procesing system '" + $system.DisplayName + "'") -Status ("$count complete out of " + $systems.count) -PercentComplete ($count/$systems.Count*100)

    # Initialize an enriched system item
    $es = New-Object PSCustomObject
    ## Enrich system data with System Insights
    $uptimeInisights = Get-JcSystemInsights -SystemID $system.Id -Table Uptime
    if ($($uptimeInisights.TotalSeconds))
    {
        $uptimeHours = (New-TimeSpan -Seconds $($uptimeInisights.TotalSeconds)).TotalHours
    }
    $systemInfoInsights = Get-JcSystemInsights -SystemID $system.Id -Table SystemInfo
    
    $es | Add-Member -MemberType NoteProperty -Name 'systemID' -Value $system.Id -Force
    $es | Add-Member -MemberType NoteProperty -Name 'systemHostname' -Value $system.Hostname -Force
    $es | Add-Member -MemberType NoteProperty -Name 'systemDisplayname' -Value $system.DisplayName -Force
    $es | Add-Member -MemberType NoteProperty -Name 'systemSerialNumber' -Value $systemInfoInsights.HardwareSerial -Force
    $es | Add-Member -MemberType NoteProperty -Name 'systemVendor' -Value $systemInfoInsights.HardwareVendor -Force
    $es | Add-Member -MemberType NoteProperty -Name 'systemModel' -Value $systemInfoInsights.HardwareModel -Force
    $es | Add-Member -MemberType NoteProperty -Name 'systemCpuBrand' -Value $systemInfoInsights.CpuBrand -Force
    $es | Add-Member -MemberType NoteProperty -Name 'systemCpuType' -Value $systemInfoInsights.CpuType -Force

    ## Calculate Disk Storage
    try 
    {
        ## For Windows
        $systemDiskInsights = Get-JcSystemInsights -SystemID $system.Id -Table DiskInfo
        if ( $null -ne $systemDiskInsights )
        {
            $systemDiskSizeGB = [math]::Round($systemDiskInsights.DiskSize/1GB)
        }
        else 
        {
            # For macOS and Linux we use Mounts
            $SystemMountInsights = Get-JcSystemInsights -SystemID $system.Id -Table Mount
            $maxMount = ($SystemMountInsights | Select-Object @{label = "intBlocks"; expression = { [int]$_.Blocks } },@{label = "intBlocksSize"; expression = { [int]$_.BlocksSize } } | Sort-Object intBlocks -Descending)[0]
            $systemDiskSizeGB = [math]::Round(($maxMount.intBlocks*$maxMount.intBlocksSize)/1GB)
        }
    }
    catch 
    {
        $systemDiskSizeGB = 0
    }
    finally
    {
        $es | Add-Member -MemberType NoteProperty -Name 'systemDiskSizeGB' -Value $systemDiskSizeGB -Force
    }

    $es | Add-Member -MemberType NoteProperty -Name 'systemPhysicalMemGB' -Value ([math]::Round($systemInfoInsights.PhysicalMemory/1GB)) -Force        
    $es | Add-Member -MemberType NoteProperty -Name 'systemLastContact' -Value $system.LastContact -Force
    $es | Add-Member -MemberType NoteProperty -Name 'systemCreated' -Value $system.Created -Force
    $es | Add-Member -MemberType NoteProperty -Name 'uptimeHours' -Value ([math]::Round($uptimeHours,2)) -Force
   
    ## Enrich System data with user association
    if ( $user_association )
    {
        $associations = Get-JcSdkSystemTraverseUser -SystemID $system.Id
        $activeUser = ""
        $inactiveUser = ""
        foreach ($association in $associations)
        {
            $foundUser = Get-JcSdkUser -Id $association.Id
            if ($foundUser.State -eq "ACTIVATED") {
                $activeUser += $foundUser.Username + ';'
            }
            else {
                Write-Warning "$($foundUser.Username) is not activated"
                $inactiveUser += $foundUser.Username + ';'
            }
        }

        $es | Add-Member -MemberType NoteProperty -Name 'activeUser' -Value $activeUser -Force
        $es | Add-Member -MemberType NoteProperty -Name 'inactiveUser' -Value $inactiveUser -Force
    }

    $es | Add-Member -MemberType NoteProperty -Name 'systemJumpCloudDetails' -Value ("https://console.jumpcloud.com/#/devices/$($system.Id)/details") -Force
    
    # Add Enriched System to Result
    $result.Add($es)

    # Appending Enriched System to CSV Output
    $es | Export-Csv -Path ($report_file_name + '.csv') -NoTypeInformation -Append
}
Write-Progress -Activity ("Procesing system '" + $system.DisplayName + "'") -Status ("$count complete out of " + $systems.count) -PercentComplete ($count/$systems.Count*100) -Completed


Write-Output ("`n----------------------------------------------------------------------------------")
Write-Output ("Device Basic Information Report for UTC timestamp: " + $timestamp_utc)
Write-Output ("* Number of Systems: " + $result.Count)

## Print where CSV of results is located
Write-Output ("* CSV Report File Name: " + "'" + $report_file_name + ".csv" + "'")


$timer.Stop()
if ( [math]::Round($timer.Elapsed.TotalSeconds) -lt 60 )
{
    Write-Output ("* Total Runtime: " + [math]::Round($timer.Elapsed.TotalSeconds,2) + " seconds")
}
else 
{
    Write-Output ("* Total Runtime: " + [math]::Round($timer.Elapsed.TotalMinutes,2) + " minutes")
}
Write-Output ("----------------------------------------------------------------------------------`n")
Write-Output ("`nDone.`n")
##### END OF SCRIPT #####
```
