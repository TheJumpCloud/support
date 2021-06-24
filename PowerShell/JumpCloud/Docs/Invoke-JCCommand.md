---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Invoke-JCCommand
schema: 2.0.0
---

# Invoke-JCCommand

## SYNOPSIS
Triggers a JumpCloud Command to run by calling the trigger associated with the Command.

## SYNTAX

### NoVariables (Default)
```
Invoke-JCCommand [-trigger] <String> -Variable1_name <String> -Variable1_value <String>
 -Variable2_name <String> -Variable2_value <String> [<CommonParameters>]
```

### Variables
```
Invoke-JCCommand [-trigger] <String> [-NumberOfVariables <Int32>] -Variable1_name <String>
 -Variable1_value <String> -Variable2_name <String> -Variable2_value <String> [<CommonParameters>]
```

## DESCRIPTION
In order to use the Invoke-JCCommand the target JumpCloud command must have the Launch Event set to Event type: 'Run on Trigger (webhook)' within the JumpCloud admin console. When a JumpCloud command is set with this value the 'launchType' which is queryable using the command Get-JCCommand will be set to 'trigger'.

## EXAMPLES

### Example 1
```powershell
Invoke-JCCommand -trigger 'GetJCAgentLog'
```

Runs the command with a trigger of 'GetJCAgentLog' on all associated systems associated with this JumpCloud command.

### Example 2
```powershell
Invoke-JCCommand -trigger 'InstallApp' -NumberOfVariables 1 -Variable1_name 'URL' -Variable1_value 'www.pathtoinstallfile.com'
```

Runs the command with a trigger of 'GetJCAgentLog' and passes the variable 'URL' with value 'www.pathtoinstallfile.com' to the JumpCloud command.

### Example 3
```powershell
Get-JCCommand | Where-Object launchType -EQ 'trigger' | Invoke-JCCommand
```

Runs all JumpCloud commands that can be run by the Invoke-JCCommand by passing the -Trigger Parameter over the pipeline using Parameter Binding.

### Example 4
```powershell
Get-JCCommand | Where-Object trigger -Like '*NewMacInstall*' | Invoke-JCCommand
```

Runs all JumpCloud commands with a trigger that matches the expression -like '*NewMacInstall*'. Use this Example to run multiple commands that have a common trigger naming convention.

## PARAMETERS

### -NumberOfVariables
Denotes the number of variables you wish to send to the JumpCloud command.
This parameter creates two dynamic parameters for each variable added.
-Variable_1Name = the variable name -Variable1_Value = the value to pass.
See EXAMPLE 2 above for full syntax.

```yaml
Type: System.Int32
Parameter Sets: Variables
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -trigger
When creating a JumpCloud command that can be run via the Invoke-JCCommand function the command must be configured for 'Launch Event - Event type: Run on Trigger (webhook)' During command configuration a 'Trigger Name' is required.
The value of this trigger name is what must be populated when using the Invoke-JCCommand function.
To find all JumpCloud Command triggers run: PS C:\\\> Get-JCCommand | Where-Object launchType -EQ 'trigger'  | Select-Object name, trigger

You can leverage the pipeline and Parameter Binding to populate the -trigger Parameter.
This is shown in EXAMPLES 2 and 3.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Variable1_name
Enter a variable name

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Variable1_value
Enter the Variables value

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Variable2_name
Enter a variable name

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Variable2_value
Enter the Variables value

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

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
