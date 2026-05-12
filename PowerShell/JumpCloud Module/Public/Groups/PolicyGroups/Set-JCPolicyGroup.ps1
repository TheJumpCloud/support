<#
.Synopsis
This endpoint allows you to do a full set of the Policy Group.
.Description
This endpoint allows you to do a full set of the Policy Group.
.Example
PS C:\> Set-JCPolicyGroup -Id:(<string>) -Body:(<JumpCloud.SDK.V2.Models.PolicyGroupData>)



----        ----------
Attributes  JumpCloud.SDK.V2.Models.GraphAttributes
Description String
Email       String
Id          String
Name        String
Type        String


.Example
PS C:\> Set-JCPolicyGroup -Id:(<string>) -Name:(<string>)



----        ----------
Attributes  JumpCloud.SDK.V2.Models.GraphAttributes
Description String
Email       String
Id          String
Name        String
Type        String



.Inputs
JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
.Inputs
JumpCloud.SDK.V2.Models.IPolicyGroupData
.Outputs
JumpCloud.SDK.V2.Models.IPolicyGroup
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

BODY <IPolicyGroupData>: PolicyGroupData
  Name <String>: Display name of a Policy Group.

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
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/Set-JcSdkPolicyGroup.md
#>
Function Set-JCPolicyGroup {
    [OutputType([JumpCloud.SDK.V2.Models.IPolicyGroup])]
    [CmdletBinding(DefaultParameterSetName='SetExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    Param(
        [Parameter(ParameterSetName='SetExpanded', Mandatory)]
        [Parameter(ParameterSetName='Set', Mandatory)]
        
        [Alias('_id', 'PolicyGroupID')]
        [JumpCloud.SDK.V2.Category('Path')]
        [System.String]
        # ObjectID of the Policy Group.
        ${Id},
        
        [Parameter(ParameterSetName='SetViaIdentityExpanded', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName='SetViaIdentity', Mandatory, ValueFromPipeline)]
        [JumpCloud.SDK.V2.Category('Path')]
        [JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity]
        # Identity Parameter
        ${InputObject},
        
        [Parameter(ParameterSetName='SetExpanded')]
        [Parameter(ParameterSetName='SetViaIdentityExpanded')]
        [JumpCloud.SDK.V2.Category('Body')]
        [System.String]
        # Display name of a Policy Group.
        ${Name},
        
        [Parameter(ParameterSetName='Set', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName='SetViaIdentity', Mandatory, ValueFromPipeline)]
        [JumpCloud.SDK.V2.Category('Body')]
        [JumpCloud.SDK.V2.Models.IPolicyGroupData]
        # PolicyGroupData
        ${Body}
    )
    Begin {
        Connect-JCOnline -force | Out-Null
        $Results = @()
    }
    Process {
        $Results = JumpCloud.SDK.V2\Set-JcSdkPolicyGroup @PSBoundParameters
    }
    End {
        Return $Results
    }
}
