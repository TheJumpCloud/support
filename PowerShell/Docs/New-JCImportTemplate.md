---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# New-JCImportTemplate

## SYNOPSIS

A guided walkthrough that creates a JumpCloud User Import .CSV file on your local machine

## SYNTAX

```PowerShell
New-JCImportTemplate
```

## DESCRIPTION

The New-JCImportTemplate is a menu driven function that guides end users and creates a custom JumpCloud User Import .CSV file on their machine for populating with their users information for Importing into JumpCloud.

If users wish to bind users to existing JumpCloud systems the function will also output a .csv file with containing all existing JumpCloud machines to the users $Home directory. The user will need this file to associate SystemIDs with new users.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> New-JCImportTemplate
```

Launches the New-JCImportTemplate menu

## PARAMETERS

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
