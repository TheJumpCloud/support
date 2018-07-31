---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# Get-JCGroup

## SYNOPSIS

Returns all JumpCloud System and User Groups.

## SYNTAX

### ReturnAll (Default)
```
Get-JCGroup [<CommonParameters>]
```

### Type
```
Get-JCGroup [[-Type] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-JCGroup function by default will return all JumpCloud System and User groups. By using the -Type Parameter you can choose to return either System or User groups.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Get-JCGroup
```

Returns all JumpCloud User and System groups

### Example 2

```PowerShell
PS C:\> Get-JCGroup -Type User
```

Returns all JumpCloud User groups

### Example 3

```PowerShell
PS C:\> Get-JCGroup -Type System
```

Returns all JumpCloud System groups

### Example 4

```PowerShell
PS C:\> Get-JCGroup -Type User -Name 'The Band'
```

Returns the JumpCloud user group 'The Band' and the posixGroups information descripting this group 

## PARAMETERS

### -Type

The type of JumpCloud group you want to return.
Note there are only two options - User and System.

```yaml
Type: String
Parameter Sets: Type
Aliases:
Accepted values: User, System

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Online Help Get-JCGroup](https://github.com/TheJumpCloud/support/wiki/Get-JCGroup)