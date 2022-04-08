# Get-JCPolicyResult

## SYNOPSIS
Returns all JumpCloud results for a given policy within a JumpCloud tenant.

## SYNTAX

### ByPolicyName (Default)
```
Get-JCPolicyResult [-PolicyName] <String> [<CommonParameters>]
```

### ByPolicyID
```
Get-JCPolicyResult [-PolicyID] <String> [-ByPolicyID] [<CommonParameters>]
```

### BySystemID
```
Get-JCPolicyResult -SystemID <String> [-BySystemID] [<CommonParameters>]
```

### ByPolicyResultID
```
Get-JCPolicyResult [-PolicyResultID <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-JCPolicyResult function returns the latest policy result information from a JumpCloud policy. You can search by a specific policy name to return results from the policy being applied. You can also search by a specific systemId to find the latest policy result for a specific system.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCPolicyResult 'HelloWorld'
```

Returns the latest policy result for the HelloWorld policy.

### Example 2
```powershell
PS C:\> Get-JCPolicyResult -PolicyId 123456789
```

Returns the latest policy result for the policy with the id of 123456789.

### Example 3
```powershell
PS C:\> Get-JCPolicyResult -SystemID 123456789
```

Returns the latest policy result for a system with the id of 123456789.

## PARAMETERS

### -ByPolicyID
The -ByPolicyID switch parameter will enforce the ByPolicyID parameter set and improve performance of gathering multiple policy results via the pipeline when the input object contains a property with PolicyID.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: ByPolicyID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -BySystemID
The -BySystemID switch parameter will enforce the BySystemID parameter set and search for results by SystemID.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: BySystemID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PolicyID
The PolicyID of the JumpCloud policy you wish to query.

```yaml
Type: System.String
Parameter Sets: ByPolicyID
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PolicyName
The PolicyName of the JumpCloud policy you wish to query.

```yaml
Type: System.String
Parameter Sets: ByPolicyName
Aliases: name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PolicyResultID
The PolicyResultID of the JumpCloud policy result you wish to query.

```yaml
Type: System.String
Parameter Sets: ByPolicyResultID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemID
The SystemID of the JumpCloud system you wish to query the latest policy result of.

```yaml
Type: System.String
Parameter Sets: BySystemID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Management.Automation.SwitchParameter

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
