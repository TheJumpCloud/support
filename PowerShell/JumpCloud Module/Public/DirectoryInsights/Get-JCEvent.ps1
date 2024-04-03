<#
.Synopsis
Query the API for Directory Insights events
#### Sample Request
```
curl -X POST 'https://api.jumpcloud.com/insights/directory/v1/events' -H 'Content-Type: application/json' -H 'x-api-key: REPLACE_KEY_VALUE' --data '{\"service\": [\"all\"], \"start_time\": \"2021-07-14T23:00:00Z\", \"end_time\": \"2021-07-28T14:00:00Z\", \"sort\": \"DESC\", \"fields\": [\"timestamp\", \"event_type\", \"initiated_by\", \"success\", \"client_ip\", \"provider\", \"organization\"]}'
```
.Description
Query the API for Directory Insights events
#### Sample Request
```
curl -X POST 'https://api.jumpcloud.com/insights/directory/v1/events' -H 'Content-Type: application/json' -H 'x-api-key: REPLACE_KEY_VALUE' --data '{\"service\": [\"all\"], \"start_time\": \"2021-07-14T23:00:00Z\", \"end_time\": \"2021-07-28T14:00:00Z\", \"sort\": \"DESC\", \"fields\": [\"timestamp\", \"event_type\", \"initiated_by\", \"success\", \"client_ip\", \"provider\", \"organization\"]}'
```
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}

.Inputs
JumpCloud.SDK.DirectoryInsights.Models.IEventQuery
.Outputs
JumpCloud.SDK.DirectoryInsights.Models.IPost200ApplicationJsonItemsItem
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

BODY <IEventQuery>: EventQuery is the users' command to search our auth logs
  Service <String[]>: service name to query.
  StartTime <DateTime>: query start time, UTC in RFC3339 format
  [EndTime <DateTime?>]: optional query end time, UTC in RFC3339 format
  [Fields <String[]>]: optional list of fields to return from query
  [Limit <Int64?>]: Max number of rows to return
  [Q <String>]: optional string for specifying a full text query
  [SearchAfter <String[]>]: Specific query to search after, see x-* response headers for next values
  [SearchTermAnd <ITermConjunction>]: TermConjunction represents a conjunction (and/or)         NOTE: the validator limits what the operator can be, not the object         for future-proof-ness         and a list of sub-values
    [(Any) <Object>]: This indicates any property can be added to this object.
  [SearchTermNot <ITermConjunction>]: TermConjunction represents a conjunction (and/or)         NOTE: the validator limits what the operator can be, not the object         for future-proof-ness         and a list of sub-values
  [SearchTermOr <ITermConjunction>]: TermConjunction represents a conjunction (and/or)         NOTE: the validator limits what the operator can be, not the object         for future-proof-ness         and a list of sub-values
  [Sort <String>]: ASC or DESC order for timestamp
.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/Get-JcSdkEvent.md
#>
Function Get-JCEvent
{
    [OutputType([JumpCloud.SDK.DirectoryInsights.Models.IPost200ApplicationJsonItemsItem])]
    [CmdletBinding(DefaultParameterSetName='GetExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
    Param(
    [Parameter(ParameterSetName='GetExpanded', Mandatory)]
    [AllowEmptyCollection()]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String[]]
    # service name to query.
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
    [AllowEmptyCollection()]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String[]]
    # optional list of fields to return from query
    ${Fields},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String]
    # optional string for specifying a full text query
    ${Q},

    [Parameter(ParameterSetName='GetExpanded')]
    [AllowEmptyCollection()]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String[]]
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
    ${SearchTermNot},

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
        $Results = JumpCloud.SDK.DirectoryInsights\Get-JcSdkEvent @PSBoundParameters
    }
    End
    {
        Return $Results
    }
}
