<#
.Synopsis
Query the API for Directory Insights events
.Description
Query the API for Directory Insights events
.Example
PS C:\> Get-JCEvent -Service:('all') -StartTime:((Get-date).AddDays(-30))

Pull all event records from the last thirty days
.Example
PS C:\> Get-JCEvent -Service:('directory') -StartTime:((Get-date).AddHours(-1)) -Limit:('10')

Get directory results from the last hour limit to the last 10 results in the time range
.Example
PS C:\> Get-JCEvent -Service:('directory') -StartTime:((Get-date).AddDays(-30)) -Sort:("DESC") -EndTime:((Get-date).AddDays(-5))

Get directory results between 30 and 5 days ago, sort timestamp by descending value
.Example
PS C:\> Get-JCEvent -Service:('directory') -StartTime:((Get-date).AddDays(-30)) -Limit:('10') -searchTermAnd:@{"event_type" = "group_create"}

Get only group_create from the last thirty days
.Example
PS C:\> Get-JCEvent -Service:('all') -StartTime:('2020-04-14T00:00:00Z') -EndTime:('2020-04-20T23:00:00Z') -SearchTermOr @{"initiated_by.username" = @("user.1", "user.2")}

Get login events initiated by either "user.1" or "user.2" between a universal time zone range
.Example
PS C:\> Get-JCEvent -Service:('all') -StartTime:('2020-04-14T00:00:00Z') -EndTime:('2020-04-20T23:00:00Z') -SearchTermAnd @{"event_type" = "admin_login_attempt"; "resource.email" = "admin.user@adminbizorg.com"}

Get all events between a date range and match event_type = admin_login_attempt and resource.email = admin.user@adminbizorg.com
.Example
PS C:\> Get-JCEvent -Service:('sso') -StartTime:('2020-04-14T00:00:00Z')  -EndTime:('2020-04-20T23:00:00Z') -SearchTermAnd @{"initiated_by.username" = "user.1"}

Get sso events with the search term initiated_by: username with value "user.1"
.Example
PS C:\> Get-JCEvent -Service:('all') -StartTime:('2020-04-14T00:00:00Z') -EndTime:('2020-04-20T23:00:00Z') -SearchTermAnd @{"event_type" = "organization_update"}

Get all events filtered by organization_update term between a date range

.Inputs
JumpCloud.SDK.DirectoryInsights.Models.IEventQuery
.Outputs
JumpCloud.SDK.DirectoryInsights.Models.IPost200ApplicationJsonItemsItem
.Outputs
System.String
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

BODY <IEventQuery>: EventQuery is the users' command to search our auth logs
  Service <String[]>: service name to query. Known services: systems,radius,sso,directory,ldap,all
  StartTime <DateTime>: query start time, UTC in RFC3339 format
  [EndTime <DateTime?>]: optional query end time, UTC in RFC3339 format
  [Fields <String[]>]: optional list of fields to return from query
  [Limit <Int64?>]: Max number of rows to return
  [SearchAfter <String[]>]: Specific query to search after, see x-* response headers for next values
  [SearchTermAnd <ISearchTermAnd>]: list of event terms. If all terms match the event will be returned by the service.
    [(Any) <Object>]: This indicates any property can be added to this object.
  [SearchTermOr <ISearchTermOr>]: list of event terms. If any term matches, the event will be returned by the service.
    [(Any) <Object>]: This indicates any property can be added to this object.
  [Sort <String>]: ASC or DESC order for timestamp
.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/Get-JcSdkEvent.md
#>
Function Get-JCEvent
{
    [OutputType([JumpCloud.SDK.DirectoryInsights.Models.IPost200ApplicationJsonItemsItem], [System.String])]
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
    [System.String[]]
    # Specific query to search after, see x-* response headers for next values
    ${SearchAfter},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [JumpCloud.SDK.DirectoryInsights.Runtime.Info(PossibleTypes=([JumpCloud.SDK.DirectoryInsights.Models.ISearchTermAnd]))]
    [System.Collections.Hashtable]
    # list of event terms.
    # If all terms match the event will be returned by the service.
    ${SearchTermAnd},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [JumpCloud.SDK.DirectoryInsights.Runtime.Info(PossibleTypes=([JumpCloud.SDK.DirectoryInsights.Models.ISearchTermOr]))]
    [System.Collections.Hashtable]
    # list of event terms.
    # If any term matches, the event will be returned by the service.
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
        $Results = JumpCloud.SDK.DirectoryInsights\Get-JcSdkEvent @PSBoundParameters
    }
    End
    {
        Return $Results
    }
}
