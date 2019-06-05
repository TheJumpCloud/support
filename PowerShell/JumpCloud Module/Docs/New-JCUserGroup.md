---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/New-JCUserGroup
schema: 2.0.0
---

# New-JCUserGroup

## SYNOPSIS
Creates a JumpCloud User Group

## SYNTAX

```
New-JCUserGroup [-GroupName] <String> [<CommonParameters>]
```

## DESCRIPTION
Creates a JumpCloud User Group. Note that a JumpCloud User Group must have a unique name.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-JCUserGroup -GroupName 'New User Group'
```

Creates a new JumpCloud User Group with the name 'New User Group'

## PARAMETERS

### -GroupName
The name of the new JumpCloud User Group.

```yaml
Type: String
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
