# Get-JCSystemInsights

## SYNOPSIS
JumpCloud's System Insights feature provides admins with the ability to easily interrogate their fleet of systems to find important pieces of information.
Using this function you can easily gather heightened levels of information from your fleet of JumpCloud managed systems.

## SYNTAX

```
Get-JCSystemInsights -Table <String> [-SystemId <String[]>] [-Filter <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Using Get-JCSystemInsights will allow you to easily query JumpCloud's RESTful API to return information from your fleet of JumpCloud managed systems.

## EXAMPLES

### Example 1
```
PS C:\> Get-JCSystemInsights -Table:('App');
```

Get all Apps from systems with system insights enabled.

### Example 2
```
PS C:\> Get-JCSystemInsights -Table:('App') -SystemId:('5d66e0ac51db1e789bb17c77', '5e0e19831bc893319ae068b6');
```

Get all Apps from the specific systems.

### Example 3
```
PS C:\> Get-JCSystemInsights -Table:('App') -Filter:('system_id:eq:5d66e0ac51db1e789bb17c77', 'bundle_name:eq:storeuid');
```

Get systems that have a specific App on a specific system where the filter is multiple strings.

### Example 4
```
PS C:\> Get-JCSystemInsights -Table:('App') -Filter:('system_id:eq:5d66e0ac51db1e789bb17c77, bundle_name:eq:storeuid');
```

Get systems that have a specific App on a specific system where the filter is a string.

## PARAMETERS

### -Filter
Filters to narrow down search.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemId
A comma separated list of System IDs to query against.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases: _id, id, system_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Table
Name of the SystemInsights Table to query. See docs.jumpcloud.com for list of available Table endpoints.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[Online Version:](https://github.com/TheJumpCloud/support/wiki/Get-JCSystemInsights)

