---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCCloudDirectory

## SYNOPSIS
Returns all Cloud Directory instances within a JumpCloud tenant, a single Cloud Directory instance using the -ID or -Name Parameter, or directories matching a single type using the -Type Parameter.

## SYNTAX

### ReturnAll (Default)
```
Get-JCCloudDirectory [-Type <String>] [<CommonParameters>]
```

### ByName
```
Get-JCCloudDirectory [-Type <String>] [-Name <String>] [<CommonParameters>]
```

### ByID
```
Get-JCCloudDirectory [-Type <String>] [-ID <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-JCCloudDirectory function returns all information describing a JumpCloud Cloud Directory instance. To find the contents and payload of a specific instance the -ID or -Name Parameter must be used as this information is only accessible when using this Parameter. The associations for an individual Cloud Directory can also be queried using the -Association Parameter and specifying either 'Users' or 'UserGroups'

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCCloudDirectory
```

Returns all Cloud Directory instances within a JumpCloud tenant

### Example 2
```powershell
PS C:\> Get-JCCloudDirectory -Type office_365
```

Returns all Office 365 Cloud Directory instances within a JumpCloud tenant

### Example 3
```powershell
PS C:\> Get-JCCloudDirectory -Name 'JumpCloud Office 365'
```

Returns the JumpCloud Office 365 Cloud Directory instance properties

### Example 4
```powershell
PS C:\> Get-JCCloudDirectory -Name 'JumpCloud Office 365' -Association Users
```

Returns the direct and indirect user associations for the JumpCloud Office 365 Cloud Directory instance

### Example 5
```powershell
PS C:\> Get-JCCloudDirectory -Name 'JumpCloud Office 365' -Association UserGroups
```

Returns the direct user group associations for the JumpCloud Office 365 Cloud Directory instance

## PARAMETERS

### -ID
The ID of cloud directory instance

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of cloud directory instance

```yaml
Type: System.String
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
The type of cloud directory

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: g_suite, office_365

Required: False
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
