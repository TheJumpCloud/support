---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCCommandResult
schema: 2.0.0
---

# Get-JCCommandResult

## SYNOPSIS
Returns all JumpCloud Command Results within a JumpCloud tenant or a single JumpCloud Command Result using the -ByID Parameter.

## SYNTAX

### ReturnAll (Default)
```
Get-JCCommandResult [<CommonParameters>]
```

### ByID
```
Get-JCCommandResult [-CommandResultID] <String> [<CommonParameters>]
```

### ByCommandID
```
Get-JCCommandResult [-CommandID <String>] [-ByCommandID]
 [<CommonParameters>]
```

### Detailed
```
Get-JCCommandResult [-Detailed] [<CommonParameters>]
```

### TotalCount
```
Get-JCCommandResult [-TotalCount] [<CommonParameters>]
```

## DESCRIPTION
The Get-JCCommandResult function returns all command results within a JumpCloud tenant. To return the command results output the -ByID Parameter must be used as this information is only accessible when using this Parameter.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCCommandResult
```

Returns all JumpCloud Commands Results

### Example 2
```powershell
PS C:\> Get-JCCommandResult -CommandResultID 5m0o65m6i4sb973059omb762
```

Returns a single JumpCloud Command Result with CommandResultID '5j09o6f23dan6f4n035601d5'. Note that the command results output will be present in the output from this command.

### Example 3
```powershell
PS C:\> Get-JCCommandResult -CommandID 6307e611baab9f408ff17eb9
```

Returns all JumpCloud Command Result corresponding to the JumpCloud Command with ID: '6307e611baab9f408ff17eb9'. Note that the command results output will be present in the output from this command.

### Example 4
```powershell
PS C:\> Get-JCComand -Name "GetJCAgentLog" | Get-JCCommandResult -ByCommandID
```

Returns all JumpCloud Commands with the name "GetJCAgentLog", and pipes the output to Get-JCComandResult. The "-ByCommandID" switch will flag the command to get the results for each commandID passed in. Multiple commands can be piped into the function.

### Example 5
```powershell
PS C:\> Get-JCCommandResult | Where-Object {$_.requestTime -GT (Get-Date).AddDays(-7) -and $_.exitCode -ne 0}
```

Returns all JumpCloud Command Result that were run within the last seven days and that did not return an exitCode of '0'. Note an exitCode of zero generally represents a successful run of a command. This command returns all failed commands results for the past seven days.

### Example 6
```powershell
PS C:\> Get-JCCommandResult -Detailed | Where-Object requestTime -GT (Get-Date).AddHours(-1) | Select-Object -ExpandProperty output
```

Returns the output for all JumpCloud Command results that were run within the last hour using the -ByID Parameter and Parameter Binding.

Note that when running this command the time for the output to display will be directly proportionate to how many JumpCloud commands that match the criteria. The command 'Get-JCCommandResult -Detailed' runs once for every JumpCloud command result that matches the criteria Where-Object criteria.

### Example 7
```powershell
PS C:\> Get-JCCommandResult -TotalCount
```

Returns the total number of JumpCloud command results

## PARAMETERS

### -ByCommandID
Use the -ByCommandID or -ByWorkflowID parameter when you want to query the results of a specific Command. The -ByCommandID or -ByWorkflowID SwitchParameter will set the ParameterSet to 'ByCommandID' which queries all JumpCloud Command Results for that particular Command.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: ByCommandID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -CommandID
The _id of the JumpCloud Command you wish to query.

```yaml
Type: System.String
Parameter Sets: ByCommandID
Aliases: WorkflowID

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -CommandResultID
The _id of the JumpCloud Command Result you wish to query.

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Detailed
A switch parameter to return the detailed output of each command result

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Detailed
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TotalCount
A switch parameter to only return the number of command results.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: TotalCount
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
### System.Management.Automation.SwitchParameter
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
