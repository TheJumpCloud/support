---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# Get-JCWorkflow

## SYNOPSIS
Returns JumpCloud workflows for the connected organization.

## SYNTAX

### ByAll (Default)
```
Get-JCWorkflow [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ById
```
Get-JCWorkflow -Id <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ByName
```
Get-JCWorkflow -Name <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-JCWorkflow returns all workflows in the connected organization.
Use the -Id parameter to return a single workflow from the GET endpoint.
Use the -Name parameter to search workflows returned from the LIST endpoint.

## EXAMPLES

### EXAMPLE 1
```
Get-JCWorkflow
```

Returns all workflows in the connected organization.

### EXAMPLE 2
```
Get-JCWorkflow -Id '673dd658ac4a0658c780f9ff'
```

Returns the workflow with the specified id.

## PARAMETERS

### -Id
The id of the workflow to return.

```yaml
Type: String
Parameter Sets: ById
Aliases: workflow_id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the workflow to return.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProgressAction

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
