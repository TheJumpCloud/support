---
layout: post
title: Generate list of Apps/Programs on systems
description: For every system, generate a CSV report of that systems Apps/Programs
tags:
  - powershell
  - reports
---

This script will produce a CSV for every system in an organization. Generating this data could take a while if many systems in an organization exist. Mac systems are queired with `Get-JCSystemInsights -Table App` whereas windows systems use the `Get-JCSystemInsights -Table Program` table to gather data.

### Basic Usage

* The PowerShell Module is required to run this script
* Save the script to a location
* In a PowerShell terminal window, run the script `~/Path/To/Scrpt/filename.ps1`

### Additional Information

A CSV file titled `systemHostname.CSV` will be created in the same location as this script is run/ saved.

### Script

```powershell
################################################################################
# This script requires the JumpCloud PowerShell Module to run. Specifically, the
# JumpCloud PowerShell SDK Modules are required to run the system queries. To
# install the PowerShell Modules, enter the following line in a PWSH terminal:
# Install-Module JumpCloud
#
# To run this script, save this file to a location on a storage drive in a
# directory of it's own.
# EX: ~/Documents/ApplicationReport/reportSystemAppsPrograms.ps1
#
# This script will create a systemHostname.csv file for each system in the org.
# These files will be generated in the same location this script is stored. EX:
#
# ~/Documents/ApplicationReport/
# ├── BobsMacSystem.csv
# ├── SallysWindowsLaptop.csv
# ├── JimsMacSystem.csv
# ├── KatesMacBookPro.csv
# ├── StevesWindowsLaptop.csv
# ├── RyansMacBookPro.local.csv
# └── reportSystemAppsPrograms.ps1
#
# To run from a powershell terminal:
# ~/Documents/ApplicationReport/reportSystemAppsPrograms.ps1
################################################################################

# query systems
$allSystems = Get-JcSdkSystem
foreach ($system in $allSystems)
{
    # Get App List for each system
    if ($system.OS -eq 'Windows')
    {
        $programs = Get-JCSystemInsights -Table Program -SystemId $system.Id | ConvertTo-CSV
        Out-File -FilePath $PSScriptRoot/$($system.hostname).csv -InputObject $programs
    }
    if ($system.OS -eq 'Mac OS X')
    {
        $apps = Get-JCSystemInsights -Table App -SystemId $system.id | ConvertTo-CSV
        Out-File -FilePath $PSScriptRoot/$($system.hostname).csv -InputObject $apps
    }
}
```