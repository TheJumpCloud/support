---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# Get-JCPolicy

## SYNOPSIS
Returns all JumpCloud Policies within a JumpCloud tenant.

## SYNTAX

### ReturnAll (Default)
```
Get-JCPolicy [<CommonParameters>]
```

### ByID
```
Get-JCPolicy [-PolicyID] <String> [-ByID] [<CommonParameters>]
```

### Name
```
Get-JCPolicy [-Name <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-JCPolicy function returns all information describing JumpCloud policies within a JumpCloud tenant.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCPolicy
```

Returns all JumpCloud Policies populated within the Policies section of the JumpCloud admin console.

### Example 2
```powershell
PS C:\> Get-JCPolicy -PolicyID 123456789
```

Returns the policy associated to the id of 123456789.

### Example 3
```powershell
PS C:\> Get-JCPolicy -Name 'HelloWorld'
```

Returns the HelloWorld policy.

## PARAMETERS

### -ByID
Use the -ByID parameter when you want to query a specific policy. The -ByID SwitchParameter will set the ParameterSet to 'ByID' which queries one JumpCloud policy at a time.


```yaml
Type: SwitchParameter
Parameter Sets: ByID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The Name of the JumpCloud policy you wish to query.

```yaml
Type: String
Parameter Sets: Name
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
Type: String
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Online Help Get-JCCommand](https://github.com/TheJumpCloud/support/wiki/Get-JCPolicy)