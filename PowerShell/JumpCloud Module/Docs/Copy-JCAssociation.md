---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Copy-JCAssociation
schema: 2.0.0
---

# Copy-JCAssociation

## SYNOPSIS
Copy the associations from one object to another.

## SYNTAX

### ById (Default)
```
Copy-JCAssociation [-Type] <String> [-Force] [-Id] <String[]> [[-TargetId] <String>] [[-TargetName] <String>]
 [-KeepExisting] [<CommonParameters>]
```

### ByName
```
Copy-JCAssociation [-Type] <String> [-Force] [-Name] <String[]> [[-TargetId] <String>] [[-TargetName] <String>]
 [-KeepExisting] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will get the associations of an existing object and will copy those same associations over to a new object.

## EXAMPLES

### Example 1
```powershell
PS C:\> Copy-JCAssociation -Type:('user') -Id:('5cdaef60452f26365ca1fbd0') -TargetId:('5cdaef62de6bf35ce44ad777')
```

The command will remove all of 5cdaef62de6bf35ce44ad777 associations and will copy all of 5cdaef60452f26365ca1fbd0 associations to 5cdaef62de6bf35ce44ad777.

### Example 2
```powershell
PS C:\> Copy-JCAssociation -Type:('user') -Name:('John') -TargetName:('Jim')
```

The command will remove all of Jim's associations and will copy all of John's associations to Jim.

## PARAMETERS

### -Force
Bypass user prompts and dynamic ValidateSet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Id
The unique id of the object.

```yaml
Type: String[]
Parameter Sets: ById
Aliases: _id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -KeepExisting
Retains the existing associations while still adding the new ones.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the object.

```yaml
Type: String[]
Parameter Sets: ByName
Aliases: displayName, username

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetId
The unique id of the target object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetName
The name of the target object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of the object.

```yaml
Type: String
Parameter Sets: (All)
Aliases: TypeNameSingular
Accepted values: command, ldap_server, policy, application, radius_server, system_group, system, user_group, user, g_suite, office_365

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Management.Automation.SwitchParameter
### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
