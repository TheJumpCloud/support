---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# New-JCWorkflow

## SYNOPSIS

Creates a new JumpCloud workflow.

## SYNTAX

```
New-JCWorkflow [-Name] <String> [[-Description] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

New-JCWorkflow creates a workflow in the connected organization using the JumpCloud Workflows API.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-JCWorkflow -Name 'Onboarding Workflow'
```

Creates a workflow with the specified name.

### Example 2

```powershell
PS C:\> New-JCWorkflow -Name 'Onboarding Workflow' -Description 'Automates onboarding tasks'
```

Creates a workflow with the specified name and description.

## PARAMETERS

### -Description
The description of the workflow.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The name of the workflow.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
