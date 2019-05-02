---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCAssociation
schema: 2.0.0
---

# Get-JCAssociation

## SYNOPSIS
Lists the associations of a specific object and a specific type of object within JumpCloud.

## SYNTAX

### ById (Default)
```
Get-JCAssociation [-Type] <String> [-Id] <String> [-TargetType] <String>
 [-HideTargetData] [<CommonParameters>]
```

### ByName
```
Get-JCAssociation [-Type] <String> [-Name] <String> [-TargetType] <String>
 [-HideTargetData] [<CommonParameters>]
```

## DESCRIPTION
The Get-JCAssociation function allows you to view the associations of a specific object to a target object.

## EXAMPLES

### Example 1
```
PS C:\> Get-JCAssociation -Type:('users') -Name:('Luke Skywalker') -TargetType:('system') | Format-Table
```

List all "systems" that are associated with the user "Luke Skywalker".

### Example 2
```
PS C:\> Get-JCAssociation -Type:('users') -Id:('5ab915cf861178491b8fc399') -TargetType:('system') | Format-Table
```

List all "systems" that are associated with the userId "5ab915cf861178491b8fc399".

## PARAMETERS

### -HideTargetData
Providing this parameter will suppress the target objects information from the result.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

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
Accepted values: active_directory, command, ldap_server, policy, application, radius_server, system_group, system, user_group, user, g_suite, office_365

Required: True
Position: 0
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
Accepted values: user, user_group, user_group, system, system_group, user, user_group, user, user_group, user, user_group, system, system_group, user_group, policy, user_group, command, system, policy, user, command, system_group, active_directory, application, g_suite, ldap_server, office_365, radius_server, system_group, user, active_directory, g_suite, ldap_server, office_365, system, user_group

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
### System.Management.Automation.SwitchParameter
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
