<#
.Synopsis
This endpoint allows you to create a new Policy Group.

#### Sample Request
```
curl -X POST https://console.jumpcloud.com/api/v2/policygroups \\
  -H 'Accept: application/json' \\
  -H 'Content-Type: application/json' \\
  -H 'x-api-key: {API_KEY}' \\
  -d '{
    \"name\": \"{Group_Name}\"
  }'
```
.Description
This endpoint allows you to create a new Policy Group.

#### Sample Request
```
curl -X POST https://console.jumpcloud.com/api/v2/policygroups \\
  -H 'Accept: application/json' \\
  -H 'Content-Type: application/json' \\
  -H 'x-api-key: {API_KEY}' \\
  -d '{
    \"name\": \"{Group_Name}\"
  }'
```
.Example
PS C:\> New-JCPolicyGroup -Name:(<string>)



----        ----------
Attributes  JumpCloud.SDK.V2.Models.GraphAttributes
Description String
Email       String
Id          String
Name        String
Type        String


.Example
PS C:\> New-JCPolicyGroup -Body:(<JumpCloud.SDK.V2.Models.PolicyGroupData>)



----        ----------
Attributes  JumpCloud.SDK.V2.Models.GraphAttributes
Description String
Email       String
Id          String
Name        String
Type        String



.Inputs
JumpCloud.SDK.V2.Models.IPolicyGroupData
.Outputs
JumpCloud.SDK.V2.Models.IPolicyGroup
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

BODY <IPolicyGroupData>: PolicyGroupData
  Name <String>: Display name of a Policy Group.
.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.V2/docs/exports/New-JcSdkPolicyGroup.md
#>
Function New-JCPolicyGroup {
    [OutputType([JumpCloud.SDK.V2.Models.IPolicyGroup])]
    [CmdletBinding(DefaultParameterSetName='CreateExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    Param(
        [Parameter(ParameterSetName='CreateExpanded')]
        [JumpCloud.SDK.V2.Category('Body')]
        [System.String]
        # Display name of a Policy Group.
        ${Name},
        
        [Parameter(ParameterSetName='Create', Mandatory, ValueFromPipeline)]
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
        $Results = JumpCloud.SDK.V2\New-JcSdkPolicyGroup @PSBoundParameters
    }
    End {
        Return $Results
    }
}
