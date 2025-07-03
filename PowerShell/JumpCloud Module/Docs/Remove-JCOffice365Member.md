---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Remove-JCOffice365Member

## SYNOPSIS
Removes a user or usergroup from an Office365 instance

## SYNTAX

### ByName
```
Remove-JCOffice365Member [-Name <String>] [-Username <String>] [-UserID <String>] [-GroupID <String>]
 [-GroupName <String>] [<CommonParameters>]
```

### ByID
```
Remove-JCOffice365Member [-ID <String>] [-Username <String>] [-UserID <String>] [-GroupID <String>]
 [-GroupName <String>] [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCOffice365Member function allows you to remove users or UserGroups from a GSuite Cloud Directory instance in your organization

## EXAMPLES

### Example 1
```powershell
Remove-JCOffice365Member -Name 'JumpCloud Office365' -Username 'john.doe'
```

Removes the user john.doe from the JumpCloud Office365 CloudDirectory instance

### Example 2
```powershell
Remove-JCOffice365Member -Name 'JumpCloud Office365' -GroupName 'Sales Users'
```

Removes the Sales Users UserGroup from the JumpCloud Office365 CloudDirectory instance

## PARAMETERS

### -GroupID
A UserGroup ID to remove to the directory

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GroupName
A UserGroup name to remove to the directory

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ID
The ID of cloud directory instance

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of cloud directory instance

```yaml
Type: System.String
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserID
A UserID to remove to the directory

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username
A username to remove to the directory

```yaml
Type: System.String
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
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
