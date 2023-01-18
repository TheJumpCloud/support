---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCSystemApp

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Get-JCSystemApp [[-SystemID] <String>] [[-SystemOS] <String>] [[-SoftwareName] <String>]
 [[-SoftwareVersion] <String>] [[-Search] <String>] [<CommonParameters>]
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

### -Search
Global search ex.
(1.1.2)

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SoftwareName
The name of the application you want to search for ex.
(JumpCloud-Agent, Slack)

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SoftwareVersion
The version of the application you want to search for ex.
(1.1.2)

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemID
The System Id of the system you want to search for applications

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

### -SystemOS
The type (windows, mac, linux) of the JumpCloud Command you wish to search ex.
(Windows, Mac, Linux))

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: Windows, MacOs, Linux

Required: False
Position: 1
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
