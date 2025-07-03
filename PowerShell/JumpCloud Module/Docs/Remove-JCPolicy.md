---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Remove-JCPolicy

## SYNOPSIS
Removes a JumpCloud Policy

## SYNTAX

### ByID
```
Remove-JCPolicy [-PolicyID] <String> [-force] [<CommonParameters>]
```

### Name
```
Remove-JCPolicy [-Name <String>] [-force] [<CommonParameters>]
```

## DESCRIPTION
The Remove-JCPolicy function will remove a JumpCloud Policy from the JumpCloud organization.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-JCPolicy -Name "Allow The Use of Biometrics"
```

This will remove the JumpCloud Policy with the name Allow The Use of Biometrics

### Example 2
```powershell
PS C:\> Remove-JCPolicy -PolicyID "645bea14b069dd0001bbe232"
```

This will remove the JumpCloud Policy by its corresponding ID

## PARAMETERS

### -force
A SwitchParameter which suppresses the warning message when removing a JumpCloud Policy.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The Name of the JumpCloud policy you wish to remove.

```yaml
Type: System.String
Parameter Sets: Name
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PolicyID
The PolicyID of the JumpCloud policy you wish to remove.

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id, id

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
