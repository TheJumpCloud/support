---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/New-JCImportTemplate
schema: 2.0.0
---

# New-JCImportTemplate

## SYNOPSIS
A guided walk through that creates a JumpCloud User Import CSV file on your local machine.

## SYNTAX

```
New-JCImportTemplate [-Force] -Type <Object> [<CommonParameters>]
```

## DESCRIPTION
The New-JCImportTemplate command is a menu driven function that guides end users and creates a custom JumpCloud User Import .CSV file on their machine for populating with their users information for Importing into JumpCloud.
If users wish to bind users to existing JumpCloud systems the function will also output a .csv file with containing all existing JumpCloud machines to the users $Home directory. The user will need this file to associate SystemIDs with new users.

## EXAMPLES

### Video Tutorials

[Basic User Import](https://youtu.be/WSE5_uGYcIc)

[Advanced User Import](https://youtu.be/L2hP-XtUJH8)

### Example 1
```powershell
PS C:\> New-JCImportTemplate
```

Launches the New-JCImportTemplate menu

## PARAMETERS

### -Force
Parameter to force populate CSV with all headers when creating an update template. When selected this option will forcefully replace existing files in the current working directory. i.e. If you

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Type of CSV to Create. Update or Import are valid options.

```yaml
Type: System.Object
Parameter Sets: (All)
Aliases:
Accepted values: Import, Update

Required: True
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
