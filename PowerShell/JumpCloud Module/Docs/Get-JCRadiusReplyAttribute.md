---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCRadiusReplyAttribute
schema: 2.0.0
---

# Get-JCRadiusReplyAttribute

## SYNOPSIS
Returns the Radius reply attributes associated with a JumpCloud user group.

## SYNTAX

```
Get-JCRadiusReplyAttribute [-GroupName] <String> [<CommonParameters>]
```

## DESCRIPTION
Returns the Radius reply attributes associated with a JumpCloud user group. User authentication Radius requests will return with the Radius reply attributes configured on the JumpCloud user groups which associates the user to JumpCloud Radius.
Any RADIUS reply attributes configured on a JumpCloud user group which associates a user to a RADIUS server will be returned in the Access-Accept message sent to the endpoint configured to authenticate with JumpCloud Radius. If a user is a member of more then one JumpCloud user group associated with a given RADIUS server all Reply attributes for the groups that associate the user to the RADIUS server will be returned in the Access-Accept message.
If a user is a member of more then one JumpCloud user group associated with a given RADIUS server and these groups are configured with conflicting RADIUS reply attributes then the values of the attributes for the group that was created most recently will be returned in the Access-Accept message.
RADIUS reply attribute conflicts are resolved based on the creation date of the user group where groups that are created more recently take precedent over older groups. Conflicts occur when groups are configured with the same RADIUS reply attributes and have conflicting attribute values. RADIUS reply attributes with the same attribute names but different tag values do not create conflicts.

## EXAMPLES

### Example 1
```powershell
Get-JCRadiusReplyAttribute -GroupName BoulderOffice
```

Returns the Radius reply attributes associated with the JumpCloud user group 'BoulderOffice'.

## PARAMETERS

### -GroupName
The JumpCloud user group to query for Radius attributes.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
