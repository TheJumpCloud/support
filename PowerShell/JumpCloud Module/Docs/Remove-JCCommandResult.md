---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCCommandResult
schema: 2.0.0
---

# Remove-JCCommandResult

## SYNOPSIS
Removes a JumpCloud Command Result

## SYNTAX

### warn (Default)
```
Remove-JCCommandResult [-CommandResultID] <String> [<CommonParameters>]
```

### force
```
Remove-JCCommandResult [-CommandResultID] <String> [-force] [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCCommandResult can remove a single JumpCloud command result or multiple command results that are passed to the command over the pipeline. The default behavior is to prompt with a warning message when deleting a command result but this can be suppressed with the -force Parameter.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-JCCommandResult -CommandResultID 5j09o6f23dan6f4n035601d5
```

Removes the JumpCloud Command Result with a CommandResultID of '5j09o6f23dan6f4n035601d5'. A warning message will be presented to confirm this operation.

### Example 2
```powershell
PS C:\> Remove-JCCommandResult -CommandResultID 5j09o6f23dan6f4n035601d5 -Force
```

Removes the JumpCloud Command Result with a CommandResultID of '5j09o6f23dan6f4n035601d5' using the -Force Parameter. A warning message will not be presented to confirm this operation.

### Example 3
```powershell
PS C:\> Get-JCCommandResult  | Where-Object system -EQ 'Server01' | Remove-JCCommandResult
```

Removes all JumpCloud Command Results that were run on target system with a hostname of 'Server01' A warning message will be present to confirm each operation. This warning could be suppressed using the -Force Parameter.

### Example 4
```powershell
PS C:\> Get-JCCommandResult | Where-Object {$_.requestTime -GT (Get-Date).AddHours(-1) -and $_.exitCode -eq 0} | Remove-JCCommandResult -force
```

Removes all JumpCloud commands that were run within the last hour and that had an exitCode of '0' using the -Force Parameter. Note an exitCode of zero generally represents a successful run of a command. This command removes all success Commands Results run in the past hour.

## PARAMETERS

### -CommandResultID
The _id of the JumpCloud Command Result you wish to query.
To find a JumpCloud Command Result run the command: PS C:\\\> Get-JCCommandResult | Select name, _id

The CommandResultID will be the 24 character string populated for the _id field.
CommandResultID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandResultID.
This is shown in EXAMPLES 3 and 4.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -force
A SwitchParameter which removes the warning message when removing a JumpCloud Command Result.

```yaml
Type: System.Management.Automation.SwitchParameter
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
