---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JcSdkEventCount
schema: 2.0.0
---

# Get-JCScheduledUserstate

## SYNOPSIS
Returns scheduled userstate changes by state or returns a user's scheduled userstate changes

## SYNTAX

### BulkLookup (Default)
```
Get-JCScheduledUserstate -State <String> [<CommonParameters>]
```

### ByID
```
Get-JCScheduledUserstate -UserId <String> [<CommonParameters>]
```

## DESCRIPTION
Get-JCScheduledUserstate function allows for admins to view upcoming scheduled user suspensions or activations. You can also look up an individual user's upcoming state changes by their userID

## EXAMPLES

### Example 1
```powershell
Get-JCScheduledUserstate -State "SUSPENDED"
```

Returns all scheduled SUSPENDED userstate changes

### Example 2
```powershell
Get-JCScheduledUserstate -State "ACTIVATED"
```

Returns all scheduled ACTIVATED userstate changes

### Example 2
```powershell
Get-JCScheduledUserstate -UserID "USERID"
```

Returns all scheduled userstate changes for a given userID

## PARAMETERS

### -State
The scheduled state you'd like to query (SUSPENDED or ACTIVATED)

```yaml
Type: System.String
Parameter Sets: BulkLookup
Aliases:
Accepted values: SUSPENDED, ACTIVATED

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserId
The _id of the User which you want to lookup.
UserID has an Alias of _id.

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id, id

Required: True
Position: Named
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
