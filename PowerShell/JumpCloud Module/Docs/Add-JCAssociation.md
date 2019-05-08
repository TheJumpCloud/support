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
Add-JCAssociation [-Type] <String> [-Id] <String> [-TargetType] <String>
 [-TargetId] <String> [<CommonParameters>]
```

### ByName
```
Add-JCAssociation [-Type] <String> [-Name] <String> [-TargetType] <String>
 [-TargetName] <String> [<CommonParameters>]
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

### -Id
The id of the input object.

```yaml
Type: String
Parameter Sets: ById
Aliases: id, _id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the input object.

```yaml
Type: String
Parameter Sets: ByName
Aliases: name, username, groupName

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of the input object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: command, ldap_server, policy, application, radius_server, system_group, system, user_group, user, g_suite, office_365

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetId
The id of the target object.

```yaml
Type: String
Parameter Sets: ById
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetName
The name of the target object.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetType
The type of the target object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: user, user_group, user_group, system, system_group, user, user_group, user, user_group, user, user_group, system, system_group, user_group, policy, user_group, command, system, policy, user, command, system_group, application, g_suite, ldap_server, office_365, radius_server, system_group, user, g_suite, ldap_server, office_365, system, user_group

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
