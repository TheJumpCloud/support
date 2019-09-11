---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCPolicyTargetGroup
schema: 2.0.0
---

# Get-JCPolicyTargetGroup

## SYNOPSIS
Returns all bound groups associated with a JumpCloud Policy within a JumpCloud tenant.

## SYNTAX

### ById (Default)
```
Get-JCPolicyTargetGroup [-PolicyID] <String> [<CommonParameters>]
```

### ByName
```
Get-JCPolicyTargetGroup [-ByName] [-PolicyName] <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-JCPolicyTargetGroup returns information about all bound groups associated with a JumpCloud Policy within a JumpCloud tenant.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCPolicyTargetGroup -PolicyId 123456789
```

Returns the bound groups associated for a policy with the id of 123456789.

### Example 2
```powershell
PS C:\> Get-JCPolicyTargetGroup -PolicyName 'HelloWorld'
```

Returns the bound groups associated for a policy with the name of HelloWorld.

### Example 3
```powershell
PS C:\> Get-JCPolicy | Get-JCPolicyTargetGroup
```

Returns all policies within a JumpCloud tenant and the bound groups associated to those policies.

## PARAMETERS

### -ByName
Use the -ByName parameter when you want to query a specific policy.
The -ByName SwitchParameter will set the ParameterSet to 'ByName' which queries one JumpCloud policy at a time.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyID
The PolicyID of the JumpCloud policy you wish to query.

```yaml
Type: System.String
Parameter Sets: ById
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PolicyName
The Name of the JumpCloud policy you wish to query.

```yaml
Type: System.String
Parameter Sets: ByName
Aliases: Name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
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
