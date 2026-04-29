---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Set-JCPolicyGroup

## SYNOPSIS

This endpoint allows you to do a full update of the Policy Group.

## SYNTAX

### SetExpanded (Default)
```
Set-JCPolicyGroup -Id <String> [-Name <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Set
```
Set-JCPolicyGroup -Id <String> -Body <IPolicyGroupData> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### SetViaIdentity
```
Set-JCPolicyGroup -InputObject <IJumpCloudApiIdentity> -Body <IPolicyGroupData>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SetViaIdentityExpanded
```
Set-JCPolicyGroup -InputObject <IJumpCloudApiIdentity> [-Name <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Set-JCPolicyGroup sets a policy group's description and "newName"

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-JCPolicyGroup -Name "Policy Group Name" -NewName "New Policy Group"
```

Sets the policy group with name: "Policy Group Name" to: "New Policy Group"

### Example 2

```powershell
PS C:\> Set-JCPolicyGroup -PolicyGroupID "671aa7190133c4000119e158" -NewName "New Policy Group"
```

Sets the policy group with id: "671aa7190133c4000119e158" to: "New Policy Group"

### Example 2

```powershell
PS C:\> Set-JCPolicyGroup -PolicyGroupID "671aa7190133c4000119e158" -Description "A group of Windows policies"
```

Sets the policy group with id: "671aa7190133c4000119e158" and it's description to: "A group of Windows policies"

## PARAMETERS

### -Body
PolicyGroupData

```yaml
Type: JumpCloud.SDK.V2.Models.IPolicyGroupData
Parameter Sets: Set, SetViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Id
ObjectID of the Policy Group.

```yaml
Type: System.String
Parameter Sets: SetExpanded, Set
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Identity Parameter

```yaml
Type: JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
Parameter Sets: SetViaIdentity, SetViaIdentityExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name

The Name of the JumpCloud policy group you wish to set.

```yaml
Type: System.String
Parameter Sets: SetExpanded, SetViaIdentityExpanded
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

### JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
### JumpCloud.SDK.V2.Models.IPolicyGroupData
## OUTPUTS

### JumpCloud.SDK.V2.Models.IPolicyGroup
## NOTES

## RELATED LINKS
