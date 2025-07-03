---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# New-JCDeviceUpdateTemplate

## SYNOPSIS
A guided walk through that creates a JumpCloud Device Import CSV file on your local machine.

## SYNTAX

```
New-JCDeviceUpdateTemplate [-Force] [<CommonParameters>]
```

## DESCRIPTION
The New-JCDeviceUpdateTemplate command is a menu driven function that guides end users and creates a custom JumpCloud Device Import .CSV file on their machine for populating with their Device information for updating in JumpCloud.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-JCDeviceUpdateTemplate
```

Launches the New-JCDeviceUpdateTemplate menu

## PARAMETERS

### -Force
Parameter to force populate CSV with all headers when creating an update template.
When selected this option will forcefully replace existing files in the current working directory

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
