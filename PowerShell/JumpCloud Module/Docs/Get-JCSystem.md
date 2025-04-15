---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCSystem
schema: 2.0.0
---

# Get-JCSystem

## SYNOPSIS
Returns all JumpCloud Systems within a JumpCloud tenant or a single JumpCloud System using the -ByID Parameter.

## SYNTAX

### SearchFilter (Default)
```
Get-JCSystem [[-hostname] <String>] [-displayName <String>] [-description <String>] [-version <String>]
 [-templateName <String>] [-os <String>] [-remoteIP <String>] [-serialNumber <String>] [-arch <String>]
 [-agentVersion <String>] [-systemTimezone <String>] [-active <Boolean>]
 [-allowMultiFactorAuthentication <Boolean>] [-allowPublicKeyAuthentication <Boolean>]
 [-allowSshPasswordAuthentication <Boolean>] [-allowSshRootLogin <Boolean>] [-modifySSHDConfig <Boolean>]
 [-hasServiceAccount <Boolean>] [-filterDateProperty <String>] [-returnProperties <String[]>]
 -dateFilter <String> -date <DateTime> [<CommonParameters>]
```

### ByID
```
Get-JCSystem -SystemID <String> [-SystemFDEKey] -dateFilter <String>
 -date <DateTime> [<CommonParameters>]
```

## DESCRIPTION
The Get-JCSystem function returns all information describing a JumpCloud system. By default this will return all Systems. 

Note: String parameters are case-insensitive

## EXAMPLES

### Example 1
```powershell
Get-JCSystem
```

Returns all JumpCloud managed systems and the information describing these systems.

### Example 2
```powershell
Get-JCSystemUser -SystemID 5n0795a712704la4eve154r
```

Returns a single JumpCloud System with SystemID '5n0795a712704la4eve154r'.

### Example 3
```powershell
Get-JCSystem -active $true
```

Returns all active JumpCloud Systems and the information describing these systems.

### Example 4
```powershell
Get-JCSystem -agentVersion '0.9.6*' -os '*Mac*'
```

Returns all JumpCloud systems where the agentVersion is '0.9.6.*' and the operating system is like '*Mac*'

### Example 5
```powershell
Get-JCSystem -filterDateProperty created -dateFilter after -date 01/01/2018
```

Returns all JumpCloud systems that were created after 01/01/2018 using the parameter -filterDateProperty and the dynamic parameters -dateFilter and -date

### Example 6
```powershell
Get-JCSystem -returnProperties remoteIP, active
```

Returns all JumpCloud systems and the properties remoteIP and active. The default properties that return are lastContact and _id.

### Example 7
```powershell
Get-JCSystem -hostname thisjchost
```

Returns JumpCloud system with hostname 'thisjchost'
NOTE: String parameters are case-insensitive. Hostname 'thisjchost' and 'thisJcHost' will return the same information.

## PARAMETERS

### -active
Filter for systems that are online or offline.

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -agentVersion
A search filter to search systems by the agentVersion.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -allowMultiFactorAuthentication
A search filter to show systems that are enabled ($true) or disabled ($true) for allowMultiFactorAuthentication

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -allowPublicKeyAuthentication
A search filter to show systems that are enabled ($true) or disabled ($true) for allowMultiFactorAuthentication

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -allowSshPasswordAuthentication
A search filter to show systems that are enabled ($true) or disabled ($true) for allowMultiFactorAuthentication

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -allowSshRootLogin
A search filter to show systems that are enabled ($true) or disabled ($true) for allowMultiFactorAuthentication

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -arch
A search filter to search systems by the processor arch.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -date
Date to filter on.

```yaml
Type: System.DateTime
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -dateFilter
Condition to filter date on.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: before, after

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -description
A search filter to search systems by the description.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -displayName
A search filter to search systems by the displayName.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -filterDateProperty
A parameter that can filter on the property 'created' or 'lastContact'.
Only inactive systems will be returned when using the lastContact filter.
This parameter if used creates two more dynamic parameters 'dateFilter' and 'date'.
See EXAMPLE 5 above for full syntax.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:
Accepted values: created, lastContact

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -hasServiceAccount
A search filter to show macOS systems that have the JumpCloud service account

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -hostname
A search filter to search systems by the hostname.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -modifySSHDConfig
A search filter to show systems that are enabled ($true) or disabled ($true) for modifySSHDConfig

```yaml
Type: System.Boolean
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -os
A search filter to search systems by the OS.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -remoteIP
A search filter to search systems by the remoteIP.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -returnProperties
Allows you to return select properties on JumpCloud system objects.
Specifying what properties are returned can drastically increase the speed of the API call with a large data set.
Valid properties that can be returned are: 'created', 'active', 'agentVersion', 'allowMultiFactorAuthentication', 'allowPublicKeyAuthentication', 'allowSshPasswordAuthentication', 'allowSshRootLogin', 'arch', 'created', 'displayName', 'hostname', 'lastContact', 'modifySSHDConfig', 'organization', 'os', 'remoteIP', 'serialNumber', 'sshdParams', 'systemTimezone', 'templateName', 'version'

```yaml
Type: System.String[]
Parameter Sets: SearchFilter
Aliases:
Accepted values: acknowledged, active, agentVersion, allowMultiFactorAuthentication, allowPublicKeyAuthentication, allowSshPasswordAuthentication, allowSshRootLogin, arch, azureAdJoined, connectionHistory, created, displayName, domainInfo, fde, fileSystem, hasServiceAccount, hostname, lastContact, mdm, modifySSHDConfig, networkInterfaces, organization, os, osFamily, provisionMetadata, remoteIP, serialNumber, serviceAccountState, sshdParams, systemInsights, systemTimezone, templateName, userMetrics, usernameHashes, version, hwVendor, secureLogin, displayManager, amazonInstanceID, archFamily, builtInCommands, description, osVersionDetail, policyStats, desktopCapable, sshRootEnabled, isPolicyBound

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -serialNumber
A search filter to search systems by the serialNumber.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SystemFDEKey
A switch parameter to reveal the SystemFDEKey

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: ByID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SystemID
The _id or id of the System which you want to query.

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -systemTimezone
A search filter to search systems by the serialNumber.
This field DOES NOT take wildcard input.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -templateName
A search filter to search systems by the templateName.

```yaml
Type: System.String
Parameter Sets: SearchFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -version
A search filter to search systems by the version.

```yaml
Type: System.String
Parameter Sets: SearchFilter
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
### System.Boolean
### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
