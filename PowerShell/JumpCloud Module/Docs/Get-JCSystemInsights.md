---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCSystemInsights
schema: 2.0.0
---

# Get-JCSystemInsights

## SYNOPSIS
JumpCloud’s System Insights feature provides admins with the ability to easily interrogate their
fleet of systems to find important pieces of information. Using this function you
can easily gather heightened levels of information from your fleet of JumpCloud managed
systems.

## SYNTAX

### Default
```
Get-JCSystemInsights -Table <String> [-Fields <Array>] [-Filter <String>] [-Limit <Int32>] [-Skip <Int32>]
 [<CommonParameters>]
```

### ById
```
Get-JCSystemInsights -Table <String> [-Fields <Array>] [-Filter <String>] -Id <String[]> [-Limit <Int32>]
 [-Skip <Int32>] [<CommonParameters>]
```

### ByName
```
Get-JCSystemInsights -Table <String> [-Fields <Array>] [-Filter <String>] [-Limit <Int32>] -Name <String[]>
 [-Skip <Int32>] [<CommonParameters>]
```

### ByValue
```
Get-JCSystemInsights [-Fields <Array>] [-Filter <String>] [-Limit <Int32>] -SearchBy <String>
 -SearchByValue <String[]> [-Skip <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Using Get-JCSystemInsights will allow you to easily query JumpCloud’s RESTful API to return information from your fleet of JumpCloud managed
systems.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Fields
An array of the fields/properties/columns you want to return from the search.

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Filter
Filters to narrow down search.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Id
The unique id of the object.

```yaml
Type: String[]
Parameter Sets: ById
Aliases: _id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Limit
{{ Fill Limit Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the object.

```yaml
Type: String[]
Parameter Sets: ByName
Aliases: displayName

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SearchBy
Specify how you want to search.

```yaml
Type: String
Parameter Sets: ByValue
Aliases:
Accepted values: ById, ByName

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SearchByValue
Specify the item which you want to search for.
Supports wildcard searches using: *

```yaml
Type: String[]
Parameter Sets: ByValue
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Skip
Ignores the specified number of objects and then gets the remaining objects.
Enter the number of objects to skip.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Table
The SystemInsights table to query against.

```yaml
Type: String
Parameter Sets: Default, ById, ByName
Aliases:
Accepted values: apps, browser_plugins, chrome_extensions, disk_encryption, firefox_addons, groups, interface_addresses, mounts, os_version, safari_extensions, system_info, users

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Array

### System.String[]

### System.Int32

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
