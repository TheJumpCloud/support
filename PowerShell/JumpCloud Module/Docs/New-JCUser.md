---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/New-JCUser
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
 [-ldap_binding_user <Boolean>] [-enable_user_portal_multifactor <String>] [-middlename <String>]
 [-displayname <String>] [-jobTitle <String>] [-employeeIdentifier <String>] [-department <String>]
 [-costCenter <String>] [-company <String>] [-employeeType <String>] [-description <String>]
 [-location <String>] [-work_streetAddress <String>] [-work_poBox <String>] [-work_locality <String>]
 [-work_region <String>] [-work_postalCode <String>] [-work_country <String>] [-home_streetAddress <String>]
 [-home_poBox <String>] [-home_locality <String>] [-home_region <String>] [-home_postalCode <String>]
 [-home_country <String>] [-mobile_number <String>] [-home_number <String>] [-work_number <String>]
 [-work_mobile_number <String>] [-work_fax_number <String>] [-suspended <Boolean>] [-enrollmentDays <Int32>]
 -Attribute1_name <String> -Attribute1_value <String> -Attribute2_name <String> -Attribute2_value <String>
 [<CommonParameters>]
```

### Attributes
```
New-JCUser -firstname <String> -lastname <String> -username <String> -email <String> [-password <String>]
 [-password_never_expires <Boolean>] [-allow_public_key <Boolean>] [-sudo <Boolean>]
 [-enable_managed_uid <Boolean>] [-unix_uid <Int32>] [-unix_guid <Int32>] [-passwordless_sudo <Boolean>]
 [-ldap_binding_user <Boolean>] [-enable_user_portal_multifactor <String>] [-NumberOfCustomAttributes <Int32>]
 [-middlename <String>] [-displayname <String>] [-jobTitle <String>] [-employeeIdentifier <String>]
 [-department <String>] [-costCenter <String>] [-company <String>] [-employeeType <String>]
 [-description <String>] [-location <String>] [-work_streetAddress <String>] [-work_poBox <String>]
 [-work_locality <String>] [-work_region <String>] [-work_postalCode <String>] [-work_country <String>]
 [-home_streetAddress <String>] [-home_poBox <String>] [-home_locality <String>] [-home_region <String>]
 [-home_postalCode <String>] [-home_country <String>] [-mobile_number <String>] [-home_number <String>]
 [-work_number <String>] [-work_mobile_number <String>] [-work_fax_number <String>] [-suspended <Boolean>]
 [-enrollmentDays <Int32>] -Attribute1_name <String> -Attribute1_value <String> -Attribute2_name <String>
 -Attribute2_value <String> [<CommonParameters>]
```

## DESCRIPTION
The New-JCUser function creates a new JumpCloud user.
Note a JumpCloud user must have a unique email address and username.
If a JumpCloud user is created without a password specified then the user will be created in an 'inactive state' and an activation email will be sent to the email address tied to the new account with instructions to complete activation. If a password is set during user creation then no activation email is send and the user is created in an active status. User activation can be seen in the boolean: 'activated' property of a JumpCloud user.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-JCUser -firstname Clarence -lastname Clemons -username cclemons -email cclemons@theband.com
```

This example creates the user with username cclemons. Because a password is not specified the user will be created in an inactive state and an activation email will be sent to 'cclemons@theband.com'.

### Example 2
```powershell
PS C:\> New-JCUser -firstname Clarence -lastname Clemons -username cclemons -email cclemons@theband.com -password Password1!
```

This example creates the user with username cclemons. Because a password is specified the user will be created in an active state and no activation email will be sent.

### Example 3
```powershell
PS C:\> New-JCUser -firstname Clarence -lastname Clemons -username cclemons -email cclemons@theband.com -password Password1! -NumberOfCustomAttributes 2 -Attribute1_name 'Band' -Attribute1_value 'E Street' -Attribute2_name 'Instrument' -Attribute2_value 'Sax'
```

This example creates the user with username cclemons and two Custom Attributes. Because a password is specified the user will be created in an active state and no activation email will be sent. When adding Custom Attributes the number of Custom Attributes being added must be declared by the -NumberOfCustomAttributes Parameter.

## PARAMETERS

### -allow_public_key
A boolean $true/$false value for allowing pubic key authentication

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

### -Attribute1_name
Enter an attribute name

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Attribute1_value
Enter an attribute value

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Attribute2_name
Enter an attribute name

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Attribute2_value
Enter an attribute value

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -company
Specifies the user's company.
The LDAP displayName of this property is company.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -costCenter
Specifies the user's costCenter.
The LDAP displayName of this property is businessCategory.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -department
Specifies the user's department.
The LDAP displayName of this property is departmentNumber.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -description
Specifies the user's description.
The LDAP displayName of this property is description.
This field is limited to 1024 characters.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -displayname
Specifies the user's preferredName.
The LDAP displayName of this property is displayName.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: preferredName

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -email
The email address for the user.
This must be a unique value.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -employeeIdentifier
Specifies the user's employeeIdentifier.
The LDAP displayName of this property is employeeNumber.
Note this field must be unique per user.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -employeeType
Specifies the user's employeeType.
The LDAP displayName of this property is employeeType.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -enable_managed_uid
A boolean $true/$false value for enabling managed uid

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

### -enable_user_portal_multifactor
A boolean $true/$false value for enabling MFA at the user portal

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: True, False, $True, $False

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -enrollmentDays
A dynamic parameter that can be set only if -enable_user_portal_multifactor is set to true.
This will specify the enrollment period for users for enrolling into MFA via the users console.
The default is 7 days if this value is not specified.

```yaml
Type: System.Int32
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
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -home_country
Specifies the user's country on the home address object.
This property is nested within the LDAP property with the displayName homePostalAddress.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -home_locality
Specifies the user's city on their home address object.
This property is nested within the LDAP property with the displayName homePostalAddress.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: home_city

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -home_number
Specifies the user's home number.
The LDAP displayName of this property is homePhone.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -home_poBox
Specifies the user's poBox on their home address object.
This property is nested within the LDAP property with the displayName homePostalAddress.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -home_postalCode
Specifies the user's postalCode on their home address object.
This property is nested within the LDAP property with the displayName homePostalAddress.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -home_region
Specifies the user's state on their home address object.
This property is nested within the LDAP property with the displayName homePostalAddress.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: home_state

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -home_streetAddress
Specifies the user's streetAddress on their home address object.
This property is nested within the LDAP property with the displayName homePostalAddress.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -jobTitle
Specifies the user's home number.
The LDAP displayName of this property is title.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -lastname
The last name of the user

```yaml
Type: System.String
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
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -location
Specifies the user's home location.
The LDAP displayName of this property is physicalDeliveryOfficeName.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -middlename
Specifies the user's home location.
The LDAP displayName of this property is initials.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -mobile_number
Specifies the user's mobile number.
The LDAP displayName of this property is mobile.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NumberOfCustomAttributes
If you intend to create users with Custom Attributes you must declare how many Custom Attributes you intend to add.
Based on the NumberOfCustomAttributes value two Dynamic Parameters will be created for each Custom Attribute: Attribute_name and Attribute_value with an associated number.
See an example for adding a user with two Custom Attributes in EXAMPLE 3

```yaml
Type: System.Int32
Parameter Sets: Attributes
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
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -password_never_expires
A boolean $true/$false value for enabling password_never_expires

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

### -passwordless_sudo
A boolean $true/$false value if you want to enable passwordless_sudo

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

### -sudo
A boolean $true/$false value if you want to enable the user to be an administrator on any and all systems the user is bound to.

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

### -suspended
A boolean $true/$false value for putting the account into a suspended state

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

### -unix_guid
The unix_guid for the new user.
Note this value must be an number.

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -unix_uid
The unix_uid for the new user.
Note this value must be an number.

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -username
The username for the user.
This must be a unique value.
This value is not modifiable after user creation.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_country
Specifies the user's country on the work address object.
This property is nested within the LDAP property with the displayName postalAddress.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_fax_number
Specifies the user's work fax number.
The LDAP displayName of this property is facsimileTelephoneNumber.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_locality
Specifies the user's city on their work address object.
The LDAP displayName of this property is l.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: work_city

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_mobile_number
Specifies the user's work mobile number.
The LDAP displayName of this property is pager.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_number
Specifies the user's work number.
The LDAP displayName of this property is telephoneNumber.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_poBox
Specifies the user's poBox on their work address object.
The LDAP displayName of this property is postOfficeBox.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_postalCode
Specifies the user's postalCode on their work address object.
The LDAP displayName of this property is postalCode.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_region
Specifies the user's state on their work address object.
This property is nested within the LDAP property with the displayName postalAddress.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: work_state

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_streetAddress
Specifies the user's streetAddress on their work address object.
This property is nested within the LDAP property with the displayName postalAddress.

```yaml
Type: System.String
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

### System.Int32

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
