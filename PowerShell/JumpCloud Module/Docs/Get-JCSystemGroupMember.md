---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCSystemGroupMember
schema: 2.0.0
---

# Get-JCSystemGroupMember

## SYNOPSIS
Returns the System Group members of a JumpCloud System Group.

## SYNTAX

### ByGroup (Default)
```
Get-JCSystemGroupMember [-GroupName] <String> [<CommonParameters>]
```

### ByID
```
Get-JCSystemGroupMember -ByID <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-JCSystemGroupMember function returns all the System Group members of a JumpCloud System Group.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCSystemGroupMember -GroupName 'OSX Group'
```

Returns the JumpCloud Systems that are a member of the group 'OSX Group'

### Example 2
```powershell
PS C:\> Get-JCGroup -Type System | Get-JCSystemGroupMember
```

Returns all JumpCloud System Groups and their System members.

### Example 3
```powershell
PS C:\> Get-JCGroup -Type System | Get-JCSystemGroupMember | Where-Object System -EQ 'Server01'
```

Returns all JumpCloud System Groups that the system with a hostname of 'Server01' is a member of.

## PARAMETERS

### -ByID
If searching for a System Group using the GroupID populate the GroupID in the -ByID field.

```yaml
Type: String
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupName
The name of the JumpCloud System Group you want to return the members of.

```yaml
Type: String
Parameter Sets: ByGroup
Aliases: name

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
