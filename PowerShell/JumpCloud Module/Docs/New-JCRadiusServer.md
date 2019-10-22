---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/New-JCRadiusServer
schema: 2.0.0
---

# New-JCRadiusServer

## SYNOPSIS
Creates a JumpCloud radius server.

## SYNTAX

```
New-JCRadiusServer [-Force] [-Name] <String[]> [-networkSourceIp] <String> [[-sharedSecret] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Use this function to create a radius servers in a JumpCloud tenet.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-JCRadiusServer -Name:('RadiusServer1') -networkSourceIp:('111.111.111.111') -sharedSecret:('dUtU9FDvPc8Wdvoc#jKmZr7aJSXv5pR')
```

Create a radius server in a JumpCloud tenet.

## PARAMETERS

### -Force
Bypass user prompts and dynamic ValidateSet.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the object.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -networkSourceIp
The ip of the new Radius Server.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -sharedSecret
The shared secret for the new Radius Server.

```yaml
Type: System.String
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
