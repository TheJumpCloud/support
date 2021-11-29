---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Backup-JCOrganization

## SYNOPSIS
Backup your JumpCloud organization to local json files

## SYNTAX

### All (Default)
```
Backup-JCOrganization -Path <FileInfo> [-All] [-Format <String>] [-PassThru] [<CommonParameters>]
```

### Type
```
Backup-JCOrganization -Path <FileInfo> [-Type <String[]>] [-Association] [-Format <String>] [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION
This function exports objects and associations from your JumpCloud organization to local json files.
Association takes a significant amount of time to gather.
The -Format:('csv') is slower than standard json output.

## EXAMPLES

### EXAMPLE 1
```
Backup all available JumpCloud objects and their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp')
```

### EXAMPLE 2
```
Backup all available JumpCloud objects and their associations to CSV (default json)
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Format:('csv')
```

### EXAMPLE 3
```
Backup selected types UserGroups and Users with no associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','User')
```

### EXAMPLE 4
```
Backup selected types UserGroups and Users with their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','User') -Association
```

### EXAMPLE 5
```
Backup UserGroups and Users without their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','User')
```

### EXAMPLE 6
```
Backup all available JumpCloud objects and their associations and return metadata
PS C:\> $BackupJcOrganizationResults = Backup-JCOrganization -Path:('C:\Temp') -PassThru
PS C:\> $BackupJcOrganizationResults.Keys
PS C:\> $BackupJcOrganizationResults.User
```

## PARAMETERS

### -All
Backup all available types and associations

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Association
Use to backup association data

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Type
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Format
The format of the output files

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Json
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return object metadata to pipeline

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

### -Path
File path for backup output

```yaml
Type: System.IO.FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
JumpCloud objects that you want to backup

```yaml
Type: System.String[]
Parameter Sets: Type
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

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Backup-JCOrganization.md](https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Backup-JCOrganization.md)
