---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Set-JCSystemUser
schema: 2.0.0
---

# Set-JCSystemUser

## SYNOPSIS
Updates the permissions of a JumpCloud user on a JumpCloud system

## SYNTAX

### ByName (Default)
```
Set-JCSystemUser [-Username] <String> -SystemID <String> -Administrator <Boolean> [<CommonParameters>]
```

### ByID
```
Set-JCSystemUser -UserID <String> -SystemID <String> -Administrator <Boolean> [<CommonParameters>]
```

## DESCRIPTION
The Set-JCSystemUser function updates the permissions between a JumpCloud user and a JumpCloud system. The command can be used to add or remove Administrator permissions for a JumpCloud user on a JumpCloud managed system.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-JCSystemUser -SystemID 5n0795a712704la4eve154r -Username cclemons -Administrator $True
```

Sets user with username 'cclemons' as an Administrator on the JumpCloud system with SystemID '5n0795a712704la4eve154r'

### Example 2
```powershell
PS C:\> Set-JCSystemUser -SystemID 5n0795a712704la4eve154r -Username cclemons -Administrator $False
```

Sets user with username 'cclemons' as a standard user on the JumpCloud system with SystemID '5n0795a712704la4eve154r'

### Example 3
```powershell
PS C:\> Get-JCSystemUser 5n0795a712704la4eve154r  | Set-JCSystemUser -Administrator $False
```

Gets all users bound to JumpCloud system with SystemID '5n0795a712704la4eve154r' and sets them as standard users. Note any users who have Global Administrator permissions would keep their Administrator permissions. To find users with Global Administrator permissions run the command: 'Get-JCUser | Where-Object sudo -EQ $true'

## PARAMETERS

### -Administrator
A boolean $true/$false value to add or remove Administrator permissions on a target JumpCloud system

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SystemID
The _id of the JumpCloud System which you want to modify the permissions on

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: _id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserID
The _id of the JumpCloud User whose system permissions will be modified

```yaml
Type: System.String
Parameter Sets: ByID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username
The Username of the JumpCloud User whose system permissions will be modified

```yaml
Type: System.String
Parameter Sets: ByName
Aliases:

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
### System.Boolean
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
