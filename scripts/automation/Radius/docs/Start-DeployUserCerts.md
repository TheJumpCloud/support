---
external help file: JumpCloud.Radius-help.xml
Module Name: JumpCloud.Radius
online version: /
schema: 2.0.0
---

# Start-DeployUserCerts

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### gui (Default)
```
Start-DeployUserCerts [<CommonParameters>]
```

### cli
```
Start-DeployUserCerts -type <String> [-username <String>] [-forceInvokeCommands] [-forceGenerateCommands]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -forceGenerateCommands
Switch to force generate new commands on systems

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: cli
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -forceInvokeCommands
Switch to force invoke generated commands on systems

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: cli
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -type
Type of cert deployment to initiate

```yaml
Type: System.String
Parameter Sets: cli
Aliases:
Accepted values: All, New, ByUsername

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -username
The JumpCloud username of a user to deploy a certificate

```yaml
Type: System.String
Parameter Sets: cli
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

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
