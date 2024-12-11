---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Update-JCDeviceFromCSV

## SYNOPSIS
Updates a set of JumpCloud devices from a CSV file created using the New-JCDeviceUpdateTemplate function.

## SYNTAX

### GUI (Default)
```
Update-JCDeviceFromCSV [-CSVFilePath] <String> [<CommonParameters>]
```

### force
```
Update-JCDeviceFromCSV [-CSVFilePath] <String> [-force]
 [<CommonParameters>]
```

## DESCRIPTION
The Update-JCDeviceFromCSV bulk sets device attributes via a CSV input.

## EXAMPLES

### Example 1
```powershell
PS C:\> Update-JCDeviceFromCSV ./JCDeviceUpdateImport_12-11-2024.csv
```

Updates devices from the .csv file 'JCDeviceUpdateImport_12-11-2024.csv'

### Example 2
```powershell
PS C:\> Update-JCDeviceFromCSV ./JCDeviceUpdateImport_12-11-2024.csv -Force
```

Uses the 'Force' parameter to skip the GUI and update devices from the file 'JCDeviceUpdateImport_12-11-2024.csv'

## PARAMETERS

### -CSVFilePath
The full path to the CSV file you wish to import.
You can use tab complete to search for .csv files.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -force
A SwitchParameter which suppresses the GUI and data validation when using the Update-JCDeviceFromCSV command.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: force
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

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
