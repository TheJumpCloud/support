---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCSystemUser
schema: 2.0.0
---

# Remove-JCSystemUser

## SYNOPSIS
Disables a JumpCloud User account on a JumpCloud System.

## SYNTAX

### ByName (Default)
```
Remove-JCSystemUser [-Username] <String> -SystemID <String> [<CommonParameters>]
```

### Force
```
Remove-JCSystemUser [-Username] <String> -SystemID <String> [-force] [<CommonParameters>]
```

### ByID
```
Remove-JCSystemUser -SystemID <String> -UserID <String> [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCSystemUser function allows you disable a JumpCloud managed local user account on a JumpCloud System. The Remove-JCSystemUser function tells the JumpCloud agent to set the managed local account into a disabled state.
Note* The Remove-JCSystemUser does not delete the account or any data from the target machine.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-JCSystemUser -Username cclemons -SystemID 5a0795nnie7127f4ev2erb154a
```

Removes the JumpCloud user with the Username 'cclemons' from the System with a SystemID of '5a0795nnie7127f4ev2erb154a'. A warning message will be presented to confirm this operation.

### Example 2
```powershell
PS C:\> Remove-JCSystemUser -Username cclemons -SystemID 5a0795nnie7127f4ev2erb154a -force
```

Removes the JumpCloud user with the Username 'cclemons' from the System with a SystemID of '5a0795nnie7127f4ev2erb154a' using the -force Parameter. A warning message will not be presented to confirm this operation.

### Example 3

```powershell
PS C:\> Get-JCSystemUser -SystemID 5a0795nnie7127f4ev2erb154a | Remove-JCSystemUser
```

Removes all JumpCloud users bound directly to the System with a System ID of '5a0795nnie7127f4ev2erb154a' using Parameter binding and the pipeline. A warning message will be displayed to confirm each remove operation.

### Example 4
```powershell
PS C:\> Get-JCSystemUser -SystemID 5a0795nnie7127f4ev2erb154a | Remove-JCSystemUser -Force
```

Removes all JumpCloud users bound directly to the System with a System ID of '5a0795nnie7127f4ev2erb154a' using Parameter binding and the pipeline. A warning message will not be displayed to confirm each remove operation because of the presence of the -Force Parameter.

## PARAMETERS

### -force
A SwitchParameter which suppresses the warning message when removing a JumpCloud user from a JumpCloud system.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Force
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemID
The _id of the System which you want to bind the JumpCloud user to.
To find a JumpCloud SystemID run the command: PS C:\\\> Get-JCSystem | Select hostname, _id The SystemID will be the 24 character string populated for the _id field.
SystemID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID.
This is shown in EXAMPLES 3 and 4.

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
The _id of the User which you want to remove from the JumpCloud system.
To find a JumpCloud UserID run the command: PS C:\\\> Get-JCUser | Select username, _id The UserID will be the 24 character string populated for the _id field.
UserID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud UserID.
This is shown in EXAMPLES 3 and 4.

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
The Username of the JumpCloud user you wish to remove from the JumpCloud system.

```yaml
Type: System.String
Parameter Sets: ByName, Force
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

## OUTPUTS

### System.Object
## NOTES
If a JumpCloud user is removed in error from a system using the Remove-JCSystemUser the error can be quickly remedied by running the Add-JCSystemUser command to re-enable the user.

## RELATED LINKS
