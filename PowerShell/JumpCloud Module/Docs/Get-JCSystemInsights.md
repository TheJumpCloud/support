---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCSystemInsights
schema: 2.0.0
---

# Get-JCSystemInsights

## SYNOPSIS
JumpCloud's System Insights feature provides admins with the ability to easily interrogate their
fleet of systems to find important pieces of information. Using this function you
can easily gather heightened levels of information from your fleet of JumpCloud managed
systems.

## SYNTAX

```
Get-JCSystemInsights -Table <String> [-SystemId <String>] [[-Filter] <String>] [-Sort <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Using Get-JCSystemInsights will allow you to easily query JumpCloud's RESTful API to return information from your fleet of JumpCloud managed
systems.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCSystemInsights -Table:('os_version');
```

Return os_version data for all systems that have system insights enabled.

### Example 2
```powershell
PS C:\> Get-JCSystemInsights -Table:('os_version') -Id:('5d0917420905f70e36e3c0d3');
```

Return os_version data for a system with a specified id.

### Example 3
```powershell
PS C:\> Get-JCSystemInsights -Table:('os_version') -Id:('5d0917420905f70e36e3c0d3', '5d0bc68b8e41442ccd10254a');
```

Return os_version data for systems with specific ids.

### Example 4
```powershell
PS C:\> Get-JCSystemInsights -Table:('os_version') -Name:('MacBook-Pro.local_TEST');
```

Return os_version data for a system with a specified name.

### Example 5
```powershell
PS C:\> Get-JCSystemInsights -Table:('os_version') -Name:('MacBook-Pro.local_TEST', 'Holly-Flax-Mac.local_TEST');
```

Return os_version data for systems with specific names.

### Example 6
```powershell
PS C:\> Get-JCSystemInsights -Table users -Filter username:eq:jcadmin
```

Filters the users table for any system with the username jcadmin.

## PARAMETERS

### -Filter
Filters to narrow down search.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 96
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Table
The SystemInsights table to query against.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: battery, managed_policies, sip_config, alf, crashes, usb_devices, ie_extensions, launchd, shared_folders, shared_resources, user_ssh_keys, logged_in_users, shadow, sharing_preferences, user_groups, kernel_info, system_controls, uptime, etc_hosts, logical_drives, disk_info, bitlocker_info, patches, programs, apps, browser_plugins, chrome_extensions, disk_encryption, firefox_addons, groups, interface_addresses, mounts, os_version, safari_extensions, system_info, users, certificates, cups_destinations, interface_details, python_packages, registry, scheduled_tasks, services, startup_items, authorized_keys, appcompat_shims, dns_resolvers, wifi_networks, wifi_status, connectivity, windows_security_products, alf_exceptions, alf_explicit_auths

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
{{ Fill Sort Description }}

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemId
{{ Fill SystemId Description }}

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: _id, id, system_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.String[]
### System.Array
### System.Int32
### System.Boolean
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
