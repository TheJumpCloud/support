---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCSystemGroupMember
schema: 2.0.0
---

# Remove-JCSystemGroupMember

## SYNOPSIS
Removes a JumpCloud System from a JumpCloud System Group

## SYNTAX

### ByName (Default)
```
Remove-JCSystemGroupMember [-GroupName] <String> -SystemID <String> [<CommonParameters>]
```

### ByID
```
Remove-JCSystemGroupMember [[-GroupName] <String>] -SystemID <String> [-ByID] [-GroupID <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCSystemGroupMember function is used to remove a JumpCloud System from a JumpCloud System Group. The  System Group member must be removed using the SystemID parameter.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-JCSystemGroupMember -GroupName 'Windows Systems' -SystemID '59dad305383roc7k369sf7s2'
```

Removes a System with SystemID '59dad305383roc7k369sf7s2' from the System Group 'Windows Systems'

### Example 2
```powershell
PS C:\> Get-JCSystem | Where-Object os -Like *Windows* | Remove-JCSystemGroupMember -GroupName 'Mac Systems'
```

Removes all Systems with an operating system like 'Windows' from the System Group 'Mac Systems'

### Example 3
```powershell
Get-JCSystem | Where-Object active -EQ $false | Remove-JCSystemGroupMember -GroupName 'Active Systems'
```

Removes all inactive systems from the System Group 'Active Systems'

## PARAMETERS

### -ByID
Use the -ByID parameter when the SystemID is passed over the pipeline to the Remove-JCSystemGroupMember function.
The -ByID SwitchParameter will set the ParameterSet to 'ByID' which will increase the function speed and performance.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: ByID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupID
The GroupID is used in the ParameterSet 'ByID'.
The GroupID for a System Group can be found by running the command: PS C:\\\> Get-JCGroup -type 'System'

```yaml
Type: System.String
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
Type: System.String
Parameter Sets: ByName
Aliases: name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: name

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SystemID
The _id of the System which you want to remove from the System Group.
To find a JumpCloud SystemID run the command: PS C:\\\> Get-JCSystem | Select hostname, _id

The SystemID will be the 24 character string populated for the _id field.
SystemID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Remove-JCSystemGroupMember.
This is shown in EXAMPLES 2 and 3.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: id, _id

Required: True
Position: Named
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
