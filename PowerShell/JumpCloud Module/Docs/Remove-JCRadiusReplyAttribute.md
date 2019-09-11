---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCRadiusReplyAttribute
schema: 2.0.0
---

# Remove-JCRadiusReplyAttribute

## SYNOPSIS
Removes Radius reply attributes from a JumpCloud user group.

## SYNTAX

```
Remove-JCRadiusReplyAttribute [-GroupName] <String> [-AttributeName <String[]>] [-All] [<CommonParameters>]
```

## DESCRIPTION
Removes Radius reply attributes from a JumpCloud user group. User authentication Radius requests will return with the Radius reply attributes configured on the JumpCloud user groups which associates the user to JumpCloud Radius.
Any RADIUS reply attributes configured on a JumpCloud user group which associates a user to a RADIUS server will be returned in the Access-Accept message sent to the endpoint configured to authenticate with JumpCloud Radius. If a user is a member of more then one JumpCloud user group associated with a given RADIUS server all Reply attributes for the groups that associate the user to the RADIUS server will be returned in the Access-Accept message.
If a user is a member of more then one JumpCloud user group associated with a given RADIUS server and these groups are configured with conflicting RADIUS reply attributes then the values of the attributes for the group that was created most recently will be returned in the Access-Accept message.
RADIUS reply attribute conflicts are resolved based on the creation date of the user group where groups that are created more recently take precedent over older groups. Conflicts occur when groups are configured with the same RADIUS reply attributes and have conflicting attribute values. RADIUS reply attributes with the same attribute names but different tag values do not create conflicts.

## EXAMPLES

### Example 1
```powershell
Remove-JCRadiusReplyAttribute -GroupName BoulderOffice -All
```

Removes all Radius reply attributes from the JumpCloud user group 'BoulderOffice' using the '-All' parameter.

### Example 2
```powershell
Remove-JCRadiusReplyAttribute -GroupName BoulderOffice -AttributeName "Session-Timeout", "Termination-Action"
```

Removes attributes with the name "Session-Timeout", "Termination-Action" from the target user group 'BoulderOffice'. To remove multiple attributes at one time separate the attribute names with commas.

## PARAMETERS

### -All
The '-All' parameter is a switch parameter which will clear all Radius reply attributes from a JumpCloud user group.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AttributeName
Attributes to remove from a target user group.
To remove multiple attributes at one time separate the attribute names with commas.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupName
The JumpCloud user group to remove the specified Radius reply attributes from.

```yaml
Type: System.String
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

### System.String[]

### System.Management.Automation.SwitchParameter

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
