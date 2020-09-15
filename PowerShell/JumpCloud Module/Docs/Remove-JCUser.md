---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCUser
schema: 2.0.0
---

# Remove-JCUser

## SYNOPSIS
Removes a JumpCloud User

## SYNTAX

### Username (Default)
```
Remove-JCUser [-Username] <String> [-force] [<CommonParameters>]
```

### UserID
```
Remove-JCUser -UserID <String> [-ByID] [-force] [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCUser function will remove a JumpCloud user from the JumpCloud organization.
This will remove the deleted users access to any JumpCloud bound resources.

## EXAMPLES

### Example 1
```
PS C:\> Remove-JCUser cclemons
```

Removes the JumpCloud User with Username 'cclemons'.
A warning message will be presented to confirm this operation.

### Example 2
```
PS C:\> Remove-JCUser cclemons -Force
```

Removes the JumpCloud User with Username 'cclemons' using the -Force Parameter.
A warning message will not be presented to confirm this operation.

## PARAMETERS

### -ByID
Use the -ByID parameter when the UserID is passed over the pipeline to the Remove-JCUser function.
The -ByID SwitchParameter will set the ParameterSet to 'ByID' which will increase the function speed and performance.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: UserID
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -force
A SwitchParameter which suppresses the warning message when removing a JumpCloud User.

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

### -UserID
The _id of the User which you want to delete.

To find a JumpCloud UserID run the command:

PS C:\\\> Get-JCUser | Select username, _id

The UserID will be the 24 character string populated for the _id field.

UserID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically.

```yaml
Type: System.String
Parameter Sets: UserID
Aliases: _id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username
The Username of the JumpCloud user you wish to remove.

```yaml
Type: System.String
Parameter Sets: Username
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

## RELATED LINKS
