---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Set-JCOrganization
schema: 2.0.0
---

# Set-JCOrganization

## SYNOPSIS
Allows a multi tenant admin to update their connection to a specific JumpCloud organization.

## SYNTAX

### Choice (Default)
```
Set-JCOrganization [<CommonParameters>]
```

### Entry
```
Set-JCOrganization [-OrgID] <String> [<CommonParameters>]
```

## DESCRIPTION
The Set-JCOrganization command can only be run by JumpCloud admins with multi tenant (MT) associations. By default the Set-JCOrganization run without any parameters with prompt JumpCloud MT admins with a selection list of their available Organizations. Admins can use the '-OrgID' parameter to skip this prompt and set their Organization programmatically. 

## EXAMPLES

### Example 1
```powershell
Set-JCOrganization

======== JumpCloud Multi Tenant Selector ======= 

1. displayName: MSP One | OrgID:  5b5o13o06tsand0c29a0t3s6   
2. displayName: MSP Two | OrgID:  5b5o13o06tsand0d29o0g3s6   

Select the number of the JumpCloud tenant you wish to connect to

Enter a value between 1 and 2:
```

Displays a prompt for MT admins to select which organization to connect to. 

### Example 2
```powershell
Set-JCOrganization -OrgID 5b5o13o06tsand0c29a0t3s6
```

Uses the -OrgID parameter for MT admins to directly connect to a specific JumpCloud org. 

## PARAMETERS

### -OrgID
Only needed for multi tenant admins. Organization ID can be found in the Settings page within the admin console.

```yaml
Type: String
Parameter Sets: Entry
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
