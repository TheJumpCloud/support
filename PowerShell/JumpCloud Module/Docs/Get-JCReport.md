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
Get-JCReport [-Sort <Sort>] -ReportID <String> -Type <String>
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
$reportContent = Get-JCReport -reportID $lastReport.id -type 'json'
```

Returns the report's content in JSON format from the last generated report

### EXAMPLE 4
```
$lastReport = Get-JCReport -Sort 'CREATED_AT' | Select -First 1
$reportContent = Get-JCReport -reportID $lastReport.id -type 'csv'
```

Returns the report's content in CSV format from the last generated report


## PARAMETERS

### -ReportID
ID of the Report request.

```yaml
Type: System.String
Parameter Sets: Report
Aliases: id

Required: True
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

### -Type
Output type of the report content, either CSV or JSON

```yaml
Type: System.String
Parameter Sets: Report
Aliases:

Required: True
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
