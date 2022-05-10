---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Set-JCUser
schema: 2.0.0
---

# Set-JCUser

## SYNOPSIS
Updates an existing JumpCloud User

## SYNTAX

### Username (Default)
```
Set-JCUser [-Username] <String> [-email <String>] [-firstname <String>] [-lastname <String>]
 [-password <String>] [-password_never_expires <Boolean>] [-allow_public_key <Boolean>] [-sudo <Boolean>]
 [-enable_managed_uid <Boolean>] [-unix_uid <Int32>] [-unix_guid <Int32>] [-account_locked <Boolean>]
 [-passwordless_sudo <Boolean>] [-externally_managed <Boolean>] [-ldap_binding_user <Boolean>]
 [-enable_user_portal_multifactor <Boolean>] [-NumberOfCustomAttributes <Int32>] [-middlename <String>]
 [-displayname <String>] [-jobTitle <String>] [-employeeIdentifier <String>] [-department <String>]
 [-costCenter <String>] [-company <String>] [-employeeType <String>] [-description <String>]
 [-location <String>] [-work_streetAddress <String>] [-work_poBox <String>] [-work_locality <String>]
 [-work_region <String>] [-work_postalCode <String>] [-work_country <String>] [-home_streetAddress <String>]
 [-home_poBox <String>] [-home_locality <String>] [-home_region <String>] [-home_postalCode <String>]
 [-home_country <String>] [-mobile_number <String>] [-home_number <String>] [-work_number <String>]
 [-work_mobile_number <String>] [-work_fax_number <String>] [-external_dn <String>]
 [-external_source_type <String>] [-state <String>] [-manager <String>] [-managedAppleId <String>]
 [-alternateEmail <String>] [-recoveryEmail <String>] [-EnrollmentDays <Int32>] -Attribute1_name <String>
 -Attribute1_value <String> -Attribute2_name <String> -Attribute2_value <String> [<CommonParameters>]
```

### RemoveAttribute
```
Set-JCUser [-Username] <String> [-email <String>] [-firstname <String>] [-lastname <String>]
 [-password <String>] [-password_never_expires <Boolean>] [-allow_public_key <Boolean>] [-sudo <Boolean>]
 [-enable_managed_uid <Boolean>] [-unix_uid <Int32>] [-unix_guid <Int32>] [-account_locked <Boolean>]
 [-passwordless_sudo <Boolean>] [-externally_managed <Boolean>] [-ldap_binding_user <Boolean>]
 [-enable_user_portal_multifactor <Boolean>] [-NumberOfCustomAttributes <Int32>] [-RemoveAttribute <String[]>]
 [-middlename <String>] [-displayname <String>] [-jobTitle <String>] [-employeeIdentifier <String>]
 [-department <String>] [-costCenter <String>] [-company <String>] [-employeeType <String>]
 [-description <String>] [-location <String>] [-work_streetAddress <String>] [-work_poBox <String>]
 [-work_locality <String>] [-work_region <String>] [-work_postalCode <String>] [-work_country <String>]
 [-home_streetAddress <String>] [-home_poBox <String>] [-home_locality <String>] [-home_region <String>]
 [-home_postalCode <String>] [-home_country <String>] [-mobile_number <String>] [-home_number <String>]
 [-work_number <String>] [-work_mobile_number <String>] [-work_fax_number <String>] [-external_dn <String>]
 [-external_source_type <String>] [-state <String>] [-manager <String>] [-managedAppleId <String>]
 [-alternateEmail <String>] [-recoveryEmail <String>] [-EnrollmentDays <Int32>] -Attribute1_name <String>
 -Attribute1_value <String> -Attribute2_name <String> -Attribute2_value <String> [<CommonParameters>]
```

### ByID
```
Set-JCUser -UserID <String> [-email <String>] [-firstname <String>] [-lastname <String>] [-password <String>]
 [-password_never_expires <Boolean>] [-allow_public_key <Boolean>] [-sudo <Boolean>]
 [-enable_managed_uid <Boolean>] [-unix_uid <Int32>] [-unix_guid <Int32>] [-account_locked <Boolean>]
 [-passwordless_sudo <Boolean>] [-externally_managed <Boolean>] [-ldap_binding_user <Boolean>]
 [-enable_user_portal_multifactor <Boolean>] [-NumberOfCustomAttributes <Int32>] [-ByID] [-middlename <String>]
 [-displayname <String>] [-jobTitle <String>] [-employeeIdentifier <String>] [-department <String>]
 [-costCenter <String>] [-company <String>] [-employeeType <String>] [-description <String>]
 [-location <String>] [-work_streetAddress <String>] [-work_poBox <String>] [-work_locality <String>]
 [-work_region <String>] [-work_postalCode <String>] [-work_country <String>] [-home_streetAddress <String>]
 [-home_poBox <String>] [-home_locality <String>] [-home_region <String>] [-home_postalCode <String>]
 [-home_country <String>] [-mobile_number <String>] [-home_number <String>] [-work_number <String>]
 [-work_mobile_number <String>] [-work_fax_number <String>] [-external_dn <String>]
 [-external_source_type <String>] [-state <String>] [-manager <String>] [-managedAppleId <String>]
 [-alternateEmail <String>] [-recoveryEmail <String>] [-EnrollmentDays <Int32>] -Attribute1_name <String>
 -Attribute1_value <String> -Attribute2_name <String> -Attribute2_value <String> [<CommonParameters>]
```

## DESCRIPTION
The Set-JCUser function updates an existing JumpCloud user account. Common use cases are account locks and unlocks, email address updates, or custom attribute modifications. Actions can be completed in bulk for multiple users by using the pipeline and Parameter Binding to query users with the Get-JCUser function and then applying updates with Set-JCUser function.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-JCUser -Username cclemons -account_locked $false
```

This example unlocks the account for the user with username cclemons by setting the value of the property -account_locked to $false.

### Example 2
```powershell
PS C:\> Set-JCUser -Username cclemons -account_locked $true -email 'clarence@clemons.com'
```

This example locks the account for user with username cclemons by setting the value of the property -account_locked to $true and also updates the email address for this user to 'clarence@clemons.com'.

### Example 3
```powershell
PS C:\> Get-JCUser | Select-Object _id, @{ Name = 'email'; Expression = { ($_.email).replace('olddomain.com','newdomain.com') }} | foreach {Set-JCUser -ByID -UserID $_._id -email $_.email}
```

This example updates the domain on the email addresses associated with every user in the JumpCloud tenant using Parameter Binding, the pipeline, and a calculated property. The 'olddomain.com' would represent the current domain and the 'newdomain.com' would be the new domain.

### Example 4
```powershell
PS C:\> Get-JCUserGroupMember -GroupName 'Sales' | Set-JCUser -NumberOfCustomAttributes 1 -Attribute1_name 'Department' -Attribute1_value 'Sales'
```

This example either updates or adds the Custom Attribute 'name = Department, value  = Sales' to all JumpCloud Users in the JumpCloud User Group 'Sales'

### Example 5
```powershell
PS C:\> Get-JCUserGroupMember -GroupName 'Sales' | Set-JCUser -RemoveAttribute Department
```

This example removes the Custom Attribute with the name 'Department' from all JumpCloud Users in the JumpCloud User Group 'Sales'

### Example 6
```powershell
PS C:\> Set-JCUser -Username cclemons -enable_user_portal_multifactor $True -enrollmentdays 14
```

This example enables the account for the user with username cclemons for MFA login to the user portal and sets an enrollment period of 14 days.

## PARAMETERS

### -account_locked
unlock or lock a users JumpCloud account

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

### -alternateEmail
The alternateEmail for the user

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

### -ByID
Use the -ByID parameter when the UserID is being passed over the pipeline to the Set-JCUser function.
The -ByID SwitchParameter will set the ParameterSet to 'ByID' which will increase the function speed and performance.
You cannot use this with the 'RemoveAttribute' Parameter

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: ByID
Aliases:

Required: False
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

Required: False
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
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EnrollmentDays
Number of days to allow for MFA enrollment.

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

### -external_dn
The distinguished name of the AD domain (ADB Externally managed users only)

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

### -external_source_type
The externally managed user source type (ADB Externally managed users only)

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

### -externally_managed
A boolean $true/$false value for enabling externally_managed

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

### -firstname
The first name of the user

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
Specifies the user's job title.
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

Required: False
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

### -managedAppleId
The managedAppleId for the user

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

### -manager
The manager for the user

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
If you intend to update a user with existing Custom Attributes or add new Custom Attributes you must declare how many Custom Attributes you intend to update or add.
If an Custom Attribute exists with a name that matches the new attribute then the existing attribute will be updated.
Based on the NumberOfCustomAttributes value two Dynamic Parameters will be created for each Custom Attribute: Attribute_name and Attribute_value with an associated number.
See an example for working with Custom Attribute in EXAMPLE 4

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

### -recoveryEmail
The recoveryEmail for the user

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

### -RemoveAttribute
The name of the existing Custom Attributes you wish to remove.
See an EXAMPLE for working with the -RemoveAttribute Parameter in EXAMPLE 5

```yaml
Type: System.String[]
Parameter Sets: RemoveAttribute
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -state
A string value for putting the account into a staged, activated or suspended state

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: ACTIVATED, SUSPENDED

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

### -unix_guid
The unix_guid for the user.
Note this value must be a number.

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

### -unix_uid
The unix_uid for the user.
Note this value must be an number.

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

### -UserID
The _id of the User which you want to modify.

To find a JumpCloud UserID run the command:

PS C:\\\> Get-JCUser | Select username, _id

The UserID will be the 24 character string populated for the _id field.

UserID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCUser function before calling Add-JCUserGroupMember.
This is shown in EXAMPLES 3, 4, and 5.

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

### -Username
The Username of the JumpCloud user you wish to modify

```yaml
Type: System.String
Parameter Sets: Username, RemoveAttribute
Aliases:

Required: True
Position: 0
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

### System.String[]

### System.Management.Automation.SwitchParameter

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
