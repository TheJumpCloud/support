---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCSystemGroup

## SYNOPSIS

This endpoint returns the details of a System Group.

## SYNTAX

### List (Default)
```
Get-JCSystemGroup [-Fields <System.Collections.Generic.List`1[System.String]>]
 [-Filter <System.Collections.Generic.List`1[System.String]>]
 [-Sort <System.Collections.Generic.List`1[System.String]>]
 [<CommonParameters>]
```

### Get
```
Get-JCSystemGroup -Id <String> [<CommonParameters>]
```

### GetViaIdentity
```
Get-JCSystemGroup -InputObject <IJumpCloudApiIdentity>
 [<CommonParameters>]
```

## DESCRIPTION

This endpoint returns the details of a System Group.

## EXAMPLES

### EXAMPLE 1

```
Get-JCSystemGroup -Fields:(<string[]>) -Filter:(<string[]>) -Sort:(<string[]>)
```

---

Attributes JumpCloud.SDK.V2.Models.GraphAttributes
Description String
Email String
Id String
MemberQueryExemptions JumpCloud.SDK.V2.Models.GraphObject\[\]
MemberQueryFilters JumpCloud.SDK.V2.Models.Any\[\]
MemberQueryType String
MembershipMethod String
MemberSuggestionsNotify Boolean
Name String
Type String

### EXAMPLE 2

```
Get-JCSystemGroup -Id:(<string>)
```

---

Attributes JumpCloud.SDK.V2.Models.GraphAttributes
Description String
Email String
Id String
MemberQueryExemptions JumpCloud.SDK.V2.Models.GraphObject\[\]
MemberQueryFilters JumpCloud.SDK.V2.Models.Any\[\]
MemberQueryType String
MembershipMethod String
MemberSuggestionsNotify Boolean
Name String
Type String

## PARAMETERS

### -Fields

The comma separated fields included in the returned records.
If omitted, the default list of fields will be returned.

```yaml
Type: System.Collections.Generic.List`1[System.String]
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter

A filter to apply to the query.

**Filter structure**: \`\<field\>:\<operator\>:\<value\>\`.

**field** = Populate with a valid field from an endpoint response.

**operator** = Supported operators are: eq, ne, gt, ge, lt, le, between, search, in.
_Note: v1 operators differ from v2 operators._

**value** = Populate with the value you want to search for.
Is case sensitive.
Supports wild cards.

**EX:** \`GET /api/v2/groups?filter=name:eq:Test+Group\`

```yaml
Type: System.Collections.Generic.List`1[System.String]
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

ObjectID of the System Group.

```yaml
Type: System.String
Parameter Sets: Get
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
Parameter Sets: GetViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Sort

The comma separated fields used to sort the collection.
Default sort is ascending, prefix with \`-\` to sort descending.

```yaml
Type: System.Collections.Generic.List`1[System.String]
Parameter Sets: List
Aliases:

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
## OUTPUTS

### JumpCloud.SDK.V2.Models.ISystemGroup
## NOTES

COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties.
For information on hash tables, run Get-Help about_Hash_Tables.

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

## RELATED LINKS

[https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Get-JcSdkSystemGroup.md](https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Get-JcSdkSystemGroup.md)
