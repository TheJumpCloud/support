---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCEvent
schema: 2.0.0
---

# Get-JCEvent

## SYNOPSIS
{{ Fill in the Synopsis }}

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
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -EndTime
{{ Fill EndTime Description }}

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

### -EventQueryBody
{{ Fill EventQueryBody Description }}

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

### -Fields
{{ Fill Fields Description }}

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
{{ Fill Limit Description }}

```yaml
Type: System.Int64
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Paginate
{{ Fill Paginate Description }}

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchAfter
{{ Fill SearchAfter Description }}

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
{{ Fill SearchTermAnd Description }}

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
{{ Fill SearchTermOr Description }}

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
{{ Fill Service Description }}

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
{{ Fill Sort Description }}

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
{{ Fill StartTime Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IEventQuery

## OUTPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem

### System.String

## NOTES

## RELATED LINKS
