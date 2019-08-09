---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Add-JCSystemUser
schema: 2.0.0
---

# Add-JCSystemUser

## SYNOPSIS
Associates a JumpCloud User account with a local account on a JumpCloud managed System.

## SYNTAX

### ByName (Default)
```
Add-JCSystemUser [-Username] <String> -SystemID <String> [-Administrator <Boolean>] [<CommonParameters>]
```

### ByID
```
Add-JCSystemUser -UserID <String> -SystemID <String> [-Administrator <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
The Add-JCSystemUser function allows you to bind a JumpCloud user to a JumpCloud system and set the user pemissions. When binding a user to a system the JumpCloud agent can complete one of two actions on the target system.
1. If there is an existing local user account on the target system with a Username that matches identically with the Username of the newly bound user then the JumpCloud agent will take over and manage the password of the existing local account.
1. If there is not an existing local user account on the target system with a Username that matches identically with the Username of the newly bound user then the JumpCloud agent will create a new account on the system with the Username of the newly bound user.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-JCSystemUser -Username cclemons -SystemID 5a0795nnie7127f4ev2erb154a -Administrator $True
```

Adds the JumpCloud user with the Username 'cclemons' to the System with a SystemID of '5a0795nnie7127f4ev2erb154a' and grants administrator permission

### Example 2
```powershell
PS C:\> Get-JCSystemUser -SystemID 5a0795nnie7127f4ev2erb154a | Add-JCSystemUser -SystemID 59f2c305383cba7e369df7c2
```

Adds all JumpCloud users associated with the JumpCloud system with a SystemID of '5a0795aa7127f4aa2ddb154a' and adds them to the JumpCloud system with a SystemID of '59f2c305383cba7e369df7c2' using Parameter Binding and the pipeline. Because '-Administrator' was not specified the users will be added as standard users

### Example 3
```powershell
PS C:\> Get-JCUserGroupMember -GroupName 'The Band' | Add-JCSystemUser -SystemID 5a0795nnie7127f4ev2erb154a -Administrator $True
```

Adds all JumpCloud users in the JumpCloud User Group 'The Band' and binds them to the JumpCloud system with a SystemID of '5a0795nnie7127f4ev2erb154a' as Administrators using Parameter Binding and the pipeline.

## PARAMETERS

### -Administrator
A boolean $true/$false value to set Administrator permissions on the target JumpCloud system

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SystemID
The _id of the System which you want to bind the JumpCloud user to.
To find a JumpCloud SystemID run the command:
PS C:\\\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field.
SystemID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID.

```yaml
Type: String
Parameter Sets: (All)
Aliases: _id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserID
The _id of the User which you want to add to the JumpCloud system.
To find a JumpCloud UserID run the command:
PS C:\\\> Get-JCUser | Select username, _id
The UserID will be the 24 character string populated for the _id field.
UserID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud UserID.
This is shown in EXAMPLES 2, 3, and 4.

```yaml
Type: String
Parameter Sets: ByID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username
The Username of the JumpCloud user you wish to add to the JumpCloud system.

```yaml
Type: String
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
