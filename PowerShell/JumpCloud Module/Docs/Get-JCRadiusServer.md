---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCRadiusServer
schema: 2.0.0
---

# Get-JCRadiusServer

## SYNOPSIS
Return JumpCloud radius server information.

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

### ByValue
```
Get-JCRadiusServer [-Force] [[-Fields] <Array>] [[-Filter] <String>] [[-Limit] <Int32>] [[-Skip] <Int32>]
 [[-Paginate] <Boolean>] [<CommonParameters>]
```

### ByName
```
Get-JCRadiusServer [-Force] [-Name] <String[]> [[-Fields] <Array>] [[-Filter] <String>] [[-Limit] <Int32>]
 [[-Skip] <Int32>] [[-Paginate] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
Use this function to return radius servers from JumpCloud tenet.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCRadiusServer
```

Returns all radius servers from a JumpCloud tenet.

### Example 2
```powershell
PS C:\> Get-JCRadiusServer -Id:('5d6802c46eb05c5971151558')
```

Returns a radius server by Id from a JumpCloud tenet.

### Example 3
```powershell
PS C:\> Get-JCRadiusServer -Name:('RadiusServer1')
```

Returns a radius server by Name from a JumpCloud tenet.

## PARAMETERS

### -Fields
An array of the fields/properties/columns you want to return from the search.

```yaml
Type: System.Array
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
Type: System.String
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
Type: System.Management.Automation.SwitchParameter
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
Type: System.String[]
Parameter Sets: ById
Aliases: _id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Limit
The number of items you want to return per API call.

```yaml
Type: System.Int32
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
Type: System.String[]
Parameter Sets: ByName
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Paginate
Whether or not you want to paginate through the results.

```yaml
Type: System.Boolean
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
Type: System.Int32
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
