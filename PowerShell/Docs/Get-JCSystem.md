---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Get-JCSystem

## SYNOPSIS

Returns all JumpCloud Systems within a JumpCloud tenant or a single JumpCloud System using the -ByID Parameter.

## SYNTAX

### ReturnAll (Default)

```PowerShell
Get-JCSystem
```

### ByID

```PowerShell
Get-JCSystem [-SystemID] <String> [-ByID]
```

## DESCRIPTION

The Get-JCSystem function returns all information describing a JumpCloud system. By default this will return all Systems.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Get-JCSystem
```

Returns all JumpCloud managed systems and the information describing these systems.

### Example 2

```PowerShell
PS C:\> Get-JCSystemUser -SystemID 5n0795a712704la4eve154r
```

Returns a single JumpCloud System with SystemID '5n0795a712704la4eve154r'.

### Example 3

```PowerShell
PS C:\> Get-JCSystem | Where-Object active -EQ $true
```

Returns all active JumpCloud Systems and the information describing these systems.

### Example 4

```PowerShell
PS C:\> Get-JCSystem | Where-Object {$_.agentVersion -NE '0.9.633' -and $_.os -like '*Mac*'}
```

Returns all JumpCloud systems where the agentVersion is not equal to '0.9.633' and the operating system is like '*Mac*'

## PARAMETERS

### -ByID

Use the -ByID parameter when you want to query a specific System or if the -SystemID property is being passed over the pipeline. The -ByID SwitchParameter will set the ParameterSet to 'ByID' which queries one JumpCloud command at a time.

```yaml
Type: SwitchParameter
Parameter Sets: ByID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemID

The _id of the System which you want to query.

To find a JumpCloud SystemID run the command:

```PowerShell
PS C:\> Get-JCSystem | Select hostname, _id
```

The SystemID will be the 24 character string populated for the _id field.

```yaml
Type: String
Parameter Sets: ByID
Aliases: _id, id

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
