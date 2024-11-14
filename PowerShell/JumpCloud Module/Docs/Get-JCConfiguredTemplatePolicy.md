---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCConfiguredTemplatePolicy

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### ReturnAll (Default)
```
Get-JCConfiguredTemplatePolicy [<CommonParameters>]
```

### ById
```
Get-JCConfiguredTemplatePolicy -ConfiguredTemplatePolicyID <String>
 [<CommonParameters>]
```

### ByName
```
Get-JCConfiguredTemplatePolicy -Name <String> [<CommonParameters>]
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

### -ConfiguredTemplatePolicyID
{{ Fill ConfiguredTemplatePolicyID Description }}

```yaml
Type: System.String
Parameter Sets: ById
Aliases: _id, id

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Retrieves a Configured Policy Templates by Name

```yaml
Type: System.String
Parameter Sets: ByName
Aliases:

Required: True
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
