---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCUserGroupMember
schema: 2.0.0
---

# Get-JCUserGroupMember

## SYNOPSIS
Returns the User Group members of a JumpCloud User Group.

## SYNTAX

### ByGroup (Default)
```
Get-JCUserGroupMember [-GroupName] <String> [-Parallel <Boolean>] [<CommonParameters>]
```

### ByID
```
Get-JCUserGroupMember -ByID <String> [-Parallel <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
The Get-JCUserGroupMember function returns all the User Group members of a JumpCloud User Group.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCUserGroupMember -GroupName 'The Band'
```

Returns the JumpCloud users that are a member of the group 'The Band'

### Example 2
```powershell
PS C:\> Get-JCGroup -Type User | Get-JCUserGroupMember
```

Returns all the JumpCloud User Groups and their members.

### Example 3
```powershell
PS C:\> Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'cclemons'
```

Returns all the JumpCloud User Groups that the JumpCloud user with a username of 'cclemons' is a member of.

## PARAMETERS

### -ByID
If searching for a User Group using the GroupID populate the GroupID in the -ByID field.

```yaml
Type: System.String
Parameter Sets: ByID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupName
The name of the JumpCloud User Group you want to return the members of.

```yaml
Type: System.String
Parameter Sets: ByGroup
Aliases: name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Parallel
Boolean: $true to run in parallel, $false to run in sequential; Default value: false

```yaml
Type: System.Boolean
Parameter Sets: (All)
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

### System.String

### System.Boolean

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
