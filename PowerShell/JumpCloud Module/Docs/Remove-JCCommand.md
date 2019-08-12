---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCCommand
schema: 2.0.0
---

# Remove-JCCommand

## SYNOPSIS
Removes a JumpCloud command

## SYNTAX

### warn (Default)
```
Remove-JCCommand [-CommandID] <String> [<CommonParameters>]
```

### force
```
Remove-JCCommand [-CommandID] <String> [-force] [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCCommand can remove a single JumpCloud command or multiple commands that are passed to the command over the pipeline. The default behavior is to prompt with a warning message when deleting a command result but this can be suppressed with the -force Parameter.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-JCCommand -CommandID 5j09o6f23dan6f4n035601d5
```

Removes the JumpCloud Command with a CommandID of '5j09o6f23dan6f4n035601d5'. A warning message will be presented to confirm this operation.

### Example 2
```powershell
PS C:\> Remove-JCCommand -CommandID 5j09o6f23dan6f4n035601d5 -Force
```

Removes the JumpCloud Command with a CommandID of '5j09o6f23dan6f4n035601d5'. A warning message will not be presented to confirm this operation because the '-Force' parameter is used.

## PARAMETERS

### -CommandID
The _id of the JumpCloud Command  you wish to query.
To find a JumpCloud CommandID run the command: \`PS C:\\\> Get-JCCommand | Select name, _id\`.
The CommandID will be the 24 character string populated for the _id field.
CommandID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandID.

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
A SwitchParameter which removes the warning message when removing a JumpCloud Command.

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
