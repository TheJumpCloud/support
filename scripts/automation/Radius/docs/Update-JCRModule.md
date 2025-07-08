---
external help file: JumpCloud.Radius-help.xml
Module Name: JumpCloud.Radius
online version: /
schema: 2.0.0
---

# Update-JCRModule

## SYNOPSIS

This function updates the JumpCloud Radius module, ensuring that the latest configurations and settings are applied.

## SYNTAX

```
Update-JCRModule [-Force] [[-Repository] <String>] [<CommonParameters>]
```

## DESCRIPTION

This function will check if there are any updates available for the JumpCloud Radius module and apply them if necessary. It can also bypass user prompts if the `-Force` parameter is specified.

## EXAMPLES

### Example 1

```powershell
Update-JCRModule -Force
```

This command forces the update of the JumpCloud Radius module without any user prompts.

## PARAMETERS

### -Force

ByPasses user prompts.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repository

Set the PSRepository

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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
