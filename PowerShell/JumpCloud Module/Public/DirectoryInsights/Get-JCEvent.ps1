<#
.Synopsis
Query the API for Directory Insights events
.Description
Query the API for Directory Insights events
.Example
PS C:\> (Get-JCEvent -Service:('all') -StartTime:('2020-04-15T00:00:00Z') -EndTime:('2020-04-16T23:00:00Z')).ToJsonString()| ConvertFrom-Json

Pull all event records between Tue, 14 Apr 2020 18:00:00 -0600 to Thu, 16 Apr 2020 17:00:00 -0600
.Example
PS C:\> (Get-JCEvent -Service:('directory') -StartTime:('2020-04-15T00:00:00Z') -Limit:('10') -EndTime:('2020-04-16T23:00:00Z')).ToJsonString()| ConvertFrom-Json

Limit results to last 10 in the time range
.Example
PS C:\> ((Get-JCEvent -Service:('directory') -StartTime:('2020-04-15T00:00:00Z') -Sort:("DESC") -EndTime:('2020-04-16T23:00:00Z')).ToJsonString()| ConvertFrom-Json

Sort descending results against timestamp value

.Inputs
JumpCloud.SDK.DirectoryInsights.Models.IEventQuery
.Outputs
JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem
.Outputs
System.String
.Notes
COMPLEX PARAMETER PROPERTIES
To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

EVENTQUERYBODY <IEventQuery>: EventQuery is the users' command to search our auth logs
  [EndTime <String>]: optional query end time, UTC in RFC3339 format
  [Fields <String[]>]: optional list of fields to return from query
  [Limit <Int64?>]: Max number of rows to return
  [SearchAfter <String[]>]: Specific query to search after, see x-* response headers for next values
  [SearchTermAnd <ISearchTermAnd>]: 
    [(Any) <Object>]: This indicates any property can be added to this object.
  [SearchTermOr <ISearchTermOr>]: 
    [(Any) <Object>]: This indicates any property can be added to this object.
  [Service <String[]>]: service name to query. Known services: "active_directory","application","command","g_suite","ldap_server","office_365","policy","radius_server","system","system_group","user","user_group"
  [Sort <String>]: ASC or DESC order for timestamp
  [StartTime <String>]: query start time, UTC in RFC3339 format
#>
Function Get-JCEvent
{
    #Requires -modules JumpCloud.SDK.DirectoryInsights
    [OutputType([JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem], [System.String])]
    [CmdletBinding(DefaultParameterSetName='GetExpanded', PositionalBinding=$false)]
    Param(
    [Parameter(ParameterSetName='Get', Mandatory, ValueFromPipeline)]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [JumpCloud.SDK.DirectoryInsights.Models.IEventQuery]
    # EventQuery is the users' command to search our auth logs
    # To construct, see NOTES section for EVENTQUERYBODY properties and create a hash table.
    ${EventQueryBody},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String]
    # optional query end time, UTC in RFC3339 format
    ${EndTime},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String[]]
    # optional list of fields to return from query
    ${Fields},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.Int64]
    # Max number of rows to return
    ${Limit},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String[]]
    # Specific query to search after, see x-* response headers for next values
    ${SearchAfter},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [JumpCloud.SDK.DirectoryInsights.Runtime.Info(PossibleTypes=([JumpCloud.SDK.DirectoryInsights.Models.ISearchTermAnd]))]
    [System.Collections.Hashtable]
    # .
    ${SearchTermAnd},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [JumpCloud.SDK.DirectoryInsights.Runtime.Info(PossibleTypes=([JumpCloud.SDK.DirectoryInsights.Models.ISearchTermOr]))]
    [System.Collections.Hashtable]
    # .
    ${SearchTermOr},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String[]]
    # service name to query.
    # Known services: "active_directory","application","command","g_suite","ldap_server","office_365","policy","radius_server","system","system_group","user","user_group"
    ${Service},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String]
    # ASC or DESC order for timestamp
    ${Sort},

    [Parameter(ParameterSetName='GetExpanded')]
    [JumpCloud.SDK.DirectoryInsights.Category('Body')]
    [System.String]
    # query start time, UTC in RFC3339 format
    ${StartTime},

    [System.Boolean]
    # Set to $true to return all results.
    $Paginate = $true
    )
    Begin
    {
        Connect-JCOnline -force | Out-Null
        $Results = @()
        $PSBoundParameters.Add('HttpPipelineAppend', {
                param($req, $callback, $next)
                # call the next step in the Pipeline
                $ResponseTask = $next.SendAsync($req, $callback)
                $global:JCHttpRequest = $req
                $global:JCHttpRequestContent = $req.Content.ReadAsStringAsync()
                $global:JCHttpResponse = $ResponseTask
                Return $ResponseTask
            }
        )
    }
    Process
    {
        If ($Paginate)
        {
            $PSBoundParameters.Remove('Paginate') | Out-Null
            Do
            {
                $Result = Get-JcSdkEvent @PSBoundParameters
                If (-not [System.String]::IsNullOrEmpty($Result))
                {
                    $XResultSearchAfter = ($JCHttpResponse.Result.Headers.GetValues('X-Search_after') | ConvertFrom-Json);
                    If ([System.String]::IsNullOrEmpty($PSBoundParameters.SearchAfter))
                    {
                        $PSBoundParameters.Add('SearchAfter', $XResultSearchAfter)
                    }
                    Else
                    {
                        $PSBoundParameters.SearchAfter = $XResultSearchAfter
                    }
                    $XResultCount = $JCHttpResponse.Result.Headers.GetValues('X-Result-Count')
                    $XLimit = $JCHttpResponse.Result.Headers.GetValues('X-Limit')
                    $Results += ($Result).ToJsonString() | ConvertFrom-Json;
                }
                Write-Debug ("ResultCount: $($XResultCount); Limit: $($XLimit); XResultSearchAfter: $($XResultSearchAfter); ");
                Write-Debug ('HttpRequest: ' + $JCHttpRequest);
                Write-Debug ('HttpRequestContent: ' + $JCHttpRequestContent.Result);
            }
            While ($XResultCount -eq $XLimit -and $Result)
        }
        Else
        {
            $PSBoundParameters.Remove('Paginate') | Out-Null
            $Result = Get-JcSdkEvent @PSBoundParameters
            Write-Debug ('HttpRequest: ' + $JCHttpRequest);
            Write-Debug ('HttpRequestContent: ' + $JCHttpRequestContent.Result);
            If (-not [System.String]::IsNullOrEmpty($Result))
            {
                $Results += ($Result).ToJsonString() | ConvertFrom-Json;
            }
        }
    }
    End
    {
        # Clean up global variables
        $GlobalVars = @('JCHttpRequest', 'JCHttpRequestContent', 'JCHttpResponse')
        $GlobalVars | ForEach-Object {
            If ((Get-Variable -Scope:('Global')).Where( { $_.Name -eq $_ })) { Remove-Variable -Name:($_) -Scope:('Global') }
        }
        Return $Results
    }
}
