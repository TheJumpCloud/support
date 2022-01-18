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
* In a PowerShell terminal window run:
  * `~/Report-Systems_To_User_Associations.ps1`
  * Follow prompts to enter your API Key & OrgID

### Additional Information

This script will post a warning message when it finds an inactive user.

### Expected Output

A table should be generated for systems and their associated users. If inactive users are bound to the system they'll appear in the `inactiveUser` column.

|systemID                |systemHostname   |systemDisplayname|systemLastContact   |systemCreated        |systemSerialNo|systemModel  |uptimeHours       |activeUser                     |inactiveUser|
|------------------------|-----------------|-----------------|--------------------|---------------------|--------------|-------------|------------------|-------------------------------|------------|
|5e90f19ecc99d210ecb3406c|mac-system.shared|MDM System       |8/28/2020 9:21:44 PM|4/10/2020 10:22:22 PM|CXXXXXXXXXXX  |Parallels16,1|1.4730555555555600|totpuser;Farmer_0;henry.murphy;|Farmer_6    |


### Script Example:

```powershell
$systems = Get-JcSdkSystem

$list = @()

foreach ($system in $systems)
{
    $uptimeInisights = Get-JcSystemInsights -SystemID $system.Id -Table Uptime
    if ($($uptimeInisights.TotalSeconds))
    {
        $uptimeHours = (New-TimeSpan -Seconds $($uptimeInisights.TotalSeconds)).TotalHours
    }
    $systemInfoInsights = Get-JcSystemInsights -SystemID $system.Id -Table SystemInfo
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

    # populate the rows
    $list += [PSCustomObject]@{
        systemID          = $system.Id;
        systemHostname    = $system.Hostname;
        systemDisplayname = $system.DisplayName;
        systemLastContact = $system.LastContact;
        systemCreated     = $system.Created;
        systemSerialNo    = $systemInfoInsights.HardwareSerial;
        systemModel       = $systemInfoInsights.HardwareModel;
        uptimeHours       = $uptimeHours;
        activeUser   = $activeUser
        inactiveUser   = $inactiveUser
    }
}

$list | ConvertTo-Csv | Out-File "Report-SystemToUserAssociation.csv"
```
