---
external help file: JumpCloud.Radius-help.xml
Module Name: JumpCloud.Radius
online version: /
schema: 2.0.0
---

# Start-GenerateRootCert

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### gui (Default)
```
Start-GenerateRootCert [<CommonParameters>]
```

### cli
```
Start-GenerateRootCert [-certKeyPassword <String>] [-generateType <String>] [-force]
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

### -certKeyPassword
The root certificate key password

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

### -force
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

### -generateType
Select an option to generate or replace the root certificate

```yaml
Type: System.String
Parameter Sets: cli
Aliases:
Accepted values: New, Replace, Renew

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
