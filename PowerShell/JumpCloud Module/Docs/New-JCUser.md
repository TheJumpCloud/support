---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# New-JCUser

## SYNOPSIS

Creates a JumpCloud User

## SYNTAX

### NoAttributes (Default)
```
New-JCUser -firstname <String> -lastname <String> -username <String> -email <String> [-password <String>]
 [-password_never_expires <Boolean>] [-allow_public_key <Boolean>] [-sudo <Boolean>]
 [-enable_managed_uid <Boolean>] [-unix_uid <Int32>] [-unix_guid <Int32>] [-passwordless_sudo <Boolean>]
 [-ldap_binding_user <Boolean>] [-enable_user_portal_multifactor <Boolean>] [<CommonParameters>]
```

### Attributes
```
New-JCUser -firstname <String> -lastname <String> -username <String> -email <String> [-password <String>]
 [-password_never_expires <Boolean>] [-allow_public_key <Boolean>] [-sudo <Boolean>]
 [-enable_managed_uid <Boolean>] [-unix_uid <Int32>] [-unix_guid <Int32>] [-passwordless_sudo <Boolean>]
 [-ldap_binding_user <Boolean>] [-enable_user_portal_multifactor <Boolean>] [-NumberOfCustomAttributes <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION

The New-JCUser function creates a new JumpCloud user.
Note a JumpCloud user must have a unique email address and username.
If a JumpCloud user is created without a password specified then the user will be created in an 'inactive state' and an activation email will be sent to the email address tied to the new account with instructions to complete activation. If a password is set during user creation then no activation email is send and the user is created in an active status.  User activation can be seen in the boolean: 'activated' property of a JumpCloud user.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> New-JCUser -firstname Clarence -lastname Clemons -username cclemons -email cclemons@theband.com
```

This example creates the user with username cclemons. Because a password is not specified the user will be created in an inactive state and an activation email will be sent to 'cclemons@theband.com'.

### Example 2

```PowerShell
PS C:\> New-JCUser -firstname Clarence -lastname Clemons -username cclemons -email cclemons@theband.com -password Password1!
```

This example creates the user with username cclemons. Because a password is specified the user will be created in an active state and no activation email will be sent.

### Example 3

```PowerShell
PS C:\> New-JCUser -firstname Clarence -lastname Clemons -username cclemons -email cclemons@theband.com -password Password1! -NumberOfCustomAttributes 2 -Attribute1_name 'Band' -Attribute1_value 'E Street' -Attribute2_name 'Instrument' -Attribute2_value 'Sax'
```

This example creates the user with username cclemons and two Custom Attributes. Because a password is specified the user will be created in an active state and no activation email will be sent. When adding Custom Attributes the number of Custom Attributes being added must be declared by the -NumberOfCustomAttributes Parameter.

## PARAMETERS

### -NumberOfCustomAttributes

If you intend to create users with Custom Attributes you must declare how many Custom Attributes you intend to add.

Based on the NumberOfCustomAttributes value two Dynamic Parameters will be created for each Custom Attribute: Attribute_name and Attribute_value with an associated number.

See an example for adding a user with two Custom Attributes in EXAMPLE 3

```yaml
Type: Int32
Parameter Sets: Attributes
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -allow_public_key

A boolean $true/$false value for allowing pubic key authentication

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -email

The email address for the user. This must be a unique value.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -enable_managed_uid

A boolean $true/$false value for enabling managed uid

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -enable_user_portal_multifactor

A boolean $true/$false value for enabling MFA at the user portal

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -firstname

The first name of the user

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -lastname

The last name of the user

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ldap_binding_user

A boolean $true/$false value to enable the user as an LDAP binding user

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -password

The password for the user

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -passwordless_sudo

A boolean $true/$false value if you want to enable passwordless_sudo


```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -sudo

A boolean $true/$false value if you want to enable the user to be an administrator on any and all systems the user is bound to.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -unix_guid

The unix_guid for the new user. Note this value must be an number.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -unix_uid

The unix_uid for the new user. Note this value must be an number.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -username

The username for the user. This must be a unique value. This value is not modifiable after user creation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -password_never_expires
A boolean $true/$false value for enabling password_never_expires

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

System.Boolean
System.Int32

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Online Help New-JCUser](https://github.com/TheJumpCloud/support/wiki/New-JCUser)
