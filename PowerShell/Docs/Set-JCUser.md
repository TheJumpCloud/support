---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Set-JCUser

## SYNOPSIS

Updates an existing JumpCloud User

## SYNTAX

### Username (Default)

```PowerShell
Set-JCUser [-Username] <String> [-email <String>] [-firstname <String>] [-lastname <String>]
 [-password <String>] [-allow_public_key <Boolean>] [-sudo <Boolean>] [-enable_managed_uid <Boolean>]
 [-unix_uid <Int32>] [-unix_guid <Int32>] [-account_locked <Boolean>] [-passwordless_sudo <Boolean>]
 [-externally_managed <Boolean>] [-ldap_binding_user <Boolean>] [-enable_user_portal_multifactor <Boolean>]
 [-NumberOfCustomAttributes <Int32>]
```

### RemoveAttribute

```PowerShell
Set-JCUser [-Username] <String> [-email <String>] [-firstname <String>] [-lastname <String>]
 [-password <String>] [-allow_public_key <Boolean>] [-sudo <Boolean>] [-enable_managed_uid <Boolean>]
 [-unix_uid <Int32>] [-unix_guid <Int32>] [-account_locked <Boolean>] [-passwordless_sudo <Boolean>]
 [-externally_managed <Boolean>] [-ldap_binding_user <Boolean>] [-enable_user_portal_multifactor <Boolean>]
 [-NumberOfCustomAttributes <Int32>] [-RemoveAttribute <String[]>]
```

### ByID

```PowerShell
Set-JCUser -UserID <String> [-email <String>] [-firstname <String>] [-lastname <String>] [-password <String>]
 [-allow_public_key <Boolean>] [-sudo <Boolean>] [-enable_managed_uid <Boolean>] [-unix_uid <Int32>]
 [-unix_guid <Int32>] [-account_locked <Boolean>] [-passwordless_sudo <Boolean>]
 [-externally_managed <Boolean>] [-ldap_binding_user <Boolean>] [-enable_user_portal_multifactor <Boolean>]
 [-NumberOfCustomAttributes <Int32>] [-ByID]
```

## DESCRIPTION

The Set-JCUser function updates an existing JumpCloud user account. Common use cases are account locks and unlocks, email address updates, or custom attribute modifications. Actions can be completed in bulk for multiple users by using the pipeline and Parameter Binding to query users with the Get-JCUser function and then applying updates with Set-JCUser function.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Set-JCUser -Username cclemons -account_locked $false

```

This example unlocks the account for the user with username cclemons by setting the value of the property -account_locked to $false.

### Example 2

```PowerShell
PS C:\> Set-JCUser -Username cclemons -account_locked $true -email 'clarence@clemons.com'

```

This example locks the account for user with username cclemons by setting the value of the property -account_locked to $true and also updates the email address for this user to 'clarence@clemons.com'.

### Example 3

```PowerShell
PS C:\> Get-JCUser | Select-Object _id, @{ Name = 'email'; Expression = { ($_.email).replace('olddomain.com','newdomain.com') }} | foreach {Set-JCUser -ByID -UserID $_._id -email $_.email}

```

This example updates the domain on the email addresses associated with every user in the JumpCloud tenant using Parameter Binding, the pipeline, and a calculated property. The 'olddomain.com' would represent the current domain and the 'newdomain.com' would be the new domain.

### Example 4

```PowerShell
PS C:\> Get-JCUserGroupMember -GroupName 'Sales' | Set-JCUser -NumberOfCustomAttributes 1 -Attribute1_name 'Department' -Attribute1_value 'Sales'

```

This example either updates or adds the Custom Attribute 'name = Department, value  = Sales' to all JumpCloud Users in the JumpCloud User Group 'Sales'

### Example 5

```PowerShell
PS C:\> Get-JCUserGroupMember -GroupName 'Sales' | Set-JCUser -RemoveAttribute Department

```

This example removes the Custom Attribute with the name 'Department' from all JumpCloud Users in the JumpCloud User Group 'Sales'

## PARAMETERS

### -ByID

Use the -ByID parameter when the UserID is being passed over the pipeline to the Set-JCUser function. The -ByID SwitchParameter will set the ParameterSet to 'ByID' which will increase the function speed and performance. You cannot use this with the 'RemoveAttribute' Parameter

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

### -NumberOfCustomAttributes

If you intend to update a user with existing Custom Attributes or add new Custom Attributes you must declare how many Custom Attributes you intend to update or add.

If an Custom Attribute exists with a name that matches the new attribute then the existing attribute will be updated.

Based on the NumberOfCustomAttributes value two Dynamic Parameters will be created for each Custom Attribute: Attribute_name and Attribute_value with an associated number.

See an example for working with Custom Attribute in EXAMPLE 4

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

### -RemoveAttribute

The name of the existing Custom Attributes you wish to remove. See an EXAMPLE for working with the -RemoveAttribute Parameter in EXAMPLE 5

```yaml
Type: String[]
Parameter Sets: RemoveAttribute
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserID

The _id of the User which you want to modify.

To find a JumpCloud UserID run the command:

```PowerShell
PS C:\> Get-JCUser | Select username, _id
```

The UserID will be the 24 character string populated for the _id field.

UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCUser function before calling Add-JCUserGroupMember. This is shown in EXAMPLES 3, 4, and 5.

```yaml
Type: String
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username

The Username of the JumpCloud user you wish to modify

```yaml
Type: String
Parameter Sets: Username, RemoveAttribute
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -account_locked

A boolean $true/$false value to unlock or lock a users JumpCloud account

```yaml
Type: Boolean
Parameter Sets: (All)
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
Accept pipeline input: False
Accept wildcard characters: False
```

### -email

The email address for the user. This must be a unique value.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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
Accept pipeline input: False
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
Accept pipeline input: False
Accept wildcard characters: False
```

### -externally_managed

A boolean $true/$false value for enabling externally_managed

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -firstname

The first name of the user

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -lastname

The last name of the user

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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
Accept pipeline input: False
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
Accept pipeline input: False
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
Accept pipeline input: False
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
Accept pipeline input: False
Accept wildcard characters: False
```

### -unix_guid

The unix_guid for the user. Note this value must be an number.

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

The unix_uid for the user. Note this value must be an number.

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

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
