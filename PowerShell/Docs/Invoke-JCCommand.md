---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Invoke-JCCommand

## SYNOPSIS

Triggers a JumpCloud Command to run by calling the trigger associated with the Command.

## SYNTAX

```PowerShell
Invoke-JCCommand [-trigger] <String>
```

## DESCRIPTION

In order to use the Invoke-JCCommand the target JumpCloud command must have the Launch Event set to Event type: 'Run on Trigger (webhook)' within the JumpCloud admin console. When a JumpCloud command is set with this value the 'launchType' which is queryable using the command Get-JCCommand will be set to 'trigger'.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Invoke-JCCommand -trigger 'GetJCAgentLog'
```

Runs the command with a trigger of 'GetJCAgentLog' on all associated systems associated with this JumpCloud command.

### Example 2

```PowerShell
PS C:\> Get-JCCommand | Where-Object launchType -EQ 'trigger' | Invoke-JCCommand

```

Runs all JumpCloud commands that can be run by the Invoke-JCCommand by passing the -Trigger Parameter over the pipeline using Parameter Binding.

### Example 3

```PowerShell
PS C:\> Get-JCCommand | Where-Object trigger -Like '*NewMacInstall*' | Invoke-JCCommand

```

Runs all JumpCloud commands with a trigger that matches the expression -like '*NewMacInstall*'. Use this Example to run multiple commands that have a common trigger naming convention.

## PARAMETERS

### -trigger

When creating a JumpCloud command that can be run via the Invoke-JCCommand function the command must be configured for 'Launch Event - Event type: Run on Trigger (webhook)'
During command configuration a 'Trigger Name' is required. The value of this trigger name is what must be populated when using the Invoke-JCCommand function.

To find all JumpCloud Command triggers run:

```PowerShell
PS C:\> Get-JCCommand | Where-Object launchType -EQ 'trigger'  | Select-Object name, trigger
```

You can leverage the pipeline and Parameter Binding to populate the -trigger Parameter. This is shown in EXAMPLES 2 and 3.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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
