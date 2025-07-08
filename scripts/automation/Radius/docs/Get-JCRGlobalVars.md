---
external help file: JumpCloud.Radius-help.xml
Module Name: JumpCloud.Radius
online version: /
schema: 2.0.0
---

# Get-JCRGlobalVars

## SYNOPSIS

This function retrieves and updates global variables related to JumpCloud Radius deployment, including user associations and system caches.

## SYNTAX

```
Get-JCRGlobalVars [-force] [-skipAssociation] [-associateManually] [[-associationUsername] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

This function retrieves and updates global variables related to JumpCloud Radius deployment, including user associations and system caches.

## EXAMPLES

### Example 1

```powershell
Get-JCRGlobalVars -force
```

This command forces an update of all cached users, systems, associations, and RADIUS group members.

## PARAMETERS

### -associateManually

Updates the system to user association cache manually using the graph api

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

### -associationUsername

Updates just a single user's associations manually using the graph api

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

### -force

Force update all cached users, systems, associations, radius group members

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

### -skipAssociation

Skips the user to system association cache, which may take a long time on larger organizations

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
