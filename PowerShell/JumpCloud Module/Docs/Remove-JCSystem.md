---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCSystem
schema: 2.0.0
---

# Remove-JCSystem

## SYNOPSIS
Removes a JumpCloud system.

## SYNTAX

### warn (Default)
```
Remove-JCSystem [-SystemID] <String> [<CommonParameters>]
```

### force
```
Remove-JCSystem [-SystemID] <String> [-force] [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCSystem removes a JumpCloud system. If the target system is online this command will uninstall the JumpCloud agent from the system. If the target machine is offline then at this next check in the JumpCloud agent will be removed. The only action completed on the target system is the removal of the JumpCloud agent. No modifications are made to local user accounts during the agent removal.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-JCSystem -SystemID 5n0795a712704la4eve154r
```

Removes the JumpCloud System with SystemID '5n0795a712704la4eve154r'. A warning message will be presented to confirm this operation.

### Example 2
```powershell
PS C:\> Remove-JCSystem -SystemID 5n0795a712704la4eve154r -Force
```

Removes the JumpCloud System with SystemID '5n0795a712704la4eve154r' using the -Force Parameter. A warning message will not be presented to confirm this operation.

### Example 3
```powershell
Get-JCSystem | Where-Object lastContact -lT (Get-Date).AddDays(-30).ToString('yyy-MM-ddTHH:MM:ss') | Remove-JCSystem
```

Removes all JumpCloud Systems that have a lastContact date greater then 30 days. A warning message will be presented to confirm each operation.

### Example 4
```powershell
PS C:\> Get-JCSystem | Where-Object displayName -Like *Server10* | Remove-JCSystem -force
```

Removes all JumpCloud Systems that have a displayName like 'Server10'. A warning message will not be presented to confirm each operation.

### Example 5

```PowerShell
Get-JCSystem -displayName System101 -returnProperties lastContact | Sort-Object lastContact -Descending | Select * -Skip 1 | Remove-JCSystem -force
```

Removes all but the last system to contact JumpCloud with the display name 'System101'. This can be used to clean up duplicate systems that may have the same name by replacing 'System101' with the name of the system that contains duplicates.

## PARAMETERS

### -SystemID
The _id of the System which you want to remove from JumpCloud.
To find a JumpCloud SystemID run the command: PS C:\\\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field.
SystemID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID.
This is shown in EXAMPLES 3 and 4.

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

### -force
A SwitchParameter which suppresses the warning message when removing a JumpCloud System.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
