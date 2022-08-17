---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Set-JCSettingsFile

## SYNOPSIS

Updates the JumpCloud Module Settings File

## SYNTAX

```
Set-JCSettingsFile [-parallelOverride <Boolean>] [-moduleBannerMessageCount <Int64>] [<CommonParameters>]
```

## DESCRIPTION

The Set-JCSettingsFile function updates an the JumpCloud Module settings file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-JCSettingsFile -ParallelOverride $true
```

Disables parallel processing of results in the JumpCloud PowerShell Module

## PARAMETERS

### -moduleBannerMessageCount

sets the messageCount settings for the moduleBanner feature

```yaml
Type: System.Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -parallelOverride

sets the Override settings for the parallel feature

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:
Accepted values: true, false

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
