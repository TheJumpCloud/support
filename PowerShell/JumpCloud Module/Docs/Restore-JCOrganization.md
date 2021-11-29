---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Restore-JCOrganization

## SYNOPSIS
The function exports objects from your JumpCloud organization to local json files

## SYNTAX

### All (Default)
```
Restore-JCOrganization -Path <FileInfo> [-All] [<CommonParameters>]
```

### Type
```
Restore-JCOrganization -Path <FileInfo> [-Type <String[]>] [-Association] [<CommonParameters>]
```

## DESCRIPTION
The function exports objects from your JumpCloud organization to local json files

## EXAMPLES

### EXAMPLE 1
```
Restore UserGroups and Users with their associations
PS C:\> Restore-JCOrganization -Path:('C:\Temp\JumpCloud_20201222T1324549196.zip') -Type:('UserGroup','User') -Association
```

### EXAMPLE 2
```
Restore UserGroups and Users without their associations
PS C:\> Restore-JCOrganization -Path:('C:\Temp\JumpCloud_20201222T1324549196.zip') -Type:('UserGroup','User')
```

### EXAMPLE 3
```
Restore all avalible JumpCloud objects and their Association
PS C:\> Restore-JCOrganization -Path:('C:\Temp\JumpCloud_20201222T1324549196.zip') -All
```

## PARAMETERS

### -All
The Username of the JumpCloud user you wish to search for

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
Include to backup object type Association

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

### -Path
Specify input .zip file path for restore files

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
Specify the type of JumpCloud objects you want to backup.
Restore of "System" is unavailable.

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

[https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Restore-JCOrganization.md](https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Restore-JCOrganization.md)

