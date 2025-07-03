---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCSystemKB

## SYNOPSIS
Returns applied hotfixes/KBs on Windows devices

## SYNTAX

### All (Default)
```
Get-JCSystemKB [<CommonParameters>]
```

### SearchFilter
```
Get-JCSystemKB [-SystemID <String[]>] [-KB <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
The Get-JCSystemKB function returns all applied hotfixes/KBs on Windows Devices. The function can be used to filter based on a specific hotfix/KB, a specific system, or both. An object is returned that contains information on the hotfix/KB including the description of the KB and when it was installed

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCSystemKB
```

This example returns all installed hotfixes/KBs on all of the Windows devices in the organization

### Example 2
```powershell
PS C:\> Get-JCSystemKB -SystemID 59f2s305383coo7t369ef7r2
```

This example returns all installed hotfixes/KBs on one Windows device

### Example 3
```powershell
PS C:\> Get-JCSystemKB -KB KB5000736
```

This example returns all devices that have the hotfix/KB installed

### Example 4
```powershell
PS C:\> Get-JCSystemKB -KB KB5000736 -SystemID 59f2s305383coo7t369ef7r2
```

This example checks a specific system for a specific hotfix/KB

### Example 5
```powershell
PS C:\> Get-JCSystem -hostname JC-Windows-01 | Get-JCSystemKB
```

This example uses pipeline input from Get-JCSystem to find all installed KBs for the system with the hostname JC-Windows-01

## PARAMETERS

### -KB
The KB(s) you wish to search for.
Accepts comma separated strings.
Ex: KB5006670, KB5005699, KB5000736, ...

```yaml
Type: System.String[]
Parameter Sets: SearchFilter
Aliases: hotfix_id

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemID
The System Id(s) of the system(s) you want to search for KBs.
Accepts comma separated strings.
Ex: 618972a694380d17e4145626, 63210fc54861961ac387f0ac, ...

```yaml
Type: System.String[]
Parameter Sets: SearchFilter
Aliases: system_id, id, _id

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
