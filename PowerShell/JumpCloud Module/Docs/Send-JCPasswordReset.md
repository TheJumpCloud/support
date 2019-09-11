---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Send-JCPasswordReset
schema: 2.0.0
---

# Send-JCPasswordReset

## SYNOPSIS
Sends a JumpCloud activation/password reset email.

## SYNTAX

### ByID (Default)
```
Send-JCPasswordReset [[-UserID] <String>] [<CommonParameters>]
```

### ByUsername
```
Send-JCPasswordReset [[-username] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Send-JCPasswordReset command sends a JumpCloud activation/password reset email to targeted users. This function mimics the functionality of the 'resend email' button in the JumpCloud admin console.
Pending users will recieve an activation email. Active users will receive a password reset request.

## EXAMPLES

### Example 1
```powershell
Send-JCPasswordReset -username jcuser.one
```

Sends an activation or reset email to JumpCloud user with username 'jcuser.one'

### Example 2
```powershell
Get-JCUserGroupMember -GroupName NewUsers | Send-JCPasswordReset
```

Sends an activation or reset email to all members of the JumpCloud user group 'NewUsers'.

### Example 3
```powershell
Get-JCUser -activated $false | Send-JCPasswordReset
```

Sends an activation email to all JumpCloud users who are in an inactive state. Users that are inactive have not yet set their JumpCloud user passwords.

### Example 4
```powershell
Get-JCUser -activated $false -filterDateProperty created -dateFilter after -date (Get-Date).AddDays(-7) -returnProperties username | Send-JCPasswordReset
```

Sends an activation email to all JumpCloud users who are in an inactive state and were created in the last seven days. Users that are inactive have not yet set their JumpCloud user passwords.

## PARAMETERS

### -UserID
The _id of the User which you want to send the email.
To find a JumpCloud UserID run the command: PS C:\\\> Get-JCUser | Select username, _id

The UserID will be the 24 character string populated for the _id field.

```yaml
Type: String
Parameter Sets: ByID
Aliases: _id, id

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -username
The Username of the JumpCloud user you wish to send the email.

```yaml
Type: String
Parameter Sets: ByUsername
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Object
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
