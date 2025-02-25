<#
.Synopsis
Request a JumpCloud report to be generated asynchronously
.Description
Request a JumpCloud report to be generated asynchronously
.Example
PS C:\> New-JCReport -ReportType 'users-to-sso-applications'

Queues creation of an user-to-sso-application report
.Example
PS C:\> New-JCReport -ReportType 'users-to-devices'

Queues creation of an users-to-devices report

.Inputs
JumpCloud.SDK.DirectoryInsights.Models.IDirectoryInsightsApiIdentity
.Outputs
JumpCloud.SDK.DirectoryInsights.Models.IPathsE6Q3GdReportsReportTypePostResponses202ContentApplicationJsonSchema
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

INPUTOBJECT <IDirectoryInsightsApiIdentity>: Identity Parameter
  [ReportType <ReportType1?>]: Report Type
.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/New-JcSdkReport.md
#>
Function New-JCReport {
    [OutputType([JumpCloud.SDK.DirectoryInsights.Models.IPathsE6Q3GdReportsReportTypePostResponses202ContentApplicationJsonSchema])]
    [CmdletBinding(DefaultParameterSetName = 'Create', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    Param(
        [Parameter(ParameterSetName = 'Create', Mandatory)]
        [ArgumentCompleter([JumpCloud.SDK.DirectoryInsights.Support.ReportType1])]
        [JumpCloud.SDK.DirectoryInsights.Category('Path')]
        [JumpCloud.SDK.DirectoryInsights.Support.ReportType1]
        [ValidateSet(
            "browser-patch-policy",
            "os-patch-policy",
            "users-to-devices",
            "users-to-directories",
            "users-to-ldap-servers",
            "users-to-radius-servers",
            "users-to-sso-applications",
            "users-to-user-groups",
            "user-account-health",
            "software-inventory",
            "os-version"
        )]
        # Report Type
        ${ReportType},

        [Parameter(ParameterSetName = 'CreateViaIdentity', Mandatory, ValueFromPipeline)]
        [JumpCloud.SDK.DirectoryInsights.Category('Path')]
        [JumpCloud.SDK.DirectoryInsights.Models.IDirectoryInsightsApiIdentity]
        # Identity Parameter
        # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
        ${InputObject}
    )
    Begin {
        Connect-JCOnline -force | Out-Null
        $Results = @()
    }
    Process {
        $Results = JumpCloud.SDK.DirectoryInsights\New-JcSdkReport @PSBoundParameters
    }
    End {
        Return $Results
    }
}
