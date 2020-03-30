---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCAssociation
schema: 2.0.0
---

# Get-JCAssociation

## SYNOPSIS
The function Get-JCAssociation can be used to query an object's associations and then provide information about how objects are associated with one another.

## SYNTAX

### ById (Default)
```
Get-JCAssociation [-Type] <String> [-Force] [-Id] <String[]> [[-Fields] <Array>] [[-Filter] <String>]
 [[-Limit] <Int32>] [[-Skip] <Int32>] [[-Paginate] <Boolean>] [[-TargetType] <String[]>] [-Direct] [-Indirect]
 [-IncludeInfo] [-IncludeNames] [-IncludeVisualPath] [<CommonParameters>]
```

### ByName
```
Get-JCAssociation [-Type] <String> [-Force] [-Name] <String[]> [[-Fields] <Array>] [[-Filter] <String>]
 [[-Limit] <Int32>] [[-Skip] <Int32>] [[-Paginate] <Boolean>] [[-TargetType] <String[]>] [-Direct] [-Indirect]
 [-IncludeInfo] [-IncludeNames] [-IncludeVisualPath] [<CommonParameters>]
```

### ByValue
```
Get-JCAssociation [-Type] <String> [-Force] [[-Fields] <Array>] [[-Filter] <String>] [[-Limit] <Int32>]
 [[-Skip] <Int32>] [[-Paginate] <Boolean>] [[-TargetType] <String[]>] [-Direct] [-Indirect] [-IncludeInfo]
 [-IncludeNames] [-IncludeVisualPath] [<CommonParameters>]
```

### Default
```
Get-JCAssociation [-Type] <String> [-Force] [[-Fields] <Array>] [[-Filter] <String>] [[-Limit] <Int32>]
 [[-Skip] <Int32>] [[-Paginate] <Boolean>] [[-TargetType] <String[]>] [-Direct] [-Indirect] [-IncludeInfo]
 [-IncludeNames] [-IncludeVisualPath] [<CommonParameters>]
```

## DESCRIPTION
The Get-JCAssociation function allows you to view the associations of a specific object to a target object.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCAssociation -Type:user_group -Name:employee -TargetType:users
```

List all "users" that are associated with the user_group "employee".

### Example 2
```powershell
PS C:\> Get-JCAssociation -Type:system -Id:5c9a95f84tdo1376318g5148
```

List all associations with the system "5c9a95f84tdo1376318g5148".

### Example 3
```powershell
PS C:\> Get-JCAssociation -Type:system  -Id:5c9a95f84tdo1376318g5148 -TargetType:users -Direct
```

List all "users" that have a direct association with the system "5c9a95f84tdo1376318g5148".

### Example 4
```powershell
PS C:\> Get-JCAssociation -Type:system  -Id:5c9a95f84tdo1376318g5148 -TargetType:users -Indirect
```

List all "users" that have a indirect association with the system "5c9a95f84tdo1376318g5148".

### Example 5
```powershell
PS C:\> Get-JCAssociation -Type:system  -Id:5c9a95f84tdo1376318g5148 -TargetType:users -IncludeInfo -IncludeNames -IncludeVisualPath
```

List all "users" that are associated with the system "5c9a95f84tdo1376318g5148" and also get additional metadata about each object.

## PARAMETERS

### -Direct
Returns only "Direct" associations.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

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

### -IncludeInfo
Appends "Info" and "TargetInfo" properties to output.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IncludeNames
Appends "Name" and "TargetName" properties to output.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IncludeVisualPath
Appends "visualPathById", "visualPathByName", and "visualPathByType" properties to output.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Indirect
Returns only "Indirect" associations.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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
Aliases: domain, displayName, username

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
Accepted values: True, False

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

### -TargetType
The type of the target object.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases: TargetSingular
Accepted values: user, user_group, system, system_group, policy, command, application, g_suite, ldap_server, office_365, radius_server

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of the object.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: TypeNameSingular
Accepted values: command, ldap_server, policy, application, radius_server, system_group, system, user_group, user, g_suite, office_365

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Management.Automation.SwitchParameter

### System.String[]

### System.Array

### System.Int32

### System.Boolean

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
