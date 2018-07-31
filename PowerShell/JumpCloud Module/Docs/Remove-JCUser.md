---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# Remove-JCUser

## SYNOPSIS

Removes a JumpCloud User

## SYNTAX

### warn (Default)
```
Remove-JCUser -Username <String> [-UserID <String>] [-ByID] [<CommonParameters>]
```

### force
```
Remove-JCUser [-Username <String>] [-UserID <String>] [-force] [-ByID] [<CommonParameters>]
```

## DESCRIPTION

The Remove-JCUser function will remove a JumpCloud user from the JumpCloud organization. This will remove the deleted users access to any JumpCloud bound resources.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Remove-JCUser cclemons
```

Removes the JumpCloud User with Username 'cclemons'. A warning message will be presented to confirm this operation.

### Example 2

```PowerShell
PS C:\> Remove-JCUser cclemons -Force
```

Removes the JumpCloud User with Username 'cclemons' using the -Force Parameter. A warning message will not be presented to confirm this operation.

## PARAMETERS

### -ByID

Use the -ByID parameter when the UserID is passed over the pipeline to the Remove-JCUser function. The -ByID SwitchParameter will set the ParameterSet to 'ByID' which will increase the function speed and performance.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserID

The _id of the User which you want to delete.

To find a JumpCloud UserID run the command:



PS C:\> Get-JCUser | Select username, _id

The UserID will be the 24 character string populated for the _id field.

UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically.

```yaml
Type: String
Parameter Sets: (All)
Aliases: _id

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username

The Username of the JumpCloud user you wish to remove.

```yaml
Type: String
Parameter Sets: warn
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: force
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -force

A SwitchParameter which suppresses the warning message when removing a JumpCloud User.

```yaml
Type: SwitchParameter
Parameter Sets: force
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Online Help Remove-JCUser](https://github.com/TheJumpCloud/support/wiki/Remove-JCUser)