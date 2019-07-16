---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Add-JCAssociation
schema: 2.0.0
---

# Add-JCAssociation

## SYNOPSIS
Create an association between two object within the JumpCloud console.

## SYNTAX

### ById (Default)
```
Add-JCAssociation [-Type] <String> [-Force] [-Fields <Array>] [-Filter <String>] [-Id] <String[]>
 [-Limit <Int32>] [-Paginate <Boolean>] [-Skip <Int32>] [[-Attributes] <PSObject>] [[-TargetId] <String>]
 [[-TargetName] <String>] [[-TargetType] <String[]>] [<CommonParameters>]
```

### ByName
```
Add-JCAssociation [-Type] <String> [-Force] [-Fields <Array>] [-Filter <String>] [-Limit <Int32>]
 [-Name] <String[]> [-Paginate <Boolean>] [-Skip <Int32>] [[-Attributes] <PSObject>] [[-TargetId] <String>]
 [[-TargetName] <String>] [[-TargetType] <String[]>] [<CommonParameters>]
```

### ByValue
```
Add-JCAssociation [-Type] <String> [-Force] [-Fields <Array>] [-Filter <String>] [-Limit <Int32>]
 [-Paginate <Boolean>] [-Skip <Int32>] [[-Attributes] <PSObject>] [[-TargetId] <String>]
 [[-TargetName] <String>] [[-TargetType] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
The Add-JCAssociation function allows you to create associations of a specific object to a target object.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-JCAssociation -Type:('radiusservers') -Id:('5c5c371704c4b477964ab4fa') -TargetType:('user_group') -TargetId:('59f20255c9118021fa01b80f')
```

Create an association between the radius server "5c5c371704c4b477964ab4fa" and the user group "59f20255c9118021fa01b80f".

### Example 2
```powershell
PS C:\> Add-JCAssociation -Type:('radiusservers') -Name:('RadiusServer1') -TargetType:('user_group') -TargetName:('All Users')
```

Create an association between the radius server "RadiusServer1" and the user group "All Users".

## PARAMETERS

### -Attributes
Add attributes that define the association such as if they are an admin.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: compiledAttributes

Required: False
Position: 15
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Force
Bypass user confirmation and ValidateSet when adding or removing associations.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the object.

```yaml
Type: String[]
Parameter Sets: ByName
Aliases: displayName, username

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetId
The unique id of the target object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetName
The name of the target object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetType
The type of the target object.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: TargetSingular
Accepted values: user, user_group, system, system_group, policy, command, application, g_suite, ldap_server, office_365, radius_server

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of the object.

```yaml
Type: String
Parameter Sets: (All)
Aliases: TypeNameSingular
Accepted values: command, ldap_server, policy, application, radius_server, system_group, system, user_group, user, g_suite, office_365

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

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

### -Limit
The number of items you want to return per API call.

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

### -Skip
Ignores the specified number of objects and then gets the remaining objects. Enter the number of objects to skip.

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

### -Paginate
Whether or not you want to paginate through the results.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
### System.Management.Automation.PSObject
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
