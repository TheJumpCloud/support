---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/New-JCCommand
schema: 2.0.0
---

# New-JCCommand

## SYNOPSIS
Creates a new JumpCloud Mac, Linux, or Windows command

## SYNTAX

```
New-JCCommand [-name] <String> [-commandType] <String> [-command] <String> [[-launchType] <String>]
 [[-timeout] <String>] [-shell <String>] [-user <String>] -trigger <String> [<CommonParameters>]
```

## DESCRIPTION
Creates a new JumpCloud Mac, Linux, or Windows command

## EXAMPLES

### Example 1
```powershell
PS C:\> New-JCCommand -commandType windows -name 'PowerShell version' -command '$PSVersionTable'
```

Creates a JumpCloud windows command named 'PowerShell version' which will return the PowerShell version installed on Windows endpoints when run.

## PARAMETERS

### -command
The script or command to run using the command.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -commandType
The type of JumpCloud command.
Options are windows, mac, or linux.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: windows, mac, linux

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -launchType
The launch type for the new command.
The default is manual.

```yaml
Type: String
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
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -shell
Enter shell type

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: powershell, cmd

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -timeout
The time the command will run before it times out.
The default is 120 seconds.

```yaml
Type: String
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
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -user
Only needed for Mac and Linux commands.
If not entered Mac and Linux commands will default to the root users.
If entering a user a UserID must be entered.

```yaml
Type: String
Parameter Sets: (All)
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
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
