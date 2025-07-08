---
external help file: JumpCloud.Radius-help.xml
Module Name: JumpCloud.Radius
online version: /
schema: 2.0.0
---

# Start-GenerateRootCert

## SYNOPSIS

This function generates a root certificate for the JumpCloud Radius module, allowing you to create or replace the root certificate as needed.

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

This function generates a root certificate for the JumpCloud Radius module. It allows you to specify whether to create a new certificate, replace an existing one, or renew the current certificate. The function can also handle the root certificate key password and force replacement of existing certificates if specified.

## EXAMPLES

### Example 1

```powershell
Start-GenerateRootCert -generateType "New" -certKeyPassword "your_password" -force
```

This command generates a new root certificate for the JumpCloud Radius module, using the specified key password and forcing replacement of any existing certificates.

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
