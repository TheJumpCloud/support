---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Set-JCCloudDirectory

## SYNOPSIS
Updates an existing Cloud Directory instance within a JumpCloud tenant

## SYNTAX

### ByName
```
Set-JCCloudDirectory [-Name <String>] [-NewName <String>] [-GroupsEnabled <Boolean>]
 [-UserLockoutAction <String>] [-UserPasswordExpirationAction <String>] [<CommonParameters>]
```

### ByID
```
Set-JCCloudDirectory [-ID <String>] [-NewName <String>] [-GroupsEnabled <Boolean>]
 [-UserLockoutAction <String>] [-UserPasswordExpirationAction <String>] [<CommonParameters>]
```

## DESCRIPTION
Updates an existing JumpCloud Cloud Directory instance by Name or ID

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-JCCloudDirectory -Name 'JumpCloud Office 365' -NewName 'JC O365'
```

Renames the JumpCloud Office 365 instance

### Example 2
```powershell
PS C:\> Set-JCCloudDirectory -Name 'JumpCloud Office 365' -GroupsEnabled $True
```

Sets the GroupsEnabled field to True for the JumpCloud Office 365 instance

### Example 3
```powershell
PS C:\> Set-JCCloudDirectory -Name 'JumpCloud Office 365' -UserLockoutAction 'suspend'
```

Sets the UserLockoutAction field to suspend for the JumpCloud Office 365 instance

### Example 4
```powershell
PS C:\> Set-JCCloudDirectory -Name 'JumpCloud Office 365' -UserPasswordExpirationAction 'suspend'
```

Sets the UserPasswordExpirationAction field to suspend for the JumpCloud Office 365 instance

## PARAMETERS

### -GroupsEnabled
A boolean $true/$false value that enable or disable groups for the Cloud Directory Instance

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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

### -NewName
A string value that will change the name of the Cloud Directory instance

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserLockoutAction
A string value that will change the lockout action for users; valid options: suspend, maintain

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: suspend, maintain

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserPasswordExpirationAction
A string value that will change the password expiration action for users; valid options: suspend, maintain or remove_access (remove_access is only available for Gsuite directories)

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: suspend, maintain, remove_access

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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
