---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
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

The Get-JCBackup command saves JumpCloud directory information to CSV files. This command can be used to backup user, system user, system, user group, and system group information to CSV files. Specific items can be selected for CSV backup using the command or the '-All' switch paramter can be specified which will backup all items.

## EXAMPLES

### Example 1
```powershell
Get-JCBackup -All
```
Backs up JumpCloud user, system user, system, user group, and system group information to CSV files. A CSV backup file will be created for each backup item within the current working directory when this command is run.

### Example 2
```powershell
Get-JCBackup -Users
```
Backs up JumpCloud user information to CSV. A CSV backup file containing all user information will be created within the current working directory when this command is run.

### Example 3
```powershell
Get-JCBackup -SystemUsers
```
Backs up JumpCloud system user information to CSV. A CSV backup file containing all system user information will be created within the current working directory when this command is run.

### Example 4
```powershell
Get-JCBackup -Systems
```
Backs up JumpCloud system information to CSV. A CSV backup file containing all system information will be created within the current working directory when this command is run.

### Example 5
```powershell
Get-JCBackup -UserGroups
```
Backs up JumpCloud user group membership to CSV. A CSV backup file containing all user group information will be created within the current working directory when this command is run.

### Example 6
```powershell
Get-JCBackup -SystemGroups
```
Backs up JumpCloud system group membership to CSV. A CSV backup file containing all system group information will be created within the current working directory when this command is run.

### Example 7
```powershell
Get-JCBackup -Users -UserGroups
```
More then one parameter can be specified at one time. The above example backs up JumpCloud user and user group information to CSV.

## PARAMETERS

### -All

A switch parameter that when called tells the command to back up JumpCloud user, system user, system, user group, and system group information to CSV files.


```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemGroups

A switch parameter that when called backs up JumpCloud system group membership to CSV.


```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemUsers

A switch parameter that when called backs up JumpCloud system user information to CSV.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Systems

A switch parameter that when called backs up JumpCloud system information to CSV.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserGroups

A switch parameter that when called backs up JumpCloud user group membership to CSV.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Users

A switch parameter that when called backs up JumpCloud user information to CSV.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
[Online Help Get-JCBackup](https://github.com/TheJumpCloud/support/wiki/Get-JCBackup)