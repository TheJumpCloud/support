---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Add-JCOffice365Member

## SYNOPSIS
Adds a user or usergroup to an Office365 instance

## SYNTAX

### ByName
```
Add-JCOffice365Member [-Name <String>] [-Username <String>] [-UserID <String>] [-GroupID <String>]
 [-GroupName <String>] [<CommonParameters>]
```

### ByID
```
Add-JCOffice365Member [-ID <String>] [-Username <String>] [-UserID <String>] [-GroupID <String>]
 [-GroupName <String>] [<CommonParameters>]
```

## DESCRIPTION
The Add-JCOffice365Member function allows you to add users or UserGroups to a GSuite Cloud Directory instance in your organization

## EXAMPLES

### Example 1
```powershell
Add-JCOffice365Member -Name 'JumpCloud Office365' -Username 'john.doe'
```

Adds the user john.doe to the JumpCloud Office365 CloudDirectory instance

### Example 2
```powershell
Add-JCOffice365Member -Name 'JumpCloud Office365' -GroupName 'Sales Users'
```

Adds the Sales Users UserGroup to the JumpCloud Office365 CloudDirectory instance

## PARAMETERS

### -GroupID
A UserGroup ID to add to the directory

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
A UserGroup name to add to the directory

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
A UserID to add to the directory

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
A username to add to the directory

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
