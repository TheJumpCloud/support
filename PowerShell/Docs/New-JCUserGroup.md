---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# New-JCUserGroup

## SYNOPSIS

Creates a JumpCloud User Group

## SYNTAX

```PowerShell
New-JCUserGroup [-GroupName] <String>
```

## DESCRIPTION

Creates a JumpCloud User Group. Note that a JumpCloud User Group must have a unique name.

## EXAMPLES

### Example 1

```PowerShell
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

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
