---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# New-JCWorkflow

## SYNOPSIS
Creates a new JumpCloud workflow.

## SYNTAX

```
New-JCWorkflow [-Name] <String> [-ExecutionRoleId] <String> [-Dsl] <Object> [[-Description] <String>]
 [[-Status] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
New-JCWorkflow creates a new workflow in the connected JumpCloud organization.

## EXAMPLES

### EXAMPLE 1
```
$dsl = @{ trigger = @{ type = 'external' }; actions = @( @{ type = 'getApiSystemusers' } ) }
PS C:\> New-JCWorkflow -Name "My Workflow" -ExecutionRoleId "64a2f2...123" -Dsl $dsl
```

Creates a new active workflow named "My Workflow".

## PARAMETERS

### -Name
The name of the workflow.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ExecutionRoleId
The Role ID used to identify the workflow execution.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Dsl
JSON definition of the workflow DSL.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Description
The description of the workflow.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Status
Status of the workflow.
Valid values are 'active' or 'inactive'.
Default is 'active'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Active
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
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
