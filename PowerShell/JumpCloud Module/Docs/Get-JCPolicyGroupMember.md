---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCPolicyGroupMember

## SYNOPSIS

This function will return the policies that are members of the specified policy group.

## SYNTAX

### ById
```
Get-JCPolicyGroupMember -PolicyGroupID <String> [<CommonParameters>]
```

### ByName
```
Get-JCPolicyGroupMember -Name <String> [<CommonParameters>]
```

## DESCRIPTION

Get-JCPolicyGroupMember will return policies which are members of the specified policy group.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-JCPolicyGroupMember -PolicyGroupID 66c3a774294f1e9071f080c9
```

This will return all policies that are members of the policy group with id: '66c3a774294f1e9071f080c9'

### Example 2

```powershell
PS C:\> Get-JCPolicyGroupMember -Name "PolicyGroupName"
```

This will return all policies that are members of the policy group with name: 'PolicyGroupName'

## PARAMETERS

### -Name

Retrieves a Configured Policy Templates by Name

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

The ID of the JumpCloud policy group to query and return members of

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
