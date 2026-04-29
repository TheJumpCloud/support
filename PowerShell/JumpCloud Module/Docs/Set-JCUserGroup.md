---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Set-JCUserGroup

## SYNOPSIS

This endpoint allows you to do a full set of the User Group.

See the \[Dynamic Group Configuration KB article\](https://jumpcloud.com/support/configure-dynamic-device-groups) for more details on maintaining a Dynamic Group.

## SYNTAX

### SetExpanded (Default)
```
Set-JCUserGroup -Id <String> [-Attributes <Hashtable>] [-Description <String>] [-Email <String>]
 [-MemberQueryExemptions <IGraphObject[]>] [-MemberQueryFilters <String[]>]
 [-MemberQuerySearchFilters <String>] [-MemberQueryType <String>] [-MemberSuggestionsNotify]
 [-MembershipMethod <String>] [-Name <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Set
```
Set-JCUserGroup -Id <String> -Body <IUserGroupPut> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### SetViaIdentity
```
Set-JCUserGroup -InputObject <IJumpCloudApiIdentity> -Body <IUserGroupPut>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SetViaIdentityExpanded
```
Set-JCUserGroup -InputObject <IJumpCloudApiIdentity> [-Attributes <Hashtable>] [-Description <String>]
 [-Email <String>] [-MemberQueryExemptions <IGraphObject[]>] [-MemberQueryFilters <String[]>]
 [-MemberQuerySearchFilters <String>] [-MemberQueryType <String>] [-MemberSuggestionsNotify]
 [-MembershipMethod <String>] [-Name <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

This endpoint allows you to do a full set of the User Group.

See the \[Dynamic Group Configuration KB article\](https://jumpcloud.com/support/configure-dynamic-device-groups) for more details on maintaining a Dynamic Group.

## EXAMPLES

### EXAMPLE 1

```
Set-JCUserGroup -Id:(<string>) -Body:(<JumpCloud.SDK.V2.Models.UserGroupPut>)
```

---

Attributes JumpCloud.SDK.V2.Models.GroupAttributesUserGroup
Description String
Email String
Id String
MemberQueryExemptions JumpCloud.SDK.V2.Models.GraphObject\[\]
MemberQueryFilters JumpCloud.SDK.V2.Models.Any\[\]
MemberQueryType String
MembershipMethod String
MemberSuggestionsNotify Boolean
Name String
SuggestionCountAdd Int
SuggestionCountRemove Int
SuggestionCountTotal Int
Type String

### EXAMPLE 2

```
Set-JCUserGroup -Id:(<string>) -Name:(<string>) -Attributes:(<hashtable>) -Description:(<string>) -Email:(<string>) -MemberQueryExemptions:(<JumpCloud.SDK.V2.Models.GraphObject[]>) -MemberQueryFilters:(<JumpCloud.SDK.V2.Models.Any[]>) -MemberQueryType:(<string>) -MemberSuggestionsNotify:(<switch>) -MembershipMethod:(<string>)
```

---

Attributes JumpCloud.SDK.V2.Models.GroupAttributesUserGroup
Description String
Email String
Id String
MemberQueryExemptions JumpCloud.SDK.V2.Models.GraphObject\[\]
MemberQueryFilters JumpCloud.SDK.V2.Models.Any\[\]
MemberQueryType String
MembershipMethod String
MemberSuggestionsNotify Boolean
Name String
SuggestionCountAdd Int
SuggestionCountRemove Int
SuggestionCountTotal Int
Type String

## PARAMETERS

### -Attributes

The graph attributes for a UserGroup.

```yaml
Type: System.Collections.Hashtable
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body

UserGroupPut

```yaml
Type: JumpCloud.SDK.V2.Models.IUserGroupPut
Parameter Sets: Set, SetViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Description

Description of a User Group

```yaml
Type: System.String
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email

Email address of a User Group

```yaml
Type: System.String
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

ObjectID of the User Group.

```yaml
Type: System.String
Parameter Sets: SetExpanded, Set
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject

Identity Parameter

```yaml
Type: JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
Parameter Sets: SetViaIdentity, SetViaIdentityExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -MemberQueryExemptions

Array of GraphObjects exempted from the query

```yaml
Type: JumpCloud.SDK.V2.Models.IGraphObject[]
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemberQueryFilters

For queryType 'Filter', this is a stringified JSON filter array that will be validated by API middleware.

```yaml
Type: System.String[]
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemberQuerySearchFilters

For queryType 'Search', this is a stringified JSON filter object that will be validated by API middleware.

```yaml
Type: System.String
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemberQueryType

.

```yaml
Type: System.String
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MembershipMethod

The type of membership method for this group.
Valid values include NOTSET, STATIC, DYNAMIC_REVIEW_REQUIRED, and DYNAMIC_AUTOMATED.Note DYNAMIC_AUTOMATED and DYNAMIC_REVIEW_REQUIRED group rules will supersede any group enrollment for \[group-associated MDM-enrolled devices\](https://jumpcloud.com/support/change-a-default-device-group-for-apple-devices).Use caution when creating dynamic device groups with MDM-enrolled devices to avoid creating conflicting rule sets.

```yaml
Type: System.String
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemberSuggestionsNotify

True if notification emails are to be sent for membership suggestions.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Display name of a User Group.

```yaml
Type: System.String
Parameter Sets: SetExpanded, SetViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
### JumpCloud.SDK.V2.Models.IUserGroupPut
## OUTPUTS

### JumpCloud.SDK.V2.Models.IUserGroup
## NOTES

COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties.
For information on hash tables, run Get-Help about_Hash_Tables.

BODY \<IUserGroupPut\>: UserGroupPut
Name \<String\>: Display name of a User Group.
\[Attributes \<IGroupAttributesUserGroup\>\]: The graph attributes for a UserGroup.
\[(Any) \<Object\>\]: This indicates any property can be added to this object.
\[SudoEnabled \<Boolean?\>\]: Enables sudo
\[SudoWithoutPassword \<Boolean?\>\]: Enable sudo without password (requires 'enabled' to be true)
\[LdapGroups \<List\<ILdapGroup\>\>\]:
\[Name \<String\>\]:
\[PosixGroups \<List\<IGraphAttributePosixGroupsItem\>\>\]:
Id \<Int32\>:
Name \<String\>:
\[RadiusReply \<List\<IGraphAttributeRadiusReplyItem\>\>\]:
Name \<String\>:
Value \<String\>:
\[SambaEnabled \<Boolean?\>\]:
\[Description \<String\>\]: Description of a User Group
\[Email \<String\>\]: Email address of a User Group
\[MemberQueryExemptions \<List\<IGraphObject\>\>\]: Array of GraphObjects exempted from the query
Id \<String\>: The ObjectID of the graph object.
Type \<String\>: The type of graph object.
\[Attributes \<IGraphAttributes\>\]: The graph attributes.
\[(Any) \<Object\>\]: This indicates any property can be added to this object.
\[MemberQueryFilters \<List\<String\>\>\]: For queryType 'Filter', this is a stringified JSON filter array that will be validated by API middleware.
\[MemberQuerySearchFilters \<String\>\]: For queryType 'Search', this is a stringified JSON filter object that will be validated by API middleware.
\[MemberQueryType \<String\>\]:
\[MemberSuggestionsNotify \<Boolean?\>\]: True if notification emails are to be sent for membership suggestions.
\[MembershipMethod \<String\>\]: The type of membership method for this group.
Valid values include NOTSET, STATIC, DYNAMIC_REVIEW_REQUIRED, and DYNAMIC_AUTOMATED.
Note DYNAMIC_AUTOMATED and DYNAMIC_REVIEW_REQUIRED group rules will supersede any group enrollment for \[group-associated MDM-enrolled devices\](https://jumpcloud.com/support/change-a-default-device-group-for-apple-devices).
Use caution when creating dynamic device groups with MDM-enrolled devices to avoid creating conflicting rule sets.

INPUTOBJECT \<IJumpCloudApiIdentity\>: Identity Parameter
\[AccountId \<String\>\]:
\[ActivedirectoryId \<String\>\]:
\[AdministratorId \<String\>\]:
\[AgentId \<String\>\]:
\[AppleMdmId \<String\>\]:
\[ApplicationId \<String\>\]: ObjectID of the Application.
\[ApprovalFlowId \<String\>\]:
\[CommandId \<String\>\]: ObjectID of the Command.
\[CustomEmailType \<String\>\]:
\[DeviceId \<String\>\]:
\[GroupId \<String\>\]: ObjectID of the Policy Group.
\[GsuiteId \<String\>\]: ObjectID of the G Suite instance.
\[Id \<String\>\]: ObjectID of this Active Directory instance.
\[JobId \<String\>\]:
\[LdapserverId \<String\>\]: ObjectID of the LDAP Server.
\[Office365Id \<String\>\]: ObjectID of the Office 365 instance.
\[PolicyId \<String\>\]: ObjectID of the Policy.
\[ProviderId \<String\>\]:
\[PushEndpointId \<String\>\]:
\[RadiusserverId \<String\>\]: ObjectID of the Radius Server.
\[SoftwareAppId \<String\>\]: ObjectID of the Software App.
\[SystemId \<String\>\]: ObjectID of the System.
\[UserId \<String\>\]: ObjectID of the User.
\[WorkdayId \<String\>\]:

MEMBERQUERYEXEMPTIONS \<IGraphObject\[\]\>: Array of GraphObjects exempted from the query
Id \<String\>: The ObjectID of the graph object.
Type \<String\>: The type of graph object.
\[Attributes \<IGraphAttributes\>\]: The graph attributes.
\[(Any) \<Object\>\]: This indicates any property can be added to this object.

## RELATED LINKS

[https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Set-JcSdkUserGroup.md](https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Set-JcSdkUserGroup.md)
