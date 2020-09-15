---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCEventCount
schema: 2.0.0
---

# Get-JCEventCount

## SYNOPSIS
Query the API for a count of matching events

## SYNTAX

### GetExpanded (Default)
```
Get-JCEventCount -Service <String[]> -StartTime <DateTime> [-EndTime <DateTime>] [-Fields <String[]>]
 [-SearchAfter <String[]>] [-SearchTermAnd <Hashtable>] [-SearchTermOr <Hashtable>] [-Sort <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### Get
```
Get-JCEventCount -Body <IEventQuery> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Query the API for a count of matching events

## EXAMPLES

### EXAMPLE 1
```
Get-JCEventCount -Service:('all') -StartTime:((Get-date).AddDays(-30))
```

Pull all event records from a specified time and count the results

### EXAMPLE 2
```
Get-JCEventCount -Service:('sso') -StartTime:('2020-04-14T00:00:00Z')
```

Pull all SSO event records from a specified time and count the results

### EXAMPLE 3
```
Get-JCEventCount -Service:('all') -StartTime:('2020-04-14T00:00:00Z') -EndTime:('2020-04-20T23:00:00Z') -SearchTermAnd @{"event_type" = "admin_login_attempt"; "resource.email" = "admin.user@adminbizorg.com"}
```

Get all events counts between a date range and match event_type = admin_login_attempt and resource.email = admin.user@adminbizorg.com

### EXAMPLE 4
```
Get-JCEventCount -Service:('directory') -StartTime:((Get-date).AddDays(-30)) -searchTermAnd:@{"event_type" = "group_create"}
```

Get only group_create event counts the last thirty days

## PARAMETERS

### -Body
EventQuery is the users' command to search our auth logs
To construct, see NOTES section for BODY properties and create a hash table.

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
Type: System.DateTime
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
TermConjunction

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
TermConjunction

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

Required: True
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
Type: System.DateTime
Parameter Sets: GetExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IEventQuery
## OUTPUTS

### System.Int64
### System.String
## NOTES
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties.
For information on hash tables, run Get-Help about_Hash_Tables.

BODY \<IEventQuery\>: EventQuery is the users' command to search our auth logs
  Service \<String\[\]\>: service name to query.
Known services: systems,radius,sso,directory,ldap,all
  StartTime \<DateTime\>: query start time, UTC in RFC3339 format
  \[EndTime \<DateTime?\>\]: optional query end time, UTC in RFC3339 format
  \[Fields \<String\[\]\>\]: optional list of fields to return from query
  \[Limit \<Int64?\>\]: Max number of rows to return
  \[SearchAfter \<String\[\]\>\]: Specific query to search after, see x-* response headers for next values
  \[SearchTermAnd \<ITermConjunction\>\]: TermConjunction
    \[(Any) \<Object\>\]: This indicates any property can be added to this object.
  \[SearchTermOr \<ITermConjunction\>\]: TermConjunction
  \[Sort \<String\>\]: ASC or DESC order for timestamp

## RELATED LINKS

[https://github.com/TheJumpCloud/support/wiki/Get-JCEventCount](https://github.com/TheJumpCloud/support/wiki/Get-JCEventCount)

