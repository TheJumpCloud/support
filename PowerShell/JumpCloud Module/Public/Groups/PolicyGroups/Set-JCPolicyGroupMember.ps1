<#
.Synopsis
This endpoint allows you to manage the Policy members of a Policy Group.

#### Sample Request
```
curl -X POST https://console.jumpcloud.com/api/v2/policygroups/{GroupID}/members \\
  -H 'Accept: application/json' \\
  -H 'Content-Type: application/json' \\
  -H 'x-api-key: {API_KEY}' \\
  -d '{
    \"op\": \"add\",
    \"type\": \"policy\",
    \"id\": \"{Policy_ID}\"
  }'
```
.Description
This endpoint allows you to manage the Policy members of a Policy Group.

#### Sample Request
```
curl -X POST https://console.jumpcloud.com/api/v2/policygroups/{GroupID}/members \\
  -H 'Accept: application/json' \\
  -H 'Content-Type: application/json' \\
  -H 'x-api-key: {API_KEY}' \\
  -d '{
    \"op\": \"add\",
    \"type\": \"policy\",
    \"id\": \"{Policy_ID}\"
  }'
```
.Example
PS C:\> Set-JCPolicyGroupMember -GroupId:(<string>) -Body:(<JumpCloud.SDK.V2.Models.GraphOperationPolicyGroupMember>)


.Example
PS C:\> Set-JCPolicyGroupMember -GroupId:(<string>) -Id:(<string>) -Op:(<string>) -Attributes:(<hashtable>)



.Inputs
JumpCloud.SDK.V2.Models.IGraphOperationPolicyGroupMember
.Inputs
JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
.Outputs
System.Boolean
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

BODY <IGraphOperationPolicyGroupMember>: GraphOperation (PolicyGroup-Member)
  Id <String>: The ObjectID of graph object being added or removed as an association.
  Op <String>: How to modify the graph connection.
  [Attributes <IGraphAttributes>]: The graph attributes.
    [(Any) <Object>]: This indicates any property can be added to this object.

INPUTOBJECT <IJumpCloudApiIdentity>: Identity Parameter
  [AccountId <String>]: 
  [ActivedirectoryId <String>]: 
  [AdministratorId <String>]: 
  [AgentId <String>]: 
  [AppleMdmId <String>]: 
  [ApplicationId <String>]: ObjectID of the Application.
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
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Set-JcSDKPolicyGroupMember.md
#>
Function Set-JCPolicyGroupMember {
    [OutputType([System.Boolean])]
    [CmdletBinding(DefaultParameterSetName='SetExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    Param(
        [Parameter(ParameterSetName='SetExpanded', Mandatory)]
        [Parameter(ParameterSetName='Set', Mandatory)]
        [JumpCloud.SDK.V2.Category('Path')]
        [System.String]
        # ObjectID of the Policy Group.
        ${GroupId},
        
        [Parameter(ParameterSetName='SetViaIdentityExpanded', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName='SetViaIdentity', Mandatory, ValueFromPipeline)]
        [JumpCloud.SDK.V2.Category('Path')]
        [JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity]
        # Identity Parameter
        ${InputObject},
        
        [Parameter(ParameterSetName='SetExpanded')]
        [Parameter(ParameterSetName='SetViaIdentityExpanded')]
        [JumpCloud.SDK.V2.Category('Body')]
        [JumpCloud.SDK.V2.Runtime.Info(PossibleTypes=([JumpCloud.SDK.V2.Models.IGraphAttributes]))]
        [System.Collections.Hashtable]
        # The graph attributes.
        ${Attributes},
        
        [Parameter(ParameterSetName='SetExpanded')]
        [Parameter(ParameterSetName='SetViaIdentityExpanded')]
        [JumpCloud.SDK.V2.Category('Body')]
        [System.String]
        # The ObjectID of graph object being added or removed as an association.
        ${Id},
        
        [Parameter(ParameterSetName='SetExpanded')]
        [Parameter(ParameterSetName='SetViaIdentityExpanded')]
        [JumpCloud.SDK.V2.Category('Body')]
        [System.String]
        # How to modify the graph connection.
        ${Op},
        
        [Parameter(ParameterSetName='Set', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName='SetViaIdentity', Mandatory, ValueFromPipeline)]
        [JumpCloud.SDK.V2.Category('Body')]
        [JumpCloud.SDK.V2.Models.IGraphOperationPolicyGroupMember]
        # GraphOperation (PolicyGroup-Member)
        ${Body},
        
        [Parameter()]
        [JumpCloud.SDK.V2.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Returns true when the command succeeds
        ${PassThru}
    )
    Begin {
        Connect-JCOnline -force | Out-Null
        $Results = @()
    }
    Process {
        $Results = JumpCloud.SDK.V2\Set-JcSdkPolicyGroupMember @PSBoundParameters
    }
    End {
        Return $Results
    }
}
