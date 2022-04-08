# Import-JCUsersFromCSV

## SYNOPSIS
Imports a set of JumpCloud users from a CSV file created using the New-JCImportTemplate function.

## SYNTAX

### GUI (Default)
```
Import-JCUsersFromCSV [-CSVFilePath] <String> [<CommonParameters>]
```

### force
```
Import-JCUsersFromCSV [-CSVFilePath] <String> [-force] [<CommonParameters>]
```

## DESCRIPTION
The Import-JCUsersFromCSV function does data validation when importing JumpCloud users from a CSV file to warn the administrator of any potential issues during the import process. Examples of warnings include warning messages for users that already exist, systems that do not exist, and groups that do not exist.

The Import-JCUserFromCSV function allows administrator to create JumpCloud users, add them to JumpCloud User Groups, and associate them with a JumpCloud system.

Note: Custom Attribute values must be non-null and unique.

The Import-JCUserFromCSV command takes ~ 1 minute for every 100 users. This time varies based on if users are added to groups or associated with systems during import.

During import a JumpCloud administrator can ensure the import is working by watching their JumpCloud user count increase in the admin console.

## EXAMPLES

### Video Tutorials

[Basic User Import](https://youtu.be/WSE5_uGYcIc)

[Advanced User Import](https://youtu.be/L2hP-XtUJH8)

### Example 1
```powershell
PS C:\> Import-JCUsersFromCSV -CSVFilePath \users\cclemons\JCUserImport_11-16-2017.csv
```

Imports the .csv file 'JCUserImport_11-16-2017.csv' from the path \users\cclemons\

### Example 2
```powershell
PS C:\Users\busters> Import-JCUsersFromCSV -CSVFilePath .\Import10.csv
```

Imports the .csv file 'Import10.csv' from the current directory using '. sourcing'

### Example 3
```powershell
PS C:\> Import-JCUsersFromCSV -CSVFilePath \users\cclemons\JCUserImport_11-16-2017.csv -Force
```

Uses the 'Force' parameter to skip the GUI and data validation and imports users from the file '\users\cclemons\JCUserImport_11-16-2017.csv'

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
A SwitchParameter which suppresses the GUI and data validation when using the Import-JCUsersFromCSV command.

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
