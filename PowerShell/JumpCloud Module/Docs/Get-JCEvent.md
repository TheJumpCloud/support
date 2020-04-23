---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCEvent
schema: 2.0.0
---

# Get-JCEvent

## SYNOPSIS
Query the API for Directory Insights events

## SYNTAX

### GetExpanded (Default)
```
Get-JCEvent [-EndTime <String>] [-Fields <String[]>] [-Limit <Int64>] [-SearchAfter <String[]>]
 [-SearchTermAnd <Hashtable>] [-SearchTermOr <Hashtable>] [-Service <String[]>] [-Sort <String>]
 [-StartTime <String>] [-Paginate <Boolean>] [<CommonParameters>]
```

### Get
```
Get-JCEvent -EventQueryBody <IEventQuery> [-Paginate <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
Query the API for Directory Insights events

## EXAMPLES

### EXAMPLE 1
```
(Get-JCEvent -Service:('all') -StartTime:('2020-04-15T00:00:00Z') -EndTime:('2020-04-16T23:00:00Z'))
```

Pull all event records between Tue, 14 Apr 2020 18:00:00 -0600 to Thu, 16 Apr 2020 17:00:00 -0600

### EXAMPLE 2
```
(Get-JCEvent -Service:('directory') -StartTime:('2020-04-15T00:00:00Z') -Limit:('10') -EndTime:('2020-04-16T23:00:00Z'))
```

Limit directory results to last 10 in the time range

### EXAMPLE 3
```
(Get-JCEvent -Service:('directory') -StartTime:('2020-04-15T00:00:00Z') -Sort:("DESC") -EndTime:('2020-04-16T23:00:00Z'))
```

Sort directory descending results against timestamp value

### EXAMPLE 4
```
(Get-JCEvent -Service:('directory') -StartTime:('2020-04-15T00:00:00Z') -Limit:('10') -EndTime:('2020-04-16T23:00:00Z') -searchTermAnd:@{"event_type" = "group_create"})
```

Get only group_create events during a time range

### EXAMPLE 5
```
(Get-JCEvent -Service:('all') -StartTime:('2020-04-14T00:00:00Z') -EndTime:('2020-04-20T23:00:00Z') -SearchTermOr @{"initiated_by.username" = @("user.1", "user.2")})
```

Get login events initiated by either "user.1" or "user.2"

### EXAMPLE 6
```
(Get-JCEvent -Service:('all') -StartTime:('2020-04-14T00:00:00Z') -EndTime:('2020-04-20T23:00:00Z') -SearchTermAnd @{"event_type" = "admin_login_attempt"; "resource.email" = "admin.user@adminbizorg.com"})
```

Get all events between a date range and match event_type = admin_login_attempt and resource.email = admin.user@adminbizorg.com

### EXAMPLE 7
```
(Get-JCEvent -Service:('sso') -StartTime:('2020-04-14T00:00:00Z')  -EndTime:('2020-04-20T23:00:00Z') -SearchTermAnd @{"initiated_by.username" = "user.1"})
```

Get sso events with the search term initated_by: username with value "user.1"

### EXAMPLE 8
```
(Get-JCEvent -Service:('all') -StartTime:('2020-04-14T00:00:00Z') -EndTime:('2020-04-20T23:00:00Z') -SearchTermAnd @{"event_type" = "organization_update"})
```

Get all events filtered by organization_update term between a date range

## PARAMETERS

### -EventQueryBody
EventQuery is the users' command to search our auth logs
To construct, see NOTES section for EVENTQUERYBODY properties and create a hash table.

```yaml
Type: JumpCloud.SDK.DirectoryInsights.Models.IEventQuery
Parameter Sets: Get
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -EndTime
optional query end time, UTC in RFC3339 format

```yaml
Type: System.String
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Fields
optional list of fields to return from query

```yaml
Type: System.String[]
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Max number of rows to return

```yaml
Type: System.Int64
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchAfter
Specific query to search after, see x-* response headers for next values

```yaml
Type: System.String[]
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchTermAnd
list of event terms.
If all terms match the event will be returned by the service.

```yaml
Type: System.Collections.Hashtable
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchTermOr
list of event terms.
If any term matches, the event will be returned by the service.

```yaml
Type: System.Collections.Hashtable
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Service
service name to query.
Known services: systems,radius,sso,directory,ldap,all

```yaml
Type: System.String[]
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
ASC or DESC order for timestamp

```yaml
Type: System.String
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime
query start time, UTC in RFC3339 format

```yaml
Type: System.String
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Paginate
Set to $true to return all results.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IEventQuery
## OUTPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem
### System.String
## NOTES
COMPLEX PARAMETER PROPERTIES
To create the parameters described below, construct a hash table containing the appropriate properties.
For information on hash tables, run Get-Help about_Hash_Tables.

EVENTQUERYBODY \<IEventQuery\>: EventQuery is the users' command to search our auth logs
  \[EndTime \<String\>\]: optional query end time, UTC in RFC3339 format
  \[Fields \<String\[\]\>\]: optional list of fields to return from query
  \[Limit \<Int64?\>\]: Max number of rows to return
  \[SearchAfter \<String\[\]\>\]: Specific query to search after, see x-* response headers for next values
  \[SearchTermAnd \<ISearchTermAnd\>\]: list of event terms.
If all terms match the event will be returned by the service.
    \[(Any) \<Object\>\]: This indicates any property can be added to this object.
  \[SearchTermOr \<ISearchTermOr\>\]: list of event terms.
If any term matches, the event will be returned by the service.
    \[(Any) \<Object\>\]: This indicates any property can be added to this object.
  \[Service \<String\[\]\>\]: service name to query.
Known services: systems,radius,sso,directory,ldap,all
  \[Sort \<String\>\]: ASC or DESC order for timestamp
  \[StartTime \<String\>\]: query start time, UTC in RFC3339 format

## RELATED LINKS
