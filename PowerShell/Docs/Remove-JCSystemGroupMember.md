---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Remove-JCSystemGroupMember

## SYNOPSIS

Removes a JumpCloud System from a JumpCloud System Group

## SYNTAX

### ByName (Default)

```PowerShell
Remove-JCSystemGroupMember [-GroupName] <String> -SystemID <String>
```

### ByID

```PowerShell
Remove-JCSystemGroupMember [[-GroupName] <String>] -SystemID <String> [-ByID] [-GroupID <String>]
```

## DESCRIPTION

The Remove-JCSystemGroupMember function is used to remove a JumpCloud System from a JumpCloud System Group. The  System Group member must be removed using the SystemID parameter.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Remove-JCSystemGroupMember -GroupName 'Windows Systems' -SystemID '59dad305383roc7k369sf7s2'
```

Removes a System with SystemID '59dad305383roc7k369sf7s2' from the System Group 'Windows Systems'

### Example 2

```PowerShell
PS C:\> Get-JCSystem | Where-Object os -Like *Windows* | Remove-JCSystemGroupMember -GroupName 'Mac Systems'
```

Removes all Systems with an operating system like 'Windows' from the System Group 'Mac Systems'

### Example 3

```PowerShell
Get-JCSystem | Where-Object active -EQ $false | Remove-JCSystemGroupMember -GroupName 'Active Systems'
```

Removes all inactive systems from the System Group 'Active Systems'

## PARAMETERS

### -ByID

Use the -ByID parameter when the SystemID is passed over the pipeline to the Remove-JCSystemGroupMember function. The -ByID SwitchParameter will set the ParameterSet to 'ByID' which will increase the function speed and performance.

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

### -GroupID

The GroupID is used in the ParameterSet 'ByID'. The GroupID for a System Group can be found by running the command:

```PowerShell
PS C:\> Get-JCGroup -type 'System'
```

```yaml
Type: String
Parameter Sets: ByID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupName

The name of the JumpCloud System Group that you want to remove the System from.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ByID
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SystemID

The _id of the System which you want to remove from the System Group.

To find a JumpCloud SystemID run the command:

```PowerShell
PS C:\> Get-JCSystem | Select hostname, _id
```

The SystemID will be the 24 character string populated for the _id field.

SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Remove-JCSystemGroupMember. This is shown in EXAMPLES 2 and 3.

```yaml
Type: String
Parameter Sets: (All)
Aliases: id, _id

Required: True
Position: Named
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
