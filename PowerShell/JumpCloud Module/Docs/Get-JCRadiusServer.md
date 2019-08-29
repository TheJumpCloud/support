---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCRadiusServer
schema: 2.0.0
---

# Get-JCRadiusServer

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Default (Default)
```
Get-JCRadiusServer [-Force] [[-Fields] <Array>] [[-Filter] <String>] [[-Limit] <Int32>] [[-Skip] <Int32>]
 [[-Paginate] <Boolean>] [<CommonParameters>]
```

### ById
```
Get-JCRadiusServer [-Force] [-Id] <String[]> [[-Fields] <Array>] [[-Filter] <String>] [[-Limit] <Int32>]
 [[-Skip] <Int32>] [[-Paginate] <Boolean>] [<CommonParameters>]
```

### ByName
```
Get-JCRadiusServer [-Force] [-Name] <String[]> [[-Fields] <Array>] [[-Filter] <String>] [[-Limit] <Int32>]
 [[-Skip] <Int32>] [[-Paginate] <Boolean>] [<CommonParameters>]
```

### ByValue
```
Get-JCRadiusServer [-Force] [[-Fields] <Array>] [[-Filter] <String>] [[-Limit] <Int32>] [[-Skip] <Int32>]
 [[-Paginate] <Boolean>] [<CommonParameters>]
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

### -Fields
An array of the fields/properties/columns you want to return from the search.

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 95
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
Position: 96
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Force
Bypass user prompts and dynamic ValidateSet.

```yaml
Type: SwitchParameter
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
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Limit
The number of items you want to return per API call.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 97
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the object.

```yaml
Type: String[]
Parameter Sets: ByName
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Paginate
Whether or not you want to paginate through the results.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 99
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Skip
The number of items you want to skip over per API call.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 98
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Management.Automation.SwitchParameter

### System.String[]

### System.String

### System.Array

### System.Int32

### System.Boolean

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
