---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# New-JCSystemGroup

## SYNOPSIS

Creates a JumpCloud System Group

## SYNTAX

```PowerShell
New-JCSystemGroup [-GroupName] <String>
```

## DESCRIPTION

Creates a JumpCloud System Group. Note that a JumpCloud System Group must have a unique name.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> New-JCSystemGroup -GroupName 'New System Group'
```

Creates a new JumpCloud System Group with the name 'New System Group'

## PARAMETERS

### -GroupName

The name of the new JumpCloud System Group.

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
