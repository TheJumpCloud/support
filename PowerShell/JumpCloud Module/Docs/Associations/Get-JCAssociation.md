---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# Get-JCAssociation

## SYNOPSIS
Lists the associations of a specific object and a specific type of object within JumpCloud.

## SYNTAX

### Default (Default)
```
Get-JCAssociation [-InputObjectType] <String> [-TargetObjectType] <String> [<CommonParameters>]
```

### ById
```
Get-JCAssociation [-InputObjectType] <String> [-InputObjectName] <String> [-TargetObjectType] <String>
 [<CommonParameters>]
```

### ByName
```
Get-JCAssociation [-InputObjectType] <String> [-InputObjectName] <String> [-TargetObjectType] <String>
 [<CommonParameters>]
```

## DESCRIPTION
The Get-JCAssociation function allows you to view the associations of a specific object to a target object. The following table shows the possible "InputObjectType" and its valid "TargetObjectType" options.

    activedirectories = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group, user, user_group
    applications = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group, user, user_group
    commands = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group, user, user_group
    gsuites = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group, user, user_group
    ldapservers = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group, user, user_group
    office365s = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group, user, user_group
    policies = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group, user, user_group
    radiusservers = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group, user, user_group
    systemgroups = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, user, user_group
    systems = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, user, user_group
    usergroups = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group
    users = active_directory, application, command, g_suite, ldap_server, office_365, policy, radius_server, system, system_group


## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCAssociation -InputObjectType:('users') -InputObjectName:('Luke Skywalker') -TargetObjectType:('system') | Format-Table
```

List all "systems" that are associated with the user "Luke Skywalker".

### Example 2
```powershell
PS C:\> Get-JCAssociation -InputObjectType:('users') -InputObjectId:('5ab915cf861178491b8fc399') -TargetObjectType:('system') | Format-Table
```

List all "systems" that are associated with the userId "5ab915cf861178491b8fc399".


## PARAMETERS

### -InputObjectId
The id of the input object.

```yaml
Type: String
Parameter Sets: ById
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputObjectName
The name of the input object.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputObjectType
The type of the input object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetObjectType
The type of the target object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
