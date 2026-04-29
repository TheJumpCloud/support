<#
.Synopsis
This endpoint allows you to do a full set of the User Group.

See the [Dynamic Group Configuration KB article](https://jumpcloud.com/support/configure-dynamic-device-groups) for more details on maintaining a Dynamic Group.

.Description
This endpoint allows you to do a full set of the User Group.

See the [Dynamic Group Configuration KB article](https://jumpcloud.com/support/configure-dynamic-device-groups) for more details on maintaining a Dynamic Group.

.Example
PS C:\> Set-JCUserGroup -Id:(<string>) -Body:(<JumpCloud.SDK.V2.Models.UserGroupPut>)



----                    ----------
Attributes              JumpCloud.SDK.V2.Models.GroupAttributesUserGroup
Description             String
Email                   String
Id                      String
MemberQueryExemptions   JumpCloud.SDK.V2.Models.GraphObject[]
MemberQueryFilters      JumpCloud.SDK.V2.Models.Any[]
MemberQueryType         String
MembershipMethod        String
MemberSuggestionsNotify Boolean
Name                    String
SuggestionCountAdd      Int
SuggestionCountRemove   Int
SuggestionCountTotal    Int
Type                    String


.Example
PS C:\> Set-JCUserGroup -Id:(<string>) -Name:(<string>) -Attributes:(<hashtable>) -Description:(<string>) -Email:(<string>) -MemberQueryExemptions:(<JumpCloud.SDK.V2.Models.GraphObject[]>) -MemberQueryFilters:(<JumpCloud.SDK.V2.Models.Any[]>) -MemberQueryType:(<string>) -MemberSuggestionsNotify:(<switch>) -MembershipMethod:(<string>)



----                    ----------
Attributes              JumpCloud.SDK.V2.Models.GroupAttributesUserGroup
Description             String
Email                   String
Id                      String
MemberQueryExemptions   JumpCloud.SDK.V2.Models.GraphObject[]
MemberQueryFilters      JumpCloud.SDK.V2.Models.Any[]
MemberQueryType         String
MembershipMethod        String
MemberSuggestionsNotify Boolean
Name                    String
SuggestionCountAdd      Int
SuggestionCountRemove   Int
SuggestionCountTotal    Int
Type                    String



.Inputs
JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
.Inputs
JumpCloud.SDK.V2.Models.IUserGroupPut
.Outputs
JumpCloud.SDK.V2.Models.IUserGroup
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

BODY <IUserGroupPut>: UserGroupPut
  Name <String>: Display name of a User Group.
  [Attributes <IGroupAttributesUserGroup>]: The graph attributes for a UserGroup.
    [(Any) <Object>]: This indicates any property can be added to this object.
    [SudoEnabled <Boolean?>]: Enables sudo
    [SudoWithoutPassword <Boolean?>]: Enable sudo without password (requires 'enabled' to be true)
    [LdapGroups <List<ILdapGroup>>]:
      [Name <String>]:
    [PosixGroups <List<IGraphAttributePosixGroupsItem>>]:
      Id <Int32>:
      Name <String>:
    [RadiusReply <List<IGraphAttributeRadiusReplyItem>>]:
      Name <String>:
      Value <String>:
    [SambaEnabled <Boolean?>]:
  [Description <String>]: Description of a User Group
  [Email <String>]: Email address of a User Group
  [MemberQueryExemptions <List<IGraphObject>>]: Array of GraphObjects exempted from the query
    Id <String>: The ObjectID of the graph object.
    Type <String>: The type of graph object.
    [Attributes <IGraphAttributes>]: The graph attributes.
      [(Any) <Object>]: This indicates any property can be added to this object.
  [MemberQueryFilters <List<String>>]: For queryType 'Filter', this is a stringified JSON filter array that will be validated by API middleware.
  [MemberQuerySearchFilters <String>]: For queryType 'Search', this is a stringified JSON filter object that will be validated by API middleware.
  [MemberQueryType <String>]:
  [MemberSuggestionsNotify <Boolean?>]: True if notification emails are to be sent for membership suggestions.
  [MembershipMethod <String>]: The type of membership method for this group. Valid values include NOTSET, STATIC, DYNAMIC_REVIEW_REQUIRED, and DYNAMIC_AUTOMATED.          Note DYNAMIC_AUTOMATED and DYNAMIC_REVIEW_REQUIRED group rules will supersede any group enrollment for [group-associated MDM-enrolled devices](https://jumpcloud.com/support/change-a-default-device-group-for-apple-devices).          Use caution when creating dynamic device groups with MDM-enrolled devices to avoid creating conflicting rule sets.

INPUTOBJECT <IJumpCloudApiIdentity>: Identity Parameter
  [AccountId <String>]:
  [ActivedirectoryId <String>]:
  [AdministratorId <String>]:
  [AgentId <String>]:
  [AppleMdmId <String>]:
  [ApplicationId <String>]: ObjectID of the Application.
  [ApprovalFlowId <String>]:
  [CommandId <String>]: ObjectID of the Command.
  [CustomEmailType <String>]:
  [DeviceId <String>]:
  [GroupId <String>]: ObjectID of the Policy Group.
  [GsuiteId <String>]: ObjectID of the G Suite instance.
  [Id <String>]: ObjectID of this Active Directory instance.
  [JobId <String>]:
  [LdapserverId <String>]: ObjectID of the LDAP Server.
  [Office365Id <String>]: ObjectID of the Office 365 instance.
  [PolicyId <String>]: ObjectID of the Policy.
  [ProviderId <String>]:
  [PushEndpointId <String>]:
  [RadiusserverId <String>]: ObjectID of the Radius Server.
  [SoftwareAppId <String>]: ObjectID of the Software App.
  [SystemId <String>]: ObjectID of the System.
  [UserId <String>]: ObjectID of the User.
  [WorkdayId <String>]:

MEMBERQUERYEXEMPTIONS <IGraphObject[]>: Array of GraphObjects exempted from the query
  Id <String>: The ObjectID of the graph object.
  Type <String>: The type of graph object.
  [Attributes <IGraphAttributes>]: The graph attributes.
    [(Any) <Object>]: This indicates any property can be added to this object.
.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Set-JcSdkUserGroup.md
#>
function Set-JCUserGroup {
  [OutputType([JumpCloud.SDK.V2.Models.IUserGroup])]
  [CmdletBinding(DefaultParameterSetName = 'SetExpanded', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param(
    [Parameter(ParameterSetName = 'SetExpanded', Mandatory)]
    [Parameter(ParameterSetName = 'Set', Mandatory)]
    [JumpCloud.SDK.V2.Category('Path')]
    [System.String]
    # ObjectID of the User Group.
    ${Id},

    [Parameter(ParameterSetName = 'SetViaIdentityExpanded', Mandatory, ValueFromPipeline)]
    [Parameter(ParameterSetName = 'SetViaIdentity', Mandatory, ValueFromPipeline)]
    [JumpCloud.SDK.V2.Category('Path')]
    [JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity]
    # Identity Parameter
    ${InputObject},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [JumpCloud.SDK.V2.Category('Body')]
    [JumpCloud.SDK.V2.Runtime.Info(PossibleTypes = ([JumpCloud.SDK.V2.Models.IGroupAttributesUserGroup]))]
    [System.Collections.Hashtable]
    # The graph attributes for a UserGroup.
    ${Attributes},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [JumpCloud.SDK.V2.Category('Body')]
    [System.String]
    # Description of a User Group
    ${Description},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [JumpCloud.SDK.V2.Category('Body')]
    [System.String]
    # Email address of a User Group
    ${Email},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [AllowEmptyCollection()]
    [JumpCloud.SDK.V2.Category('Body')]
    [JumpCloud.SDK.V2.Models.IGraphObject[]]
    # Array of GraphObjects exempted from the query
    ${MemberQueryExemptions},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [AllowEmptyCollection()]
    [JumpCloud.SDK.V2.Category('Body')]
    [System.String[]]
    # For queryType 'Filter', this is a stringified JSON filter array that will be validated by API middleware.
    ${MemberQueryFilters},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [JumpCloud.SDK.V2.Category('Body')]
    [System.String]
    # For queryType 'Search', this is a stringified JSON filter object that will be validated by API middleware.
    ${MemberQuerySearchFilters},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [JumpCloud.SDK.V2.Category('Body')]
    [System.String]
    # .
    ${MemberQueryType},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [JumpCloud.SDK.V2.Category('Body')]
    [System.Management.Automation.SwitchParameter]
    # True if notification emails are to be sent for membership suggestions.
    ${MemberSuggestionsNotify},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [JumpCloud.SDK.V2.Category('Body')]
    [System.String]
    # The type of membership method for this group.
    # Valid values include NOTSET, STATIC, DYNAMIC_REVIEW_REQUIRED, and DYNAMIC_AUTOMATED.Note DYNAMIC_AUTOMATED and DYNAMIC_REVIEW_REQUIRED group rules will supersede any group enrollment for [group-associated MDM-enrolled devices](https://jumpcloud.com/support/change-a-default-device-group-for-apple-devices).Use caution when creating dynamic device groups with MDM-enrolled devices to avoid creating conflicting rule sets.
    ${MembershipMethod},

    [Parameter(ParameterSetName = 'SetExpanded')]
    [Parameter(ParameterSetName = 'SetViaIdentityExpanded')]
    [JumpCloud.SDK.V2.Category('Body')]
    [System.String]
    # Display name of a User Group.
    ${Name},

    [Parameter(ParameterSetName = 'Set', Mandatory, ValueFromPipeline)]
    [Parameter(ParameterSetName = 'SetViaIdentity', Mandatory, ValueFromPipeline)]
    [JumpCloud.SDK.V2.Category('Body')]
    [JumpCloud.SDK.V2.Models.IUserGroupPut]
    # UserGroupPut
    ${Body}
  )
  begin {
    Connect-JCOnline -force | Out-Null
    $Results = @()
  }
  process {
    $Results = JumpCloud.SDK.V2\Set-JcSdkUserGroup @PSBoundParameters
  }
  end {
    return $Results
  }
}
