---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCWorkflow

## SYNOPSIS

Returns JumpCloud workflows for the connected organization.

## SYNTAX

### ByAll (Default)
```
Get-JCWorkflow [<CommonParameters>]
```

### ById
```
Get-JCWorkflow [-Id <String>] [<CommonParameters>]
```

### ByName
```
Get-JCWorkflow [-Name <String>] [<CommonParameters>]
```

## DESCRIPTION

Get-JCWorkflow returns all workflows in the connected organization. Use the `-Id` or `-Name` parameters to return a specific workflow.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-JCWorkflow
```

Returns all workflows in the connected organization.

### Example 2

```powershell
PS C:\> Get-JCWorkflow -Id '673dd658ac4a0658c780f9ff'
```

Returns the workflow with the specified id.

## PARAMETERS

### -Id

The id of the workflow to return.

```yaml
Type: System.String
Parameter Sets: ById
Aliases: workflow_id

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name

The name of the workflow to return.

```yaml
Type: System.String
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
