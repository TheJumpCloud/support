---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCPolicyGroupTemplateMember

## SYNOPSIS

Retrieves a Policy Group Template's Members

## SYNTAX

### ById

```
Get-JCPolicyGroupTemplateMember -GroupTemplateID <String>
 [<CommonParameters>]
```

### ByName

```
Get-JCPolicyGroupTemplateMember -Name <String> [<CommonParameters>]
```

## DESCRIPTION

Get-JCPolicyGroupTemplateMember returns members of the policy group template in an MTP organization. Policy Group Templates are defined on the MTP level for all organizations to access.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-JCPolicyGroupTemplateMember -GroupTemplateID 670e935fbf700a0001990e7d
```

Retrieves a Policy Group Template with id: 670e935fbf700a0001990e7d policy members

### Example 2

```powershell
PS C:\> Get-JCPolicyGroupTemplateMember -Name "GroupTemplateName"
```

Retrieves a Policy Group Template with name: GroupTemplateName policy members

## PARAMETERS

### -GroupTemplateID

Use the -GroupTemplateID parameter when you want to query a specific group template members.

```yaml
Type: System.String
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of the JumpCloud policy group template to query and return members of

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
