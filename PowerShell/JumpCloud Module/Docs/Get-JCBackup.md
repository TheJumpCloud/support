---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCBackup
schema: 2.0.0
---

# Get-JCBackup

## SYNOPSIS
Backs up JumpCloud directory information to CSV

## SYNTAX

```
Get-JCBackup [-All] [-Users] [-SystemUsers] [-Systems] [-UserGroups] [-SystemGroups] [<CommonParameters>]
```

## DESCRIPTION
The Get-JCBackup command saves JumpCloud directory information to CSV files.
This command can be used to backup user, system user, system, user group, and system group information to CSV files.
Specific items can be selected for CSV backup using the command or the '-All' switch parameter can be specified which will backup all items.
How JCBackup works JumpCloud user information can be queried using the JumpCloud PowerShell module command Get-JCUser (https://github.com/TheJumpCloud/support/wiki/Get-JCUser)This command will by default return all JumpCloud user properties.

To export only the JumpCloud user information presented within the JumpCloud admin console ("First Name", "Last Name", "Username" and "Email") use the '-returnProperties' parameter of the Get-JCUser command as shown below.
Note JumpCloud unique IDs (_id) are always returned when using the Get-JCUser command.

Get-JCUser -returnProperties firstname, lastname, username, email | Export-CSV -Path "JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation

This command will export all JumpCloud users first name, last name, username, id, and email to a CSV file named JumpCloudUsers_CurrentDate.CSV created within the directory where the command is run.

If enforcing UID/GID consistency and you wish to export this information run the following command:

Get-JCUser -returnProperties firstname, lastname, username, email, unix_uid, unix_guid | Export-CSV -Path "JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation

This command will export all JumpCloud users first name, last name, username, id, email, unix_guid, and unix_uid to a CSV file named JumpCloudUsers_CurrentDate.CSV created within the directory where the command is run.

To export all information describing JumpCloud users to CSV some additional object expansion must be done.

The properties "attributes", "addresses", "phonenumbers" and "ssh_keys" of JumpCloud users are returned as nested objects via the JumpCloud PowerShell module.

This means that if the objects are not expanded before exporting to CSV they will simply display as a 'System.Object\[\]' in the output CSV file.

To account for this find the below example which expands each nested object using PowerShell calculated properties and converts the objects to the JSON format.
Note the backtick '\`' escape character is used to break this command into multiple lines for readability.

```
Get-JCUser | Select-Object * , \`
  @{Name = 'attributes'; Expression = {$_.attributes | ConvertTo-Json}}, \`
  @{Name = 'addresses'; Expression = {$_.addresses | ConvertTo-Json}}, \`
  @{Name = 'phonenumbers'; Expression = {$_.phonenumbers | ConvertTo-Json}}, \`
  @{Name = 'ssh_keys'; Expression = {$_.ssh_keys | ConvertTo-Json}} \`
  -ExcludeProperty attributes, addresses, phonenumbers, ssh_keys | Export-CSV -Path "JumpCloudUsers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation
```

This command will gather and format all JumpCloud user information and export it to a CSV file named JumpCloudUsers_CurrentDate.CSV created within the directory where the command is run.
If you wish to exclude certain user properties you can append the '-ExcludeProperty' list with the properties you wish to exclude.
Backing up JumpCloud System User Information JumpCloud system user associations can be queried using the JumpCloud PowerShell module command Get-JCSystemUser (https://github.com/TheJumpCloud/support/wiki/Get-JCUser)The Get-JCSystemUser command will show all JumpCloud users associated with a specific JumpCloud System using the JumpCloud System ID.

To export all JumpCloud system user information to CSV use the following example.

The property "BindGroups" is returned as a nested object via the JumpCloud PowerShell module.

This means that if the object is expanded before exporting to CSV it will simply display as a 'System.Object\[\]' in the output CSV file.

To account for this the "BindGroups" property is expanded using a PowerShell calculated property.

```
Get-JCSystem | Get-JCSystemUser | Select-Object -Property * , @{Name = 'BindGroups'; Expression = {$ .BindGroups | ConvertTo-Json}} -ExcludeProperty BindGroups | Export-CSV -Path "JumpCloudSystemUsers $(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation
```

This command will gather and format all JumpCloud system user associations and export them to a CSV file named JumpCloudSystemUsers_CurrentDate.CSV created within the directory where the command is run.
Backing up JumpCloud System Information JumpCloud system information can be queried using the JumpCloud PowerShell module command Get-JCSystem (https://github.com/TheJumpCloud/support/wiki/Get-JCSystemUser)This command will by default return all JumpCloud system properties.
Note The properties JumpCloud System ID (_id) and lastContact are always returned when using the Get-JCSystem command.

To only return and export specific system properties to CSV use the '-returnProperties' parameter of the Get-JCSystem command.

```
Get-JCSystem -returnProperties hostname, os, version, serialNumber, remoteIP, systemTimezone | Export-CSV -Path "JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation
```

This command will export all JumpCloud Systems hostname, os, version, serial number, remoteIP, system time zone, system id, and last conntect time to a CSV file named JumpCloudSystems_CurrentDate.CSV created within the directory where the command is run.

The properties "networkInterfaces" and "sshdParams" of JumpCloud systems are returned as nested objects via the JumpCloud PowerShell module.

This means that if the objects are not expanded before exporting to CSV they will simply display as a 'System.Object\[\]' in the output CSV file.

To account for this find the below example which expands each nested object using PowerShell calculated properties and converts the objects to the JSON format.
Note the back tick '\`' escape character is used to break this command into multiple lines for readability.

```
Get-JCSystem | Select-Object *, \`
  @{Name = 'networkInterfaces'; Expression = {$_.networkInterfaces | ConvertTo-Json}}, \`
  @{Name = 'sshdParams'; Expression = {$_.sshdParams | ConvertTo-Json}} \`
  -ExcludeProperty networkInterfaces, sshdParams, connectionHistory | Export-CSV -Path "JumpCloudSystems_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation
```

This command will gather and format all JumpCloud system information and export it to a CSV file named JumpCloudSystems_CurrentDate.CSV created within the directory where the command is run.
If you wish to exclude certain system properties you can append the '-ExcludeProperty' list with the properties you wish to exclude.
Backing up JumpCloud User Groups JumpCloud user group membership can be queried using the JumpCloud PowerShell module command Get-JCUserGroupMember (https://github.com/TheJumpCloud/support/wiki/Get-JCUserGroupMember)Get-JCGroup -Type User | Get-JCUserGroupMember | Export-CSV -Path "JumpCloudUserGroupMembers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation

This command will save all JumpCloud user groups and the group members to a CSV file named JumpCloudUserGroupMember_CurrentDate.CSV created within the directory where the command is run.
Backing up JumpCloud System Groups JumpCloud system group membership can be queried using the JumpCloud PowerShell module command Get-JCSystemGroupMember (https://github.com/TheJumpCloud/support/wiki/Get-JCSystemGroupMember)
```
Get-JCGroup -Type System | Get-JCSystemGroupMember | Export-CSV -Path "JumpCloudSystemGroupMembers_$(Get-Date -Format MMddyyyy).CSV" -NoTypeInformation
```
This command will save all JumpCloud system groups and the group members to a CSV file named JumpCloudSystemGroupMember_CurrentDate.CSV created within the directory where the command is run.

## EXAMPLES

### Example 1
```
Get-JCBackup -All
```

Backs up JumpCloud user, system user, system, user group, and system group information to CSV files.
A CSV backup file will be created for each backup item within the current working directory when this command is run.

### Example 2
```
Get-JCBackup -Users
```

Backs up JumpCloud user information to CSV.
A CSV backup file containing all user information will be created within the current working directory when this command is run.

### Example 3
```
Get-JCBackup -SystemUsers
```

Backs up JumpCloud system user information to CSV.
A CSV backup file containing all system user information will be created within the current working directory when this command is run.

### Example 4
```
Get-JCBackup -Systems
```

Backs up JumpCloud system information to CSV.
A CSV backup file containing all system information will be created within the current working directory when this command is run.

### Example 5
```
Get-JCBackup -UserGroups
```

Backs up JumpCloud user group membership to CSV.
A CSV backup file containing all user group information will be created within the current working directory when this command is run.

### Example 6
```
Get-JCBackup -SystemGroups
```

Backs up JumpCloud system group membership to CSV.
A CSV backup file containing all system group information will be created within the current working directory when this command is run.

### Example 7
```
Get-JCBackup -Users -UserGroups
```

More then one parameter can be specified at one time.
The above example backs up JumpCloud user and user group information to CSV.

## PARAMETERS

### -All
A switch parameter that when called tells the command to back up JumpCloud user, system user, system, user group, and system group information to CSV files.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemGroups
A switch parameter that when called backs up JumpCloud system group membership to CSV.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Systems
A switch parameter that when called backs up JumpCloud system information to CSV.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemUsers
A switch parameter that when called backs up JumpCloud system user information to CSV.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserGroups
A switch parameter that when called backs up JumpCloud user group membership to CSV.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Users
A switch parameter that when called backs up JumpCloud user information to CSV.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
