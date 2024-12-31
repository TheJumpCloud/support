---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCReport

## SYNOPSIS
Ordered list of report metadata

## SYNTAX

### List (Default)
```
Get-JCReport [-Sort <Sort>] [<CommonParameters>]
```

### Report
```
Get-JCReport [-Sort <Sort>] [-ReportID <String>] [-ArtifactID <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Ordered list of report metadata

## EXAMPLES

### EXAMPLE 1
```
Get-JCReport
```

Returns a list of all available reports

### EXAMPLE 2
```
Get-JCReport -Sort 'CREATED_AT'
```

Returns a list of all available reports, sorted by the most recently created report

### EXAMPLE 3
```
$lastReport = Get-JCReport -Sort 'CREATED_AT' | Select -First 1
$artifactID = ($lastReport.artifacts | Where-Object { $_.format -eq 'json' }).id
$reportID = $lastReport.id
$reportContent = Get-JCReport -artifactID $artifactID -reportID $reportID
```

Returns the report's content in JSON format from the last generated report

### EXAMPLE 4
```
$lastReport = Get-JCReport -Sort 'CREATED_AT' | Select -First 1
$artifactID = ($lastReport.artifacts | Where-Object { $_.format -eq 'csv' }).id
$reportID = $lastReport.id
$reportContent = Get-JCReport -artifactID $artifactID -reportID $reportID
```

Returns the report's content in CSV format from the last generated report

### EXAMPLE 5
```
$usersToUserGroups = New-JCReport -ReportType "users-to-user-groups"
do {
    $finishedReport = Get-JCReport | Where-Object { $_.id -eq $usersToUserGroups.id }
    switch ($finishedReport.status) {
        PENDING {
            Write-Warning "[status] waiting 5s for jumpcloud report to complete"
            Start-Sleep -Seconds 5
        }
        IN_PROGRESS {
            Write-Warning "[status] waiting 5s for jumpcloud report to complete"
            Start-Sleep -Seconds 5
        }
        FAILED {
            throw "Report failed to generate"
        }
        DELETED {
            throw "Report was deleted"
        }
    }
} until ($finishedReport.status -eq "COMPLETED")
$artifactID = ($finishedReport.artifacts | Where-Object { $_.format -eq 'json' }).id
$reportID = $usersToUserGroups.id
$reportContent = Get-JCReport -artifactID $artifactID -reportID $reportID
```

Generates a report using New-JCReport, then using a do-until loop, checks to see if the report is finished generating and then saves the finished report's content in JSON format to the $reportContent variable

## PARAMETERS

### -ArtifactID
ID of the Artifact

```yaml
Type: System.String
Parameter Sets: Report
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ReportID
ID of the Report request.

```yaml
Type: System.String
Parameter Sets: Report
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Sort
Sort type and direction.
Default sort is descending, prefix with - to sort ascending.

```yaml
Type: JumpCloud.SDK.DirectoryInsights.Support.Sort
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem
## NOTES

## RELATED LINKS

[https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/Get-JcSdkReport.md](https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/Get-JcSdkReport.md)
