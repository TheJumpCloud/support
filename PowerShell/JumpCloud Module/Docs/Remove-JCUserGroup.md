---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCUserGroup
schema: 2.0.0
---

# Remove-JCUserGroup

## SYNOPSIS
Removes a JumpCloud User Group

## SYNTAX

### warn (Default)
```
Remove-JCUserGroup [-GroupName] <String> [<CommonParameters>]
```

### force
```
Remove-JCUserGroup [-GroupName] <String> [-force] [<CommonParameters>]
```

## DESCRIPTION
Removes a JumpCloud User Group. By default a warning message will be presented to confirm the operation.

## EXAMPLES

### Example 1```powershell
PS C:\> Remove-JCUserGroup -GroupName 'The Band'
```

Removes the JumpCloud User Group with the name 'The Band'. A warning message will be presented to confirm the operation.

### Example 2```powershell
PS C:\> Remove-JCUserGroup -GroupName 'The Band' -Force
```

Removes the JumpCloud User Group with the name 'The Band' using the -Force Parameter. A warning message will not be presented to confirm the operation.

## PARAMETERS

### -GroupName
The name of the User Group you want to remove.

```yaml
Type: String
Parameter Sets: (All)
Aliases: name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -force
A SwitchParameter which suppresses the warning message when removing a JumpCloud User Group.

```yaml
Type: SwitchParameter
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

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
