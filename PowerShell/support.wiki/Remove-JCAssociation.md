# Remove-JCAssociation

## SYNOPSIS
Remove an association between two object within the JumpCloud console.

## SYNTAX

### ById (Default)
```
Remove-JCAssociation [-Type] <String> [-Force] [-Id] <String[]> [[-TargetType] <String[]>]
 [[-TargetId] <String>] [[-TargetName] <String>] [<CommonParameters>]
```

### ByName
```
Remove-JCAssociation [-Type] <String> [-Force] [-Name] <String[]> [[-TargetType] <String[]>]
 [[-TargetId] <String>] [[-TargetName] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCAssociation function allows you to create associations of a specific object to a target object.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-JCAssociation -Type:('radiusservers') -Id:('5c5c371704c4b477964ab4fa') -TargetType:('user_group') -TargetId:('59f20255c9118021fa01b80f')
```

Remove the association between the radius server "5c5c371704c4b477964ab4fa" and the user group "59f20255c9118021fa01b80f".

### Example 2
```powershell
PS C:\> New-JCAssociation -Type:('radiusservers') -Name:('RadiusServer1') -TargetType:('user_group') -TargetName:('All Users')
```

Remove the association between the radius server "RadiusServer1" and the user group "All Users".

## PARAMETERS

### -Force
Bypass user prompts and dynamic ValidateSet.

```yaml
Type: System.Management.Automation.SwitchParameter
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
Type: System.String[]
Parameter Sets: ById
Aliases: _id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the object.

```yaml
Type: System.String[]
Parameter Sets: ByName
Aliases: domain, displayName, username

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetId
The unique id of the target object.

```yaml
Type: System.String
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
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetType
The type of the target object.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases: TargetSingular
Accepted values: user, user_group, system, system_group, policy, command, application, g_suite, ldap_server, office_365, radius_server

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of the object.

```yaml
Type: System.String
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
