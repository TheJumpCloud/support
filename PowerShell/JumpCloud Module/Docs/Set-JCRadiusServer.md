---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Set-JCRadiusServer
schema: 2.0.0
---

# Set-JCRadiusServer

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### ById (Default)
```
Set-JCRadiusServer [-Force] [-Id] <String[]> [[-newName] <String>] [[-networkSourceIp] <String>]
 [[-sharedSecret] <String>] [<CommonParameters>]
```

### ByName
```
Set-JCRadiusServer [-Force] [-Name] <String[]> [[-newName] <String>] [[-networkSourceIp] <String>]
 [[-sharedSecret] <String>] [<CommonParameters>]
```

### ByValue
```
Set-JCRadiusServer [-Force] [[-newName] <String>] [[-networkSourceIp] <String>] [[-sharedSecret] <String>]
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

### -Force
Bypass user prompts and dynamic ValidateSet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Id
The unique id of the object.

```yaml
Type: String[]
Parameter Sets: ById
Aliases: _id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the object.

```yaml
Type: String[]
Parameter Sets: ByName
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -networkSourceIp
The ip of the new Radius Server.

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

### -newName
The new name of the Radius Server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -sharedSecret
The shared secret for the new Radius Server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Management.Automation.SwitchParameter

### System.String[]

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
