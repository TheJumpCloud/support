---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# New-JCReport

## SYNOPSIS
Request a JumpCloud report to be generated asynchronously

## SYNTAX

### Create (Default)
```
New-JCReport -ReportType <Object> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### CreateViaIdentity
```
New-JCReport -InputObject <IDirectoryInsightsApiIdentity> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Request a JumpCloud report to be generated asynchronously

## EXAMPLES

### EXAMPLE 1
```
New-JCReport -ReportType 'users-to-sso-applications'
```

Queues creation of an user-to-sso-application report

### EXAMPLE 2
```
New-JCReport -ReportType 'users-to-devices'
```

Queues creation of an users-to-devices report

## PARAMETERS

### -InputObject
Identity Parameter
To construct, see NOTES section for INPUTOBJECT properties and create a hash table.

```yaml
Type: JumpCloud.SDK.DirectoryInsights.Models.IDirectoryInsightsApiIdentity
Parameter Sets: CreateViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ReportType
Report Type

```yaml
Type: System.Object
Parameter Sets: Create
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IDirectoryInsightsApiIdentity
## OUTPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IPathsE6Q3GdReportsReportTypePostResponses202ContentApplicationJsonSchema
## NOTES
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties.
For information on hash tables, run Get-Help about_Hash_Tables.

INPUTOBJECT \<IDirectoryInsightsApiIdentity\>: Identity Parameter
  \[ReportType \<ReportType1?\>\]: Report Type

## RELATED LINKS

[https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/New-JcSdkReport.md](https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/New-JcSdkReport.md)
