---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# New-JCImportTemplate

## SYNOPSIS

A guided walk through that creates a JumpCloud User Import CSV file on your local machine.

## SYNTAX

```
New-JCImportTemplate [<CommonParameters>]
```

## DESCRIPTION

The New-JCImportTemplate command is a menu driven function that guides end users and creates a custom JumpCloud User Import .CSV file on their machine for populating with their users information for Importing into JumpCloud.

If users wish to bind users to existing JumpCloud systems the function will also output a .csv file with containing all existing JumpCloud machines to the users $Home directory. The user will need this file to associate SystemIDs with new users.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> New-JCImportTemplate
```

Launches the New-JCImportTemplate menu

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[Online Help New-JCImportTemplate](https://github.com/TheJumpCloud/support/wiki/New-JCImportTemplate)