---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Remove-JCPolicyGroup

## SYNOPSIS

This endpoint allows you to delete a Policy Group.

## SYNTAX

### Delete (Default)
```
Remove-JCPolicyGroup -Id <String> [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### DeleteViaIdentity
```
Remove-JCPolicyGroup -InputObject <IJumpCloudApiIdentity> [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Remove-JCPolicyGroup deletes a policy group by name or id.

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-JCPolicyGroup -Name "Policy Group Name"
```

Removes a policy group with name: "Policy Group Name", the cmdlet will prompt before deleting the group

### Example 2

```powershell
PS C:\> Remove-JCPolicyGroup -Name "Policy Group Name" -Force
```

Removes a policy group with name: "Policy Group Name", the cmdlet will not prompt before deleting the group

### Example 2

```powershell
PS C:\> Remove-JCPolicyGroup -PolicyGroupID "66ace9082dfb9356f460bee4" -Force
```

Removes a policy group with id: "66ace9082dfb9356f460bee4", the cmdlet will not prompt before deleting the group

## PARAMETERS

### -Id
ObjectID of the Policy Group.

```yaml
Type: System.String
Parameter Sets: Delete
Aliases: _id, PolicyGroupID

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
Parameter Sets: DeleteViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PassThru
Returns true when the command succeeds

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
## OUTPUTS

### JumpCloud.SDK.V2.Models.IPolicyGroup
## NOTES

## RELATED LINKS
