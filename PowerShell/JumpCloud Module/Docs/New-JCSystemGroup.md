---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/New-JCSystemGroup
schema: 2.0.0
---

# New-JCSystemGroup

## SYNOPSIS
Creates a JumpCloud System Group

## SYNTAX

```
New-JCSystemGroup [-GroupName] <String> [<CommonParameters>]
```

## DESCRIPTION
Creates a JumpCloud System Group. Note that a JumpCloud System Group must have a unique name.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-JCSystemGroup -GroupName 'New System Group'
```

Creates a new JumpCloud System Group with the name 'New System Group'

## PARAMETERS

### -GroupName
The name of the new JumpCloud System Group.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
