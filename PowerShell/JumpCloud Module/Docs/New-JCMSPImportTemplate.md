---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# New-JCMSPImportTemplate

## SYNOPSIS

Creates a CSV file to either create new or update existing MSP organizations in a MSP tenant.

## SYNTAX

```
New-JCMSPImportTemplate [-Force] [-Type <Object>] [<CommonParameters>]
```

## DESCRIPTION

The New-JCMSPImportTemplate command is a menu driven function that creates a CSV template for the `Update-JCMSPFromCSV` and `Import-JCMSPFromCSV` functions. Templates for updated existing orgs are populated with the ids, names and max user counts of existing orgs. The template for new organizations is populated with only a name and max user count column.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-JCMSPImportTemplate
```

Launches the New-JCMSPImportTemplate menu

## PARAMETERS

### -Force

Parameter to force populate CSV with all headers when creating an update template.
When selected this option will forcefully replace existing files in the current working directory.
i.e.
If you

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

Type of CSV to Create.
Update or Import are valid options.

```yaml
Type: System.Object
Parameter Sets: (All)
Aliases:
Accepted values: Import, Update

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
