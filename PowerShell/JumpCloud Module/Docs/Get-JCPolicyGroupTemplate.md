---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCPolicyGroupTemplate

## SYNOPSIS

Returns the policy group templates for an MTP organization

## SYNTAX

### ReturnAll (Default)
```
Get-JCPolicyGroupTemplate [<CommonParameters>]
```

### ByName
```
Get-JCPolicyGroupTemplate -Name <String> [<CommonParameters>]
```

### ByID
```
Get-JCPolicyGroupTemplate -GroupTemplateID <String> [<CommonParameters>]
```

## DESCRIPTION

Get-JCPolicyGroupTemplate requires an administrator be connected to an MTP organization. Policy Group Templates are defined on the MTP level for all organizations to access.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-JCPolicyGroupTemplate
```

Returns all available Policy Group Templates in the MTP Organization

### Example 2

```powershell
PS C:\> Get-JCPolicyGroupTemplate -Name "PolicyGroupTemplateName"
```

Gets the policy group template with name: PolicyGroupTemplateName

### Example 3

```powershell
PS C:\> Get-JCPolicyGroupTemplate -GroupTemplateID 6733de990662210001e76bcc
```

Gets the policy group template with id: 6733de990662210001e76bcc

## PARAMETERS

### -GroupTemplateID

Use the -GroupTemplateID parameter when you want to query a specific group template.

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The Name of the JumpCloud policy group you wish to query. This value is case sensitive

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

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
