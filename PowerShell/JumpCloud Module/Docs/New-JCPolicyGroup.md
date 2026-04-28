---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# New-JCPolicyGroup

## SYNOPSIS

This endpoint allows you to create a new Policy Group.

## SYNTAX

### CreateExpanded (Default)
```
New-JCPolicyGroup [-Name <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Create
```
New-JCPolicyGroup -Body <IPolicyGroupData> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

New-JCPolicyGroup allows you to create a new Policy Group to add policies to.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-JCPolicyGroup -Name "Windows Policy Group"
```

Creates a policy group with name: "Windows Policy Group"

### Example 2

```powershell
PS C:\> New-JCPolicyGroup -Name "Windows Policy Group" -Description "Windows MDM Policies"
```

Creates a policy group with name: "Windows Policy Group" and description: "Windows MDM Policies"

## PARAMETERS

### -Body
PolicyGroupData

```yaml
Type: JumpCloud.SDK.V2.Models.IPolicyGroupData
Parameter Sets: Create
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name

The name of the policy group to create

```yaml
Type: System.String
Parameter Sets: CreateExpanded
Aliases:

Required: False
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
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

### JumpCloud.SDK.V2.Models.IPolicyGroupData
## OUTPUTS

### JumpCloud.SDK.V2.Models.IPolicyGroup
## NOTES

## RELATED LINKS
