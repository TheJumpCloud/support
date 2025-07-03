---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCPolicyGroup

## SYNOPSIS

Returns all policy groups, policy groups by name or id.

## SYNTAX

### ReturnAll (Default)
```
Get-JCPolicyGroup [<CommonParameters>]
```

### ByName
```
Get-JCPolicyGroup -Name <String> [<CommonParameters>]
```

### ById
```
Get-JCPolicyGroup -PolicyGroupID <String> [<CommonParameters>]
```

## DESCRIPTION

Get-JCPolicyGroup will return all policy groups for a given organization by default. If either the 'name' or 'PolicyGroupId' parameters are specified, the function will attempt to find policy groups by name or id.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-JCPolicyGroup
```

Returns all JumpCloud policy groups

### Example 2

```powershell
PS C:\> Get-JCPolicyGroup -Name "PolicyGroupName"
```

Returns the policy group with name 'PolicyGroupName'

### Example 3

```powershell
PS C:\> Get-JCPolicyGroup -PolicyGroupId "66c3a774294f1e9071f080c9"
```

Returns the policy group with id '66c3a774294f1e9071f080c9'

## PARAMETERS

### -Name

The Name of the JumpCloud policy group you wish to query.

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

The ID of the JumpCloud policy group you wish to query

```yaml
Type: System.String
Parameter Sets: ById
Aliases: _id, id

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
