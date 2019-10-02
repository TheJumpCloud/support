---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Add-JCSystemGroupMember
schema: 2.0.0
---

# Add-JCSystemGroupMember

## SYNOPSIS
Adds a JumpCloud System to a JumpCloud System Group

## SYNTAX

### ByName (Default)
```
Add-JCSystemGroupMember [-GroupName] <String> -SystemID <String> [<CommonParameters>]
```

### ByID
```
Add-JCSystemGroupMember [[-GroupName] <String>] -SystemID <String> [-ByID] [-GroupID <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The Add-JCSystemGroupMember function is used to add a JumpCloud System to a JumpCloud System Group. The new System Group member must be added by the SystemID parameter.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-JCSystemGroupMember -GroupName 'Windows Systems' -SystemID '59dad305383roc7k369sf7s2'
```

Adds a System with SystemID '59dad305383roc7k369sf7s2' to the System Group 'Windows Systems'

### Example 2
```powershell
PS C:\> Get-JCSystem | Where-Object os -Like *Mac* | Add-JCSystemGroupMember -GroupName 'Mac Systems'
```

Adds all Systems with an operating system like 'Mac' to the System Group 'Mac Systems'

### Example 3
```powershell
Get-JCSystem | Where-Object active -EQ $true | Add-JCSystemGroupMember -GroupName 'Active Systems'
```

Adds all active systems to the System Group 'Active Systems'

### Example 4
```powershell
Get-JCSystem |  Where-Object {$_.active -EQ $true -and $_.os -like '*Mac*'} | Add-JCSystemGroupMember 'Active Mac Systems'
```

Adds all active systems with an operating system like 'Mac' to the System Group 'Active Mac Systems'

## PARAMETERS

### -ByID
Use the -ByID parameter when the GroupID and SystemID are both being passed over the pipeline to the Add-JCSystemGroupMember function.
The -ByID SwitchParameter will set the ParameterSet to "ByID" which will increase the function speed and performance.

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
The GroupID for a System Group can be found by running the command:

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
The name of the JumpCloud System Group that you want to add the System to.

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
The _id of the System which you want to add to the System Group.

To find a JumpCloud SystemID run the command:

PS C:\\\> Get-JCSystem | Select hostname, _id

The SystemID will be the 24 character string populated for the _id field.

SystemID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Add-JCSystemGroupMember.
This is shown in EXAMPLES 2, 3, and 4.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: _id, id

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
