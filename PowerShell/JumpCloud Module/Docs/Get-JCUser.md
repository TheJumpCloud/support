---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCUser
schema: 2.0.0
---

# Get-JCUser

## SYNOPSIS
Returns all JumpCloud Users within a JumpCloud tenant or searches for a JumpCloud User by 'username', 'firstname', 'lastname', or 'email'.

## SYNTAX

### SearchFilter (Default)
```
Get-JCUser [[-username] <String>] [-firstname <String>] [-lastname <String>] [-email <String>]
 [-unix_guid <String>] [-unix_uid <String>] [-sudo <Boolean>] [-enable_managed_uid <Boolean>]
 [-activated <Boolean>] [-password_expired <Boolean>] [-account_locked <Boolean>]
 [-passwordless_sudo <Boolean>] [-externally_managed <Boolean>] [-ldap_binding_user <Boolean>]
 [-enable_user_portal_multifactor <Boolean>] [-totp_enabled <Boolean>] [-allow_public_key <Boolean>]
 [-samba_service_user <Boolean>] [-password_never_expires <Boolean>] [-suspended <Boolean>]
 [-filterDateProperty <String>] [-returnProperties <String[]>] [-middlename <String>] [-displayname <String>]
 [-jobTitle <String>] [-employeeIdentifier <String>] [-department <String>] [-costCenter <String>]
 [-company <String>] [-employeeType <String>] [-description <String>] [-location <String>]
 [-external_dn <String>] [-external_source_type <String>] -dateFilter <String> -date <DateTime>
 [<CommonParameters>]
```

### ByID
```
Get-JCUser -userid <String> -dateFilter <String> -date <DateTime> [<CommonParameters>]
```

## DESCRIPTION
The Get-JCUser function returns all information describing a JumpCloud user.
By default it will return all Users.

## EXAMPLES

### Example 1
```
PS C:\> Get-JCUser
```

Returns all JumpCloud Users and the information describing these users.

### Example 2
```
Get-JCUser -Username cclemons
```

Returns the information describing the JumpCloud User with Username cclemons

### Example 3
```
Get-JCUser -Username *clemons
```

Returns all JumpCloud users that usernames end with clemons using the wildcard character '*'

### Example 4
```
Get-JCUser -filterDateProperty created -dateFilter after -date 01/01/2018
```

Returns all JumpCloud users that were created after '01/01/2018'.
The parameter '-filterDateProperty' takes both 'created' and 'password_expiration_date' as input and creates two dynamic parameters '-dateFilter' which takes "before" or "after" as input and "-date" which takes a date value as input.

### Example 5
```
Get-JCUser -returnProperties username, sudo
```

Returns all JumpCloud users and only the username and sudo Properties of their JumpCloud user object.

## PARAMETERS

### -account_locked
A search filter to return users that are in a locked ($true) or unlocked ($false) state.

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -activated
A search filter to return users that are activated ($true) or those that have not set a password ($false).

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -allow_public_key
A search filter to show accounts that are enabled ($true) or disabled ($true) to allow_public_key

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -company
The company of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -costCenter
The costCenter of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -date
Date to filter on.

```yaml
Type: System.DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -dateFilter
Condition to filter date on.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: before, after

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -department
The department of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -description
The description of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -displayname
The preferred name of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -email
The Email of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -employeeIdentifier
The employeeIdentifier of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -employeeType
The employeeType of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -enable_managed_uid
A search filter to show accounts that are enabled ($true) or disabled ($false) for enable_managed_uid

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -enable_user_portal_multifactor
A search filter to show accounts that are enabled ($true) or disabled ($false) for enable_user_portal_multifactor

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -external_dn
The distinguished name of the AD domain (ADB Externally managed users only)

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -external_source_type
The externally managed user source type (ADB Externally managed users only)

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -externally_managed
A search filter to show accounts that are enabled ($true) or disabled ($false) for externally_managed

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -filterDateProperty
A parameter that can filter the properties 'created' or 'password_expiration_date'.
This parameter if used creates two more dynamic parameters 'dateFilter' and 'date'.
See EXAMPLE 4 above for full syntax.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:
Accepted values: created, password_expiration_date

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -firstname
The First Name of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -jobTitle
The jobTitle of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -lastname
The Last Name of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ldap_binding_user
A search filter to show accounts that are enabled ($true) or disabled ($false) for ldap_binding_user

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -location
The location of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -middlename
The middlename of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -password_expired
A search filter to show accounts that have expired passwords ($true) or valid passwords ($false)

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -password_never_expires
A search filter to show accounts that are enabled ($true) or disabled ($false) for password_never_expires

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -passwordless_sudo
A search filter to show accounts that are enabled ($true) or disabled ($false) for passwordless_sudo

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -returnProperties
Allows you to return select properties on JumpCloud user objects.
Specifying what properties are returned can drastically increase the speed of the API call with a large data set.
Valid properties that can be returned are: 'created', 'password_expiration_date', 'account_locked', 'activated', 'addresses', 'allow_public_key', 'attributes', 'email', 'enable_managed_uid', 'enable_user_portal_multifactor', 'externally_managed', 'firstname', 'lastname', 'ldap_binding_user', 'passwordless_sudo', 'password_expired', 'password_never_expires', 'phoneNumbers', 'samba_service_user', 'ssh_keys', 'sudo', 'totp_enabled', 'unix_guid', 'unix_uid', 'username','suspended'

```yaml
Type: System.String[]
Parameter Sets: SearchFilter
Aliases:
Accepted values: created, password_expiration_date, account_locked, activated, addresses, allow_public_key, attributes, email, enable_managed_uid, enable_user_portal_multifactor, externally_managed, firstname, lastname, ldap_binding_user, passwordless_sudo, password_expired, password_never_expires, phoneNumbers, samba_service_user, ssh_keys, sudo, totp_enabled, unix_guid, unix_uid, username, middlename, displayname, jobTitle, employeeIdentifier, department, costCenter, company, employeeType, description, location, external_source_type, external_dn, suspended, mfa

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -samba_service_user
A search filter to show accounts that are enabled ($true) or disabled ($false) for samba_service_user

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -sudo
A search filter to show accounts that are enabled ($true) or disabled ($false) for sudo

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -suspended
A search filter to show accounts that are enabled ($true) or disabled ($false) for password_never_expires

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -totp_enabled
A search filter to show accounts that are enabled ($true) or disabled ($false) for totp_enabled

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -unix_guid
A search filter to search for users with a specific unix_gid.
DOES NOT accept wild card input.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -unix_uid
A search filter to search for users with a specific unix_uid.
DOES NOT accept wild card input.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -userid
The _id of the User which you want to modify.
UserID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically.

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -username
The Username of the JumpCloud user you wish to search for.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Boolean
### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
