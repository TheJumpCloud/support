<#
.Synopsis
Query the API for a count of matching events
.Description
Query the API for a count of matching events
.Example
PS C:\> Get-JCEventCount -Service:('all') -StartTime:((Get-date).AddDays(-30))

Pull all event records from a specified time and count the results
.Example
PS C:\> Get-JCEventCount -Service:('sso') -StartTime:('2020-04-14T00:00:00Z')

Pull all SSO event records from a specified time and count the results
.Example
PS C:\> Get-JCEventCount -Service:('all') -StartTime:('2020-04-14T00:00:00Z') -EndTime:('2020-04-20T23:00:00Z') -SearchTermAnd @{"event_type" = "admin_login_attempt"; "resource.email" = "admin.user@adminbizorg.com"}

Get all events counts between a date range and match event_type = admin_login_attempt and resource.email = admin.user@adminbizorg.com
.Example
PS C:\> Get-JCEventCount -Service:('directory') -StartTime:((Get-date).AddDays(-30)) -searchTermAnd:@{"event_type" = "group_create"}

Get only group_create event counts the last thirty days

.Inputs
JumpCloud.SDK.DirectoryInsights.Models.IEventQuery
.Outputs
System.Int64
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

BODY <IEventQuery>: EventQuery is the users' command to search our auth logs
  Service <String[]>: service name to query. Known services: systems,radius,sso,directory,ldap,all
  StartTime <DateTime>: query start time, UTC in RFC3339 format
  [EndTime <DateTime?>]: optional query end time, UTC in RFC3339 format
  [Fields <String[]>]: optional list of fields to return from query
  [Limit <Int64?>]: Max number of rows to return
  [SearchAfter <IEventQuerySearchAfterItem[]>]: Specific query to search after, see x-* response headers for next values
  [SearchTermAnd <ITermConjunction>]: TermConjunction represents a conjunction (and/or)         NOTE: the validator limits what the operator can be, not the object         for future-proof-ness         and a list of sub-values
    [(Any) <Object>]: This indicates any property can be added to this object.
  [SearchTermOr <ITermConjunction>]: TermConjunction represents a conjunction (and/or)         NOTE: the validator limits what the operator can be, not the object         for future-proof-ness         and a list of sub-values
  [Sort <String>]: ASC or DESC order for timestamp
.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/Get-JcSdkEventCount.md
#>
Function Get-JCEventCount
{
    [OutputType([System.Int64])]
    [CmdletBinding(DefaultParameterSetName='GetExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    Param(
    [Parameter(ParameterSetName='GetExpanded', Mandatory)]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String[]]
    # service name to query.
    # Known services: systems,radius,sso,directory,ldap,all
    ${Service},

    [Parameter(ParameterSetName='GetExpanded', Mandatory)]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.DateTime]
    # query start time, UTC in RFC3339 format
    ${StartTime},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.DateTime]
    # optional query end time, UTC in RFC3339 format
    ${EndTime},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String[]]
    # optional list of fields to return from query
    ${Fields},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [JumpCloud.SDK.DirectoryInsights.Models.IEventQuerySearchAfterItem[]]
    # Specific query to search after, see x-* response headers for next values
    ${SearchAfter},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [JumpCloud.SDK.DirectoryInsights.Runtime.Info(PossibleTypes=([JumpCloud.SDK.DirectoryInsights.Models.ITermConjunction]))]
    [System.Collections.Hashtable]
    # TermConjunction represents a conjunction (and/or)NOTE: the validator limits what the operator can be, not the objectfor future-proof-nessand a list of sub-values
    ${SearchTermAnd},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [JumpCloud.SDK.DirectoryInsights.Runtime.Info(PossibleTypes=([JumpCloud.SDK.DirectoryInsights.Models.ITermConjunction]))]
    [System.Collections.Hashtable]
    # TermConjunction represents a conjunction (and/or)NOTE: the validator limits what the operator can be, not the objectfor future-proof-nessand a list of sub-values
    ${SearchTermOr},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String]
    # ASC or DESC order for timestamp
    ${Sort},

    [Parameter(ParameterSetName='Get', Mandatory, ValueFromPipeline)]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [JumpCloud.SDK.DirectoryInsights.Models.IEventQuery]
    # EventQuery is the users' command to search our auth logs
    # To construct, see NOTES section for BODY properties and create a hash table.
    ${Body}
    )
    Begin
    {
        Connect-JCOnline -force | Out-Null
        $Results = @()
    }
    Process
    {
        $Results = JumpCloud.SDK.DirectoryInsights\Get-JcSdkEventCount @PSBoundParameters
    }
    End
    {
        Return $Results
    }
}
