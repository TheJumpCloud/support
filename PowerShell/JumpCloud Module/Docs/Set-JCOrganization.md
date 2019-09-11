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

```
Set-JCOrganization [[-JumpCloudApiKey] <String>] [[-JumpCloudOrgId] <String>] [<CommonParameters>]
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

### -JumpCloudApiKey
Please enter your JumpCloud API key.
This can be found in the JumpCloud admin console within "API Settings" accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JumpCloudOrgId
Organization Id can be found in the Settings page within the admin console.
Only needed for multi tenant admins.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
