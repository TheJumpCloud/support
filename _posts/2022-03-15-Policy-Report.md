---
layout: post
title: Policy Report
description: Creates a report based on the PolicyId provided
tags:
  - powershell
  - reports
  - automation
  - policy
---

This script will create a CSV report based on the given PolicyId. The script prompts the user to enter the PolicyId and the folder directory it intends to save the CSV file.

### Basic Usage

* The PowerShell Module is required to run this script
* Save the script to a location
* In a PowerShell terminal window, run the script `~/Path/To/Scrpt/filename.ps1`
* Follow the prompts to enter
  * PolicyId
  * Folder directory ()
  
### Expected Output

|HostName       |Time(UTC)           |State  |Success|StdOut                                               |StdErr|
|---------------|--------------------|-------|-------|-----------------------------------------------------|------|
|KENMARANIOND64B|3/4/2022 4:35:51 PM |success|True   |removablestorage_windows policy successfully applied.|      |
|KENMARANION3EDC|3/14/2022 5:07:05 PM|success|True   |removablestorage_windows policy successfully applied.|      |

### Script

```powershell
$policy =  Read-Host -Prompt "Enter policy id"
$policyId = $policy
$csvFilePath = Read-Host -Prompt "Enter folder directory to save the report"
$today = (get-date).tostring("yyyyMMddHHmm")
$outcsvpath = $csvFilePath
$outcsv = "JCPolicyResult_" + $policyId + "_" + $today + '.csv'
$tempdir = $csvFilePath
$policyos = (Get-JcSdkPolicy -Id $policyId | select TemplateOSMetaFamily -ExpandProperty TemplateOSMetaFamily)
$filter = 'osFamily:$eq:'+$policyos

if (test-path -Path ($tempdir + "JcSdkSystem" + '.json'))
{
    Clear-Content ($tempdir + "JcSdkSystem" + '.json') #Clear the temp json file
    Get-JcSdkSystem -Filter $filter | ConvertTo-Json -Depth 100 | out-file ($tempdir + "JcSdkSystem" + '.json')
}
else
{
    #apicall for system to csv to hashtable
    Get-JcSdkSystem -Filter $filter | ConvertTo-Json -Depth 100 | out-file ($tempdir + "JcSdkSystem" + '.json')
}

# Build local system/id hashtable
$hash = @{}
    foreach ($property in (get-content ($tempdir + "JcSdkSystem" + '.json') | convertFrom-Json))
    {
        $hash[$property.Id] = $property.Hostname
    }

#Query latest policy results
$latestpresult = Get-JcSdkPolicyStatus -PolicyId $policyId

#Form attributes
$output = @()
foreach ($item in $latestpresult)
{
  $matchingSystem = $hash.($item.systemID)
  # Policy results will contain records for deleted systems, do not include them in this report.
  # if system exists in system list, continue.
  if ($matchingSystem)
  {
      $output += [PSCustomObject]@{
          HostName        = $matchingSystem
          'Time(UTC)'     = ([TimeZoneInfo]::ConvertTimeToUtc(([DateTime]$item.endedAt).ToUniversalTime()))
          State           = $item.State
          Result          = $item.Success
          Result_Message  = $item.StdOut
          Error           = $item.StdErr
      }
  }
}

#Output to csv
$output | Export-Csv -NoTypeInformation ($outcsvpath + $outcsv)
```