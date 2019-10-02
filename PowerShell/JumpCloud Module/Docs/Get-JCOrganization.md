---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCOrganization
schema: 2.0.0
---

# Get-JCOrganization

## SYNOPSIS
Returns all JumpCloud organizations associated with the authenticated JumpCloud admins account.

## SYNTAX

```
Get-JCOrganization [<CommonParameters>]
```

## DESCRIPTION
The Get-JCOrganization command displays all JumpCloud organizations associated with the authenticated JumpCloud admins. JumpCloud admins configured for multi tenant administration can see the Organizations they have access to and the displayName and OrgID for these accounts.

## EXAMPLES

### Example 1
```powershell
Get-JCOrganization
```

Displays the JumpCloud organizations associated with the authenticated JumpCloud admin.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
