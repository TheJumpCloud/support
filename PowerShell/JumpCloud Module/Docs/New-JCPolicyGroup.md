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

### FromTemplateID

```
New-JCPolicyGroup -TemplateID <String> [<CommonParameters>]
```

### Name

```
New-JCPolicyGroup -Name <String> [-Description <String>]
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

### -Description

The description of the policy group to create

```yaml
Type: System.String
Parameter Sets: Name
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of the policy group to create

```yaml
Type: System.String
Parameter Sets: Name
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateID

The Policy Template ID to apply to this MTP org.
This parameter will only work in MTP organizations

```yaml
Type: System.String
Parameter Sets: FromTemplateID
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

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
