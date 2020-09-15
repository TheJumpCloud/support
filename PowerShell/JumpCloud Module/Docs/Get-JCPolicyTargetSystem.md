---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCPolicyTargetSystem
schema: 2.0.0
---

# Get-JCPolicyTargetSystem

## SYNOPSIS
Returns all bound systems associated with a JumpCloud Policy within a JumpCloud tenant.

## SYNTAX

### ById (Default)
```
Get-JCPolicyTargetSystem [-PolicyID] <String> [<CommonParameters>]
```

### ByName
```
Get-JCPolicyTargetSystem [-ByName] [-PolicyName] <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-JCPolicyTargetSystem returns information about all bound systems associated with a JumpCloud Policy within a JumpCloud tenant.

## EXAMPLES

### Example 1
```
PS C:\> Get-JCPolicyTargetSystem -PolicyId 123456789
```

Returns the bound Systems associated for a policy with the id of 123456789.

### Example 2
```
PS C:\> Get-JCPolicyTargetSystem -PolicyName 'HelloWorld'
```

Returns the bound Systems associated for a policy with the name of HelloWorld.

### Example 3
```
PS C:\> Get-JCPolicy | Get-JCPolicyTargetSystem
```

Returns all policies within a JumpCloud tenant and the bound systems associated to those policies.

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
