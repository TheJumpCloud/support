---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCSystemGroup
schema: 2.0.0
---

# Remove-JCSystemGroup

## SYNOPSIS
Removes a JumpCloud System Group

## SYNTAX

### warn (Default)
```
Remove-JCSystemGroup [-GroupName] <String> [<CommonParameters>]
```

### force
```
Remove-JCSystemGroup [-GroupName] <String> [-force] [<CommonParameters>]
```

## DESCRIPTION
Removes a JumpCloud System Group. By default a warning message will be presented to confirm the operation.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-JCSystemGroup -GroupName 'On Prem Systems'
```

Removes the JumpCloud System Group with the name 'On Prem Systems'. A warning message will be presented to confirm the operation.

### Example 2
```powershell
PS C:\> Remove-JCSystemGroup -GroupName 'On Prem Systems' -Force
```

Removes the JumpCloud System Group with the name 'On Prem Systems' using the -Force Parameter. A warning message will not be presented to confirm the operation.

## PARAMETERS

### -GroupName
The name of the System Group you want to remove.

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
A SwitchParameter which suppresses the warning message when removing a JumpCloud System Group.

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
