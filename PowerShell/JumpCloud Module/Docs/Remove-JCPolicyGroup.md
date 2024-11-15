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

### ByName
```
Remove-JCPolicyGroup -Name <String> [-Force] [<CommonParameters>]
```

### ByID
```
Remove-JCPolicyGroup -PolicyGroupID <String> [-Force] [<CommonParameters>]
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

### -Force

A SwitchParameter which suppresses the warning message when removing a JumpCloud Policy.

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

### -Name

The Name of the JumpCloud policy group you wish to remove.

```yaml
Type: System.String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyGroupID

The ID of the JumpCloud policy group you wish to remove.

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: Named
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
