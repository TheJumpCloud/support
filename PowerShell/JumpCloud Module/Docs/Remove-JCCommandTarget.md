---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# Remove-JCCommandTarget

## SYNOPSIS

Removes the association between a JumpCloud system or a JumpCloud system group from a JumpCloud command

## SYNTAX

### SystemID (Default)
```
Remove-JCCommandTarget [-CommandID] <String> [-SystemID] <Object> [<CommonParameters>]
```

### GroupID
```
Remove-JCCommandTarget [-CommandID] <String> [-GroupID] <Object> [<CommonParameters>]
```

### GroupName
```
Remove-JCCommandTarget [-CommandID] <String> [-GroupName] <Object> [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCCommandTarget function allows you to remove JumpCloud systems or JumpCloud system groups from the target list of a specific JumpCloud command. Group associations can be removed by system group name or system group ID system associations can only be removed using the SystemID. When JumpCloud commands are run they target all the systems on their target list.

## EXAMPLES

### Example 1
```powershell
Remove-JCCommandTarget -CommandID 5b99777710a3690ssisr3a1w -SystemID 5l0o2fu426041i79st3c35
```

Removes the JumpCloud system with System ID '5l0o2fu426041i79st3c35' from the target list for the JumpCloud command with command ID '5b99777710a3690ssisr3a1w'

### Example 2
```powershell
Remove-JCCommandTarget -CommandID 5b99777710a3690ssisr3a1w -GroupName WindowsMachines
```

Removes the JumpCloud system group 'WindowsMachines' and the systems within this group from the target list for the JumpCloud command with command ID '5b99777710a3690ssisr3a1w'

### Example 3
```powershell
Remove-JCCommandTarget -CommandID 5b99777710a3690ssisr3a1w -GroupID 5j03458a232z115210z66913
```

Removes the JumpCloud system group with the GroupID '5j03458a232z115210z66913' and the systems within this group from the target list for the JumpCloud command with command ID '5b99777710a3690ssisr3a1w'

## PARAMETERS

### -CommandID

The id value of the JumpCloud command. Use the command 'Get-JCCommand | Select-Object _id, name' to find the "_id" value for all the JumpCloud commands in your tenant.


```yaml
Type: String
Parameter Sets: (All)
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupID

The id value of a JumpCloud system group


```yaml
Type: Object
Parameter Sets: GroupID
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupName

The name of the JumpCloud system group. If the name includes a space enter the name within quotes. Example: -GroupName 'The Space'

```yaml
Type: Object
Parameter Sets: GroupName
Aliases: name

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SystemID
The _id of a JumpCloud system. To find the _id of all JumpCloud systems within your tenant run 'Get-JCSystem | select _id, hostname'


```yaml
Type: Object
Parameter Sets: SystemID
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
System.Object

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Online Help Remove-JCCommandTarget](https://github.com/TheJumpCloud/support/wiki/Remove-JCCommandTarget)