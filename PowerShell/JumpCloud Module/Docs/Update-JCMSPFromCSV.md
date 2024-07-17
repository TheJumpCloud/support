---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Update-JCMSPFromCSV

## SYNOPSIS

Updates a list of JumpCloud MSP organizations from a CSV file created using the New-JCMSPImportTemplate function.

## SYNTAX

### GUI (Default)
```
Update-JCMSPFromCSV [-CSVFilePath] <String> [<CommonParameters>]
```

### force
```
Update-JCMSPFromCSV [-CSVFilePath] <String> [-force] [-ProviderID <String>]
 [<CommonParameters>]
```

## DESCRIPTION

The Update-JCMSPFromCSV function does data validation when updating JumpCloud Organizations in bulk from a CSV file to warn the administrator of any potential issues during the import process. Examples of warnings include warning messages for organizations whose name already exists and duplicate organization names in the CSV file.

The Update-JCMSPFromCSV command can be used to update organization names and max user counts.

The Update-JCMSPFromCSV command also has a '-force' parameter which admins can use to skip the gui validation or to use the function in an automation script.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-JCMSPFromCSV ./JCMSPUpdateImport_06-14-2023.csv
```

Updates MSP orgs from the .csv file 'JCMSPUpdateImport_06-14-2023.csv'

### Example 2

```powershell
PS C:\> Update-JCMSPFromCSV ./JCMSPUpdateImport_06-14-2023.csv -Force
```

Uses the 'Force' parameter to skip the GUI and data validation and update MSP orgs from the file 'JCMSPUpdateImport_06-14-2023.csv

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

A SwitchParameter which suppresses the GUI and data validation when using the Update-JCMSPFromCSV command.

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

### -ProviderID

Your Provider ID

```yaml
Type: System.String
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
