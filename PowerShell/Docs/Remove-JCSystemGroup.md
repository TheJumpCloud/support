---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Remove-JCSystemGroup

## SYNOPSIS

Removes a JumpCloud System Group

## SYNTAX

### warn (Default)

```PowerShell
Remove-JCSystemGroup [-GroupName] <String>
```

### force

```PowerShell
Remove-JCSystemGroup [-GroupName] <String> [-force]
```

## DESCRIPTION

Removes a JumpCloud System Group. By default a warning message will be presented to confirm the operation.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Remove-JCSystemGroup -GroupName 'On Prem Systems'
```

Removes the JumpCloud System Group with the name 'On Prem Systems'. A warning message will be presented to confirm the operation.

### Example 2

```PowerShell
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

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
