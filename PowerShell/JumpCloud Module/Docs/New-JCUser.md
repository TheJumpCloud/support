---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/New-JCUser
schema: 2.0.0
---

# New-JCUser

## SYNOPSIS
{{ Fill in the Synopsis }}

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
 [-work_mobile_number <String>] [-work_fax_number <String>] [-enrollmentDays <Int32>] -Attribute1_name <String>
 -Attribute1_value <String> -Attribute2_name <String> -Attribute2_value <String> [<CommonParameters>]
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
 [-work_number <String>] [-work_mobile_number <String>] [-work_fax_number <String>] [-enrollmentDays <Int32>]
 -Attribute1_name <String> -Attribute1_value <String> -Attribute2_name <String> -Attribute2_value <String>
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Attribute1_name
Enter an attribute name

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

### -Attribute1_value
Enter an attribute value

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

### -Attribute2_name
Enter an attribute name

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

### -Attribute2_value
Enter an attribute value

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

### -NumberOfCustomAttributes
{{ Fill NumberOfCustomAttributes Description }}

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
{{ Fill allow_public_key Description }}

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

### -company
{{ Fill company Description }}

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

### -costCenter
{{ Fill costCenter Description }}

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

### -department
{{ Fill department Description }}

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

### -description
{{ Fill description Description }}

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

### -displayname
{{ Fill displayname Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: preferredName

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -email
{{ Fill email Description }}

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

### -employeeIdentifier
{{ Fill employeeIdentifier Description }}

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

### -employeeType
{{ Fill employeeType Description }}

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

### -enable_managed_uid
{{ Fill enable_managed_uid Description }}

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
{{ Fill enable_user_portal_multifactor Description }}

```yaml
Type: String
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
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -firstname
{{ Fill firstname Description }}

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

### -home_country
{{ Fill home_country Description }}

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

### -home_locality
{{ Fill home_locality Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: home_city

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -home_number
{{ Fill home_number Description }}

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

### -home_poBox
{{ Fill home_poBox Description }}

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

### -home_postalCode
{{ Fill home_postalCode Description }}

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

### -home_region
{{ Fill home_region Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: home_state

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -home_streetAddress
{{ Fill home_streetAddress Description }}

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

### -jobTitle
{{ Fill jobTitle Description }}

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

### -lastname
{{ Fill lastname Description }}

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
{{ Fill ldap_binding_user Description }}

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

### -location
{{ Fill location Description }}

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

### -middlename
{{ Fill middlename Description }}

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

### -mobile_number
{{ Fill mobile_number Description }}

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

### -password
{{ Fill password Description }}

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

### -password_never_expires
{{ Fill password_never_expires Description }}

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

### -passwordless_sudo
{{ Fill passwordless_sudo Description }}

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
{{ Fill sudo Description }}

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
{{ Fill unix_guid Description }}

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
{{ Fill unix_uid Description }}

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
{{ Fill username Description }}

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

### -work_country
{{ Fill work_country Description }}

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

### -work_fax_number
{{ Fill work_fax_number Description }}

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

### -work_locality
{{ Fill work_locality Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: work_city

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_mobile_number
{{ Fill work_mobile_number Description }}

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

### -work_number
{{ Fill work_number Description }}

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

### -work_poBox
{{ Fill work_poBox Description }}

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

### -work_postalCode
{{ Fill work_postalCode Description }}

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

### -work_region
{{ Fill work_region Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: work_state

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -work_streetAddress
{{ Fill work_streetAddress Description }}

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
