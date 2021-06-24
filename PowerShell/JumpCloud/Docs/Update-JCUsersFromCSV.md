---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Update-JCUsersFromCSV
schema: 2.0.0
---

# Update-JCUsersFromCSV

## SYNOPSIS
Updates a set of JumpCloud users from a CSV file created using the New-JCImportTemplate function.

## SYNTAX

### GUI (Default)
```
Update-JCUsersFromCSV [-CSVFilePath] <String> [<CommonParameters>]
```

### force
```
Update-JCUsersFromCSV [-CSVFilePath] <String> [-force] [<CommonParameters>]
```

## DESCRIPTION
The Update-JCUsersFromCSV function does data validation when updating JumpCloud users in bulk from a CSV file to warn the administrator of any potential issues during the import process. Examples of warnings include warning messages for employeeIdentifiers that already exist, systems that do not exist, and groups that do not exist.
The Update-JCUserFromCSV command can be used to update user attributes, add users to groups, and bind users to systems in bulk.
The Update-JCUserFromCSV command also has a '-force' parameter which admins can use to skip the data validate or to use the function in an automation script.

## EXAMPLES

### Example 1
```powershell
PS C:\> Update-JCUsersFromCSV ./JCUserUpdateImport_09-20-2018.csv
```

Updates users from the .csv file 'JCUserUpdateImport_09-20-2018.csv'

### Example 2
```powershell
PS C:\> Update-JCUsersFromCSV ./JCUserUpdateImport_09-20-2018.csv -Force
```

Uses the 'Force' parameter to skip the GUI and data validation and update users from the file 'JCUserUpdateImport_09-20-2018.csv

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
A SwitchParameter which suppresses the GUI and data validation when using the Update-JCUsersFromCSV command.

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
