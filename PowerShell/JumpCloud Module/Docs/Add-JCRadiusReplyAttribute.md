---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Add-JCRadiusReplyAttribute
schema: 2.0.0
---

# Add-JCRadiusReplyAttribute

## SYNOPSIS
Adds Radius reply attributes to a JumpCloud user group.

## SYNTAX

```
Add-JCRadiusReplyAttribute [-GroupName] <String> [-VLAN <String>] [-NumberOfAttributes <Int32>]
 -Attribute1_name <String> -Attribute1_value <String> -Attribute2_name <String> -Attribute2_value <String>
 [-VLANTag <String>] [<CommonParameters>]
```

## DESCRIPTION
Adds Radius reply attributes to a JumpCloud user group.
Any RADIUS reply attributes configured on a JumpCloud user group which associates a user to a RADIUS server will be returned in the Access-Accept message sent to the endpoint configured to authenticate with JumpCloud Radius. If a user is a member of more then one JumpCloud user group associated with a given RADIUS server all Reply attributes for the groups that associate the user to the RADIUS server will be returned in the Access-Accept message.
If a user is a member of more then one JumpCloud user group associated with a given RADIUS server and these groups are configured with conflicting RADIUS reply attributes then the values of the attributes for the group that was created most recently will be returned in the Access-Accept message.
RADIUS reply attribute conflicts are resolved based on the creation date of the user group where groups that are created more recently take precedent over older groups. Conflicts occur when groups are configured with the same RADIUS reply attributes and have conflicting attribute values. RADIUS reply attributes with the same attribute names but different tag values do not create conflicts.

## EXAMPLES

### Example 1
```powershell
Add-JCRadiusReplyAttribute -GroupName "BoulderOffice" -VLAN 24
```

By specifying the '-VLAN' parameter three radius attributes are added to the JumpCloud user group 'BoulderOffice'.

These attributes are:

name                    value
----                    -----
Tunnel-Medium-Type      IEEE-802
Tunnel-Type             VLAN
Tunnel-Private-Group-Id 24

The value specified for the '-VLAN' parameter is populated for the value of **Tunnel-Private-Group-Id**.

### Example 2
```powershell
Add-JCRadiusReplyAttribute -GroupName "BoulderOffice" -VLAN 24 -VLANTag 3
```

By specifying the '-VLAN' parameter three radius attributes are added to the JumpCloud user group 'BoulderOffice'. The use of '-VLANTag' appends each VLAN attribute name with a colon and the tag number specified.

These attributes are:

name                    value
----                    -----
Tunnel-Medium-Type:3      IEEE-802
Tunnel-Type:3             VLAN
Tunnel-Private-Group-Id:3 24

### Example 3
```powershell
Add-JCRadiusReplyAttribute -GroupName "BoulderOffice" -NumberOfAttributes 2 -Attribute1_name "Session-Timeout" -Attribute1_value 100 -Attribute2_name "Termination-Action" -Attribute2_value 1
```

Adds two Radius attributes to the JumpCloud user group 'BoulderOffice'.

These attribute are:

name               value
----               -----
Session-Timeout    100
Termination-Action 1

The parameter '-NumberOfAttributes' is a dynamic parameter that generates two required parameters for each custom attribute specified. In this example these parameters are -Attribute1_name,-Attribute1_value, -Attribute2_name and -Attribute2_value.

### Example 4
```powershell
Add-JCRadiusReplyAttribute -GroupName "BoulderOffice" -VLAN 24 -NumberOfAttributes 2 -Attribute1_name "Session-Timeout" -Attribute1_value 100 -Attribute2_name "Termination-Action" -Attribute2_value 1
```

Adds five Radius reply attributes to the JumpCloud User group 'BoulderUsers'

These attributes are:

name                    value
----                    -----
Tunnel-Medium-Type      IEEE-802
Termination-Action      1
Tunnel-Type             VLAN
Session-Timeout         100
Tunnel-Private-Group-Id 24

By specifying the '-VLAN' parameter three radius attributes are added to the JumpCloud user group 'BoulderOffice'. The value specified for the '-VLAN' parameter is populated for the value of **Tunnel-Private-Group-Id**.The parameter '-NumberOfAttributes' is a dynamic parameter that generates two required parameters for each custom attribute specified. In this example these parameters are -Attribute1_name,-Attribute1_value, -Attribute2_name and -Attribute2_value.

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

### -GroupName
The JumpCloud user group to add the specified Radius reply attributes to.

```yaml
Type: String
Parameter Sets: (All)
Aliases: name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NumberOfAttributes
The number of RADIUS reply attributes you wish to add to a user group.
If an attributes exists with a name that matches the new attribute then the existing attribute will be updated.
Based on the NumberOfAttributes value two Dynamic Parameters will be created for each Attribute: Attribute_name and Attribute_value with an associated number.
See an example for working with Custom Attribute in EXAMPLE 3 above.
Attributes must be valid RADIUS attributes.
Find a list of valid RADIUS attributes within the dictionary files of this repro broken down by vendor: github.com/FreeRADIUS/freeradius-server/tree/v3.0.x/share If an invalid attribute is configured on a user group this will prevent users within this group from being able to authenticate via RADIUS until the invalid attribute is removed.

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

### -VLAN
By specifying the '-VLAN' parameter three radius attributes are added to the target user group.

These attributes and values are are:

name                    value

----                    -----

Tunnel-Medium-Type      IEEE-802

Tunnel-Type             VLAN

Tunnel-Private-Group-Id **VALUE of -VLAN**

The value specified for the '-VLAN' parameter is populated for the value of **Tunnel-Private-Group-Id**.

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

### -VLANTag
Specifies the VLAN id which is applied to all attribute names.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31

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
### System.Int32
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
