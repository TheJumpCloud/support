# Set-JCUserGroupLDAP

## SYNOPSIS
The Set-JCUserGroupLDAP command adds or removes a JumpCloud user group and the members to/from the JumpCloud LDAP directory.

## SYNTAX

### GroupName (Default)
```
Set-JCUserGroupLDAP [-GroupName] <String> -LDAPEnabled <Boolean> [<CommonParameters>]
```

### GroupID
```
Set-JCUserGroupLDAP [-GroupID] <String> -LDAPEnabled <Boolean> [<CommonParameters>]
```

## DESCRIPTION
By default a JumpCloud user group and it's members are not added to the JumpCloud LDAP directory. To add a JumpCloud user group and its members to JumpCloud LDAP from within the admin console this can be toggled via the checkmark under the 'directories tab' for each user group.
Alternatively this can be done using the 'Set-JCUserGroupLDAP' command and by leveraging this command with the 'Get-JCGroup -type User' command modifying JumpCloud User Group LDAP membership can be done in bulk.

## EXAMPLES

### Example 1
```powershell
Set-JCUserGroupLDAP -GroupName Developers -LDAPEnabled $true
```

Adds the JumpCloud group 'Developers' (**Group names are case sensitive**) and the members of this group to JumpCloud LDAP directory.

### Example 2
```powershell
Set-JCUserGroupLDAP -GroupName Developers -LDAPEnabled $False
```

Removes the JumpCloud group 'Developers' (**Group names are case sensitive**) and the members of this group from the JumpCloud LDAP directory.

### Example 3
```powershell
Get-JCGroup -Type User | Set-JCUserGroupLDAP -LDAPEnabled $true
```

This command users the 'Get-JCGroup -Type User' command to pass all JumpCloud user groups to the 'Set-JCUserGroupLDAP' command and enables JumpCloud LDAP for all user groups within a JumpCloud tenant.

## PARAMETERS

### -GroupID
The ID of the JumpCloud user group to modify

```yaml
Type: System.String
Parameter Sets: GroupID
Aliases: id, _id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupName
The name of the JumpCloud user group to modify

```yaml
Type: System.String
Parameter Sets: GroupName
Aliases: name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LDAPEnabled
A boolean $true/$false value to enable or disable LDAP for a group

```yaml
Type: System.Boolean
Parameter Sets: (All)
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

### System.Boolean

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
