---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# Get-JCPolicyResult

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### ByPolicyName (Default)
```
Get-JCPolicyResult [-PolicyName] <String> [<CommonParameters>]
```

### ByPolicyID
```
Get-JCPolicyResult [-PolicyID] <String> [<CommonParameters>]
```

### BySystemID
```
Get-JCPolicyResult [-SystemID <String>] [<CommonParameters>]
```

### ByPolicyResultID
```
Get-JCPolicyResult [-PolicyResultID <String>] [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -PolicyID
{{Fill PolicyID Description}}

```yaml
Type: String
Parameter Sets: ByPolicyID
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PolicyName
{{Fill PolicyName Description}}

```yaml
Type: String
Parameter Sets: ByPolicyName
Aliases: name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PolicyResultID
{{Fill PolicyResultID Description}}

```yaml
Type: String
Parameter Sets: ByPolicyResultID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemID
{{Fill SystemID Description}}

```yaml
Type: String
Parameter Sets: BySystemID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
