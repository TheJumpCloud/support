---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Get-JCSystemGroupMember

## SYNOPSIS

Returns the System Group members of a JumpCloud System Group.

## SYNTAX

### ByGroup (Default)

```PowerShell
Get-JCSystemGroupMember [-GroupName] <String>
```

### ByID

```PowerShell
Get-JCSystemGroupMember -ByID <String>
```

## DESCRIPTION

The Get-JCSystemGroupMember function returns all the System Group members of a JumpCloud System Group.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Get-JCSystemGroupMember -GroupName 'OSX Group'
```

Returns the JumpCloud Systems that are a member of the group 'OSX Group'

### Example 2

```PowerShell
PS C:\> Get-JCGroup -Type System | Get-JCSystemGroupMember
```

Returns all JumpCloud System Groups and their System members.

### Example 3

```PowerShell
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

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
