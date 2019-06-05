---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCSystemUser
schema: 2.0.0
---

# Get-JCSystemUser

## SYNOPSIS
Returns all JumpCloud Users associated with a JumpCloud System.

## SYNTAX

```
Get-JCSystemUser [-SystemID] <String> [<CommonParameters>]
```

## DESCRIPTION
The Get-JCSystemUser function returns all the JumpCloud Users associated with the system. Users can be associated with a JumpCloud system through a direct bind, a User Group, or both. The output of the Get-JCSystemUser identifies the associations between JumpCloud Users and the system.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCSystemUser -SystemID 59f2s305383coo7t369ef7r2
```

This example returns all users associated with the JumpCloud System with a SystemID of '59f2s305383coo7t369ef7r2'

### Example 2
```powershell
PS C:\> Get-JCSystem | Get-JCSystemUser
```

This example returns all the JumpCloud users associated with all JumpCloud systems within a JumpCloud tenant.

### Example 3
```powershell
PS C:\> Get-JCSystem | Where-Object os -like *Mac* | Get-JCSystemUser
```

This example returns all the JumpCloud users associated with all JumpCloud systems within an operating system like 'Mac'.

### Example 4
```powershell
PS C:\>  Get-JCSystem | Get-JCSystemUser | Where-Object Administrator -EQ True
```

This example returns all the JumpCloud users whos have Administrator permissions on JumpCloud systems.

## PARAMETERS

### -SystemID
The _id of the System which you want to query.
To find a JumpCloud SystemID run the command:
PS C:\> Get-JCSystem | Select hostname, _id
The SystemID will be the 24 character string populated for the _id field.
SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Get-JCSystemUser. This is shown in EXAMPLES 2 and 3.

```yaml
Type: String
Parameter Sets: (All)
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
