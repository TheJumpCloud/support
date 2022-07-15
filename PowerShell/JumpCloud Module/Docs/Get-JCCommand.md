---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCCommand
schema: 2.0.0
---

# Get-JCCommand

## SYNOPSIS
Returns all JumpCloud Commands within a JumpCloud tenant or a single JumpCloud Command using the -ByID Parameter.

## SYNTAX

### SearchFilter (Default)
```
Get-JCCommand [-command <String>] [-name <String>] [-commandType <String>] [-launchType <String>]
 [-trigger <String>] [-scheduleRepeatType <String>] [-returnProperties <String[]>] [<CommonParameters>]
```

### ByID
```
Get-JCCommand [-CommandID] <String[]> [-ByID] [<CommonParameters>]
```

## DESCRIPTION
The Get-JCCommand function returns all information describing a JumpCloud command. To find the contents and payload of a specific command the -ByID Parameter must be used as this information is only accessible when using this Parameter.
Note: String parameters are case-insensitive

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCCommand
```

Returns all JumpCloud Commands populated within the Commands section of the JumpCloud admin console.

### Example 2
```powershell
PS C:\> Get-JCCommand -CommandID 5j09o6f23dan6f4n035601d5
```

Returns a single JumpCloud command with CommandID '5j09o6f23dan6f4n035601d5'. Note that the contents of the command will be present in the output from this command.

### Example 3
```powershell
PS C:\> Get-JCCommand | Get-JCCommand -ByID
```

Returns all information describing all JumpCloud commands by passing the -CommandID Parameter to the -ByID Parameter using the pipeline and Parameter Binding.

Note that when running this command the time for the output to display will be directly proportionate to how many JumpCloud commands you have. The command 'Get-JCCommand -ByID' runs once for every JumpCloud command within your tenant.

### Example 4
```powershell
PS C:\> Get-JCCommand -name '*BitLocker*' | Get-JCCommand -ByID
```

Returns all information describing all JumpCloud commands with a name of '*BitLocker*' by passing the -CommandID Parameter to the -ByID Parameter using the pipeline and Parameter Binding. Note, search parameters on Get-JCCommand support wildcard characters. In this example commands with the string "BitLocker" somewhere in the name would be returned.

### Example 5
```powershell
PS C:\> Get-JCCommand -launchType 'trigger' | Get-JCCommand -ByID
```

Returns all information describing all JumpCloud commands with a launchType of 'trigger' by passing the -CommandID Parameter to the -ByID Parameter using the pipeline and Parameter Binding.

Note that when running this command the time for the output to display will be directly proportionate to how many JumpCloud commands you have with a launchType of 'trigger'. The command 'Get-JCCommand -ByID' runs once for every JumpCloud command within your tenant with a launchType of 'trigger'. LaunchType 'trigger' or 'Trigger' will return the same information due to case-insensitivity

### Example 6
```powershell
PS C:\> Get-JCCommand -command '*fdesetup*' | Get-JCCommand -ByID
```

Returns all information describing all JumpCloud commands with a command string and the search term "*fdesetup*", by passing the -CommandID Parameter to the -ByID Parameter using the pipeline and Parameter Binding. Note, search parameters on Get-JCCommand support wildcard characters. In this example commands with the string "fdesetup" somewhere in the command body would be returned.

## PARAMETERS

### -ByID
Use the -ByID parameter when you want to query the contents of a specific command or if the -CommandID is being passed over the pipeline to return the full contents of a JumpCloud command.
The -ByID SwitchParameter will set the ParameterSet to 'ByID' which queries one JumpCloud command at a time.

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

### -command
The command to execute on the server.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CommandID
The _id of the JumpCloud command you wish to query.

To find a JumpCloud CommandID run the command:

PS C:\\\> Get-JCCommand | Select name, _id

The CommandID will be the 24 character string populated for the _id field.

CommandID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandID.
This is shown in EXAMPLES  3 and 4.

```yaml
Type: System.String[]
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -commandType
Command Type

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:
Accepted values: windows, mac, linux

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -launchType
Launch Type

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:
Accepted values: repeated, one-time, manual, trigger

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -name
Name of the command

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -returnProperties
Allows you to return select properties on JumpCloud user objects. Specifying what properties are returned can drastically increase the speed of the API call with a large data set. Valid properties that can be returned are: 'command', 'name','commandType', 'launchType','listensTo','schedule','trigger','scheduleRepeatType','organization'

```yaml
Type: System.String[]
Parameter Sets: SearchFilter
Aliases:
Accepted values: command, name, launchType, commandType, trigger, scheduleRepeatType

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -scheduleRepeatType
When the command will repeat

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:
Accepted values: minute, hour, day, week, month

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -trigger
The name of the command trigger

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.String[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
