---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCPolicyGroup

## SYNOPSIS

Returns all policy groups, policy groups by name or id.

## SYNTAX

### List (Default)
```
Get-JCPolicyGroup [-Fields <System.Collections.Generic.List`1[System.String]>]
 [-Filter <System.Collections.Generic.List`1[System.String]>]
 [-Sort <System.Collections.Generic.List`1[System.String]>]
 [<CommonParameters>]
```

### Get
```
Get-JCPolicyGroup -Id <String> [<CommonParameters>]
```

### GetViaIdentity
```
Get-JCPolicyGroup -InputObject <IJumpCloudApiIdentity>
 [<CommonParameters>]
```

## DESCRIPTION

Get-JCPolicyGroup will return all policy groups for a given organization by default. If either the 'name' or 'PolicyGroupId' parameters are specified, the function will attempt to find policy groups by name or id.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-JCPolicyGroup
```

Returns all JumpCloud policy groups

### Example 2

```powershell
PS C:\> Get-JCPolicyGroup -Name "PolicyGroupName"
```

Returns the policy group with name 'PolicyGroupName'

### Example 3

```powershell
PS C:\> Get-JCPolicyGroup -PolicyGroupId "66c3a774294f1e9071f080c9"
```

Returns the policy group with id '66c3a774294f1e9071f080c9'

## PARAMETERS

### -Fields
The comma separated fields included in the returned records.
If omitted, the default list of fields will be returned.

```yaml
Type: System.Collections.Generic.List`1[System.String]
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
A filter to apply to the query.

**Filter structure**: `<field>:<operator>:<value>`.

**field** = Populate with a valid field from an endpoint response.

**operator** = Supported operators are: eq, ne, gt, ge, lt, le, between, search, in.
_Note: v1 operators differ from v2 operators._

**value** = Populate with the value you want to search for.
Is case sensitive.
Supports wild cards.

**EX:** `GET /api/v2/groups?filter=name:eq:Test+Group`

```yaml
Type: System.Collections.Generic.List`1[System.String]
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
ObjectID of the Policy Group.

```yaml
Type: System.String
Parameter Sets: Get
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Identity Parameter

```yaml
Type: JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
Parameter Sets: GetViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Sort
The comma separated fields used to sort the collection.
Default sort is ascending, prefix with `-` to sort descending.

```yaml
Type: System.Collections.Generic.List`1[System.String]
Parameter Sets: List
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

### JumpCloud.SDK.V2.Models.IJumpCloudApiIdentity
## OUTPUTS

### JumpCloud.SDK.V2.Models.IPolicyGroup
## NOTES

## RELATED LINKS
