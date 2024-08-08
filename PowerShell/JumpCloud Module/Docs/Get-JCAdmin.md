---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCAdmin

## SYNOPSIS
Gets JumpCloud administrators in your organization

## SYNTAX

```
Get-JCAdmin [[-email] <String>] [[-enableMultifactor] <Boolean>] [[-totpEnrolled] <Boolean>]
 [[-roleName] <String>] [[-organization] <String>] [<CommonParameters>]
```

## DESCRIPTION
Allows you to search for JumpCloud administrators in your organization. If you have a MSP/MTP tenant, you can query all administrators across all organizations

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCAdmin
```

Returns all administrators

### Example 2
```powershell
PS C:\> Get-JCAdmin -email "john.doe@example.com"
```

Returns a specific administrator using their email address

### Example 3
```powershell
PS C:\> Get-JCAdmin -email "john*"
```

Returns all administrators that contains john in their email address

### Example 4
```powershell
PS C:\> Get-JCAdmin -enableMultifactor $true
```

Returns all administrators that have multifactor enabled

### Example 5
```powershell
PS C:\> Get-JCAdmin -totpEnrolled $true
```

Returns all administrators that have totp enabled/enrolled

### Example 6
```powershell
PS C:\> Get-JCAdmin -roleName "Administrator With Billing"
```

Returns all administrators that have the Administrator With Billing role

### Example 7
```powershell
PS C:\> Get-JCAdmin -email "john*" -enableMultiFactor $true -roleName "Administrator With Billing"
```

Returns all administrators that contains john in their email address, have mutlifactor enabled and have the Administrator With Billing role

### Example 8
```powershell
PS C:\> Get-JCAdmin -organization "organizationID"
```

Returns all administrators that are within a specific organization (this can only be utilized by MTP/MSP tenants)

## PARAMETERS

### -email
The email of the JumpCloud admin you wish to search for.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -enableMultifactor
A search filter to search for admins with multifactor enabled/disabled.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -organization
A search filter to search for admins based on their organization (Only for MTP/MSP tenants)

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -roleName
A search filter to search for admins based on their role

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -totpEnrolled
A search filter to search for admins with totp enabled/disabled.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Boolean
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
