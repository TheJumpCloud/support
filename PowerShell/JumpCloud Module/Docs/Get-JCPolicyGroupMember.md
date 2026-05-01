---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCPolicyGroupMember

## SYNOPSIS

This function will return the policies that are members of the specified policy group.

## SYNTAX

### Get (Default)
```
Get-JCPolicyGroupMember -PolicyId <String> [-Filter <System.Collections.Generic.List`1[System.String]>]
 [-Sort <System.Collections.Generic.List`1[System.String]>] [-Authorization <String>] [-Date <String>]
 [<CommonParameters>]
```

### GetViaIdentity
```
Get-JCPolicyGroupMember -InputObject <IJumpCloudApiIdentity>
 [-Filter <System.Collections.Generic.List`1[System.String]>]
 [-Sort <System.Collections.Generic.List`1[System.String]>] [-Authorization <String>] [-Date <String>]
 [<CommonParameters>]
```

### List
```
Get-JCPolicyGroupMember -GroupId <String> [<CommonParameters>]
```

## DESCRIPTION

Get-JCPolicyGroupMember will return policies which are members of the specified policy group.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-JCPolicyGroupMember -PolicyGroupID 66c3a774294f1e9071f080c9
```

This will return all policies that are members of the policy group with id: '66c3a774294f1e9071f080c9'

### Example 2

```powershell
PS C:\> Get-JCPolicyGroupMember -Name "PolicyGroupName"
```

This will return all policies that are members of the policy group with name: 'PolicyGroupName'

## PARAMETERS

### -Authorization
Authorization header for the System Context API

```yaml
Type: System.String
Parameter Sets: Get, GetViaIdentity
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Date
Current date header for the System Context API

```yaml
Type: System.String
Parameter Sets: Get, GetViaIdentity
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
Parameter Sets: Get, GetViaIdentity
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupId
ObjectID of the Policy Group.

```yaml
Type: System.String
Parameter Sets: List
Aliases: id,, _id, PolicyGroupID

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

### -PolicyId
ObjectID of the Policy.

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

### -Sort
The comma separated fields used to sort the collection.
Default sort is ascending, prefix with `-` to sort descending.

```yaml
Type: System.Collections.Generic.List`1[System.String]
Parameter Sets: Get, GetViaIdentity
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

### JumpCloud.SDK.V2.Models.IGraphConnection
### JumpCloud.SDK.V2.Models.IGraphObjectWithPaths
## NOTES

## RELATED LINKS
