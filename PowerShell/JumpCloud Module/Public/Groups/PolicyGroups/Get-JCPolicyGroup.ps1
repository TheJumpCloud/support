<#
.Synopsis
This endpoint returns the details of a Policy Group.
.Description
This endpoint returns the details of a Policy Group.
.Example
PS C:\> Get-JCPolicyGroup -Fields:(<string[]>) -Filter:(<string[]>) -Sort:(<string[]>)



----        ----------
Attributes  JumpCloud.SDK.V2.Models.GraphAttributes
Description String
Email       String
Id          String
Name        String
Type        String


.Example
PS C:\> Get-JCPolicyGroup -Id:(<string>)



----        ----------
Attributes  JumpCloud.SDK.V2.Models.GraphAttributes
Description String
Email       String
Id          String
Name        String
Type        String



.Inputs
JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
.Outputs
JumpCloud.SDK.V2.Models.IPolicyGroup
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

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
.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Get-JcSdkPolicyGroup.md
#>
Function Get-JCPolicyGroup {
    [OutputType([JumpCloud.SDK.V2.Models.IPolicyGroup])]
    [CmdletBinding(DefaultParameterSetName='List', PositionalBinding=$false)]
    Param(
        [Parameter(ParameterSetName='Get', Mandatory)]
        
        [Alias('_id', 'PolicyGroupID')]
        [JumpCloud.SDK.V2.Category('Path')]
        [System.String]
        # ObjectID of the Policy Group.
        ${Id},
        
        [Parameter(ParameterSetName='GetViaIdentity', Mandatory, ValueFromPipeline)]
        [JumpCloud.SDK.V2.Category('Path')]
        [JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity]
        # Identity Parameter
        ${InputObject},
        
        [Parameter(ParameterSetName='List')]
        [AllowEmptyCollection()]
        [JumpCloud.SDK.V2.Category('Query')]
        [JumpCloud.SDK.V2.Runtime.Info(PossibleTypes=([System.String]))]
        [System.Collections.Generic.List[System.String]]
        # The comma separated fields included in the returned records.
        # If omitted, the default list of fields will be returned.
        ${Fields},
        
        [Parameter(ParameterSetName='List')]
        [AllowEmptyCollection()]
        [JumpCloud.SDK.V2.Category('Query')]
        [JumpCloud.SDK.V2.Runtime.Info(PossibleTypes=([System.String]))]
        [System.Collections.Generic.List[System.String]]
        # A filter to apply to the query.
        #
        # **Filter structure**: `<field>:<operator>:<value>`.
        #
        # **field** = Populate with a valid field from an endpoint response.
        #
        # **operator** = Supported operators are: eq, ne, gt, ge, lt, le, between, search, in.
        # _Note: v1 operators differ from v2 operators._
        #
        # **value** = Populate with the value you want to search for.
        # Is case sensitive.
        # Supports wild cards.
        #
        # **EX:** `GET /api/v2/groups?filter=name:eq:Test+Group`
        ${Filter},
        
        [Parameter(ParameterSetName='List')]
        [AllowEmptyCollection()]
        [JumpCloud.SDK.V2.Category('Query')]
        [JumpCloud.SDK.V2.Runtime.Info(PossibleTypes=([System.String]))]
        [System.Collections.Generic.List[System.String]]
        # The comma separated fields used to sort the collection.
        # Default sort is ascending, prefix with `-` to sort descending.
        ${Sort}
    )
    Begin {
        Connect-JCOnline -force | Out-Null
        $Results = @()
    }
    Process {
        $Results = JumpCloud.SDK.V2\Get-JcSdkPolicyGroup @PSBoundParameters
    }
    End {
        Return $Results
    }
}
