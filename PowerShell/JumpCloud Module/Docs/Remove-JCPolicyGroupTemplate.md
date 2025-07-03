---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Remove-JCPolicyGroupTemplate

## SYNOPSIS

Deletes a Policy Group Template

## SYNTAX

### ByName
```
Remove-JCPolicyGroupTemplate -Name <String> [-Force] [<CommonParameters>]
```

### ByID
```
Remove-JCPolicyGroupTemplate -GroupTemplateID <String> [-Force]
 [<CommonParameters>]
```

## DESCRIPTION

Remove-JCPolicyGroupTemplate deletes policy group templates defined in an MTP organization. Policy Group Templates are defined on the MTP level for all organizations to access.

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-JCPolicyGroupTemplate -GroupTemplateID "64022e24f7763b2295302342"
```

Removes the Policy Group Template with id: 64022e24f7763b2295302342

### Example 2

```powershell
PS C:\> Remove-JCPolicyGroupTemplate -name "PolicyGroupName"
```

Removes the Policy Group Template with name: PolicyGroupName

## PARAMETERS

### -Force

A SwitchParameter which suppresses the warning message when removing a JumpCloud policy group template.

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

### -GroupTemplateID

The ID of the JumpCloud policy group template you wish to remove.

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

### -Name

The Name of the JumpCloud policy group template you wish to remove.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
