---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Set-JCCommand
schema: 2.0.0
---

# Set-JCCommand

## SYNOPSIS
Updates an existing JumpCloud command

## SYNTAX

```
Set-JCCommand [-CommandID] <String> [[-name] <String>] [[-command] <String>] [[-launchType] <String>]
 [[-timeout] <String>] -trigger <String> [<CommonParameters>]
```

## DESCRIPTION
Updates an existing JumpCloud command using the CommandID

## EXAMPLES

### Example 1
```powershell
Set-JCCommand -CommandID 5g6o3lf95r1485193o8cks6 -launchType trigger -trigger getWinLog
```

Updates the 'launchType' of command with CommandID '5g6o3lf95r1485193o8cks6' to trigger and sets the 'trigger' to getWinLog.

### Example 2
```powershell
Set-JCCommand -CommandID 5g6o3lf95r1485193o8cks6 -name "Windows - Get Windows Event Log"
```

Updates the 'name' of command with CommandID '5g6o3lf95r1485193o8cks6' to "Windows - Get Windows Event Log".

## PARAMETERS

### -CommandID
The _id of the JumpCloud command you wish to update.

To find a JumpCloud CommandID run the command:

PS C:\\\> Get-JCCommand | Select name, _id

The CommandID will be the 24 character string populated for the _id field.

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

### -command
The actual script or command.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -launchType
The launch type of the command options are: trigger, manual, repeated, one-time.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: trigger, manual

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -name
The name of the new JumpCloud command.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -timeout
The time the command will run before it times out.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -trigger
Enter a trigger name.
Triggers must be unique

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
