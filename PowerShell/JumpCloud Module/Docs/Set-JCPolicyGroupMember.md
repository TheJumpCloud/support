---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Set-JCPolicyGroupMember

## SYNOPSIS

This endpoint allows you to manage the Policy members of a Policy Group.

## SYNTAX

### SetExpanded (Default)
```
Set-JCPolicyGroupMember -GroupId <String> [-Attributes <Hashtable>] [-Id <String>] [-Op <String>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Set
```
Set-JCPolicyGroupMember -GroupId <String> -Body <IGraphOperationPolicyGroupMember> [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SetViaIdentity
```
Set-JCPolicyGroupMember -InputObject <IJumpCloudApiIdentity> -Body <IGraphOperationPolicyGroupMember>
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### SetViaIdentityExpanded
```
Set-JCPolicyGroupMember -InputObject <IJumpCloudApiIdentity> [-Attributes <Hashtable>] [-Id <String>]
 [-Op <String>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This endpoint allows you to manage the Policy members of a Policy Group.

## EXAMPLES

### EXAMPLE 1

```
Set-JCPolicyGroupMember -GroupId:(<string>) -Body:(<JumpCloud.SDK.V2.Models.GraphOperationPolicyGroupMember>)
```

### EXAMPLE 2

```
Set-JCPolicyGroupMember -GroupId:(<string>) -Id:(<string>) -Op:(<string>) -Attributes:(<hashtable>)
```

## PARAMETERS

### -Attributes

The graph attributes.

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

GraphOperation (PolicyGroup-Member)

```yaml
Type: JumpCloud.SDK.V2.Models.IGraphOperationPolicyGroupMember
Parameter Sets: Set, SetViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -GroupId

ObjectID of the Policy Group.

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

### -Id

The ObjectID of graph object being added or removed as an association.

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

### -Op

How to modify the graph connection.

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

### -PassThru

Returns true when the command succeeds

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### JumpCloud.SDK.V2.Models.IGraphOperationPolicyGroupMember
### JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
## OUTPUTS

### System.Boolean
## NOTES

COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties.
For information on hash tables, run Get-Help about_Hash_Tables.

BODY \<IGraphOperationPolicyGroupMember\>: GraphOperation (PolicyGroup-Member)
Id \<String\>: The ObjectID of graph object being added or removed as an association.
Op \<String\>: How to modify the graph connection.
\[Attributes \<IGraphAttributes\>\]: The graph attributes.
\[(Any) \<Object\>\]: This indicates any property can be added to this object.

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

[https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Set-JcSdkPolicyGroupMember.md](https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Set-JcSdkPolicyGroupMember.md)
