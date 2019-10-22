---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Import-JCCommand
schema: 2.0.0
---

# Import-JCCommand

## SYNOPSIS
Imports a Mac, Linux or Windows JumpCloud Command into the JumpCloud admin portal from a URL

## SYNTAX

```
Import-JCCommand [-URL] <String> [<CommonParameters>]
```

## DESCRIPTION
The Import-JCCommand command can be used to import curated JumpCloud Mac, Linux, and Windows commands into a JumpCloud tenant

See all available commands in the [JumpCloud Commands Gallery](https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Commands%20Gallery)

## EXAMPLES

### Example 1
```powershell
Import-JCCommand -URL 'https://git.io/jccg-Windows-ListAllUsers'
```

Imports the JumpCloud command located at the URL 'Import-JCCommand -URL 'https://git.io/jccg-Windows-ListAllUsers' into a JumpCloud tenant. This command lists all user accounts on a Windows system and shows if the account is enabled or disabled

## PARAMETERS

### -URL
The URL of the JumpCloud command to import into a JumpCloud tenant.

```yaml
Type: System.String
Parameter Sets: (All)
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
