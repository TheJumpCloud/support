---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Get-JCCommandResult

## SYNOPSIS

Returns all JumpCloud Command Results within a JumpCloud tenant or a single JumpCloud Command Result using the -ByID Parameter.

## SYNTAX

### ReturnAll (Default)

```PowerShell
Get-JCCommandResult
```

### ByID

```PowerShell
Get-JCCommandResult [-CommandResultID] <String[]> [-ByID]
```

## DESCRIPTION

The Get-JCCommandResult function returns all command results within a JumpCloud tenant. To return the command results output the -ByID Parameter must be used as this information is only accessible when using this Parameter.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Get-JCCommandResult
```

Returns all JumpCloud Commands Results

### Example 2

```PowerShell
PS C:\> Get-JCCommandResult -CommandResultID 5m0o65m6i4sb973059omb762

```

Returns a single JumpCloud Command Result with CommandResultID '5j09o6f23dan6f4n035601d5'. Note that the command results output will be present in the output from this command.

### Example 3

```PowerShell
PS C:\> Get-JCCommandResult | Where-Object {$_.requestTime -GT (Get-Date).AddDays(-7) -and $_.exitCode -ne 0}

```

Returns all JumpCloud Command Result that were run within the last seven days and that did not return an exitCode of '0'. Note an exitCode of zero generally represents a successful run of a command. This command returns all failed commands results for the past seven days.

### Example 4

```PowerShell
PS C:\> Get-JCCommandResult | Where-Object requestTime -GT (Get-Date).AddHours(-1) |  Get-JCCommandResult -ByID  | Select-Object -ExpandProperty output

```

Returns the output for all JumpCloud Command results that were run within the last hour using the -ByID Parameter and Parameter Binding.

Note that when running this command the time for the output to display will be directly proportionate to how many JumpCloud commands that match the criteria. The command 'Get-JCCommandResult -ByID' runs once for every JumpCloud command result that matches the criteria Where-Object criteria.

## PARAMETERS

### -ByID

Use the -ByID parameter when you want to query the contents of a specific Command Result or if the -CommandResultID is being passed over the pipeline to return the full contents of a JumpCloud Command Result. The -ByID SwitchParameter will set the ParameterSet to 'ByID' which queries one JumpCloud Command Result at a time.

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

### -CommandResultID

The _id of the JumpCloud Command Result you wish to query.

To find a JumpCloud Command Result run the command:

```PowerShell
PS C:\> Get-JCCommandResult | Select name, _id
```

The CommandResultID will be the 24 character string populated for the _id field.

CommandResultID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandResultID. This is shown in EXAMPLES 3 and 4.

```yaml
Type: String[]
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

### System.String[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
