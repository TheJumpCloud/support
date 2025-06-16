---
external help file: JumpCloud.Radius-help.xml
Module Name: JumpCloud.Radius
online version: /
schema: 2.0.0
---

# Start-GenerateUserCerts

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### gui (Default)
```
Start-GenerateUserCerts [<CommonParameters>]
```

### cli
```
Start-GenerateUserCerts -type <String> [-username <String>] [-forceReplaceCerts]
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

### -forceReplaceCerts
When specified, this parameter will replace certificates if they already exist on the current filesystem

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
Type of certificate to initialize.
To generate all new certificates for existing users, specify "all", To generate certificates for users who have not yet had certificates generated, specify "new".
To generate certificates by an individual, speficy "ByUsername" and populate the "username" parameter.
To generate certificates for users who have certificates expiring in 15 days or less, specify "ExpiringSoon".

```yaml
Type: System.String
Parameter Sets: cli
Aliases:
Accepted values: All, New, ByUsername, ExpiringSoon

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -username
The JumpCloud username of an individual user

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
