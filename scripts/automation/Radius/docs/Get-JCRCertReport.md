---
external help file: JumpCloud.Radius-help.xml
Module Name: JumpCloud.Radius
online version: /
schema: 2.0.0
---

# Get-JCRCertReport

## SYNOPSIS

This cmdlet generates a report of RADIUS certificates for JumpCloud devices and their associated users.

## SYNTAX

```
Get-JCRCertReport [-ExportFilePath] <FileInfo> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet generates a report of RADIUS certificates for JumpCloud devices and their associated users.

The report includes details such as certificate installation status, and user associations.

## EXAMPLES

### Example 1

```powershell
Get-JCRCertReport -ExportFilePath "C:\Reports\RadiusCertReport.csv"
```

This command generates a report of RADIUS certificates and exports it to a CSV file at the specified path.

## PARAMETERS

### -ExportFilePath

Specifies the file path where the report will be exported.

```yaml
Type: System.IO.FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
