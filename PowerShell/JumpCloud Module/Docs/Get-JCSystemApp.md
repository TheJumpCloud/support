---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Get-JCSystemApp

## SYNOPSIS
Returns the applications/programs/linux packages installed on JumpCloud managed system(s). This function queries separate system insights tables to get data for macOS/windows/linux devices.

## SYNTAX

### All (Default)
```
Get-JCSystemApp [-SystemID <String>] [-SystemOS <String>] [-SoftwareName <String>] [-SoftwareVersion <String>]
 [<CommonParameters>]
```

### Search
```
Get-JCSystemApp [-SystemID <String>] [-SystemOS <String>] [-SoftwareName <String>] [-SoftwareVersion <String>]
 [-Search] [<CommonParameters>]
```

## DESCRIPTION
Get-JCSystem app function helps admins identify what applications/programs or linux packages exist on their JumpCloud managed systems.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-JCSystemApp -SystemId '6363237ec991136ae59892e4'
```

Returns the applications installed in the system with the given -SystemId

### Example 2
```powershell
PS C:\> Get-JCSystemApp -SystemOs 'macOS'
```

Returns the 'macOS' systems and all the applications installed for each system

### Example 3
```powershell
PS C:\> Get-JCSystemApp -SystemOs 'macOS' -SoftwareName 'JumpCloud-Agent'
```

### Example 4
```powershell
PS C:\> Get-JCSystemApp -SystemOs 'macOS' -SoftwareName 'JumpCloud-Agent' -SoftwareVersion '1.12.5'
```

Returns the 'macOS' systems that have a 'JumpCloud Agent' application with the version '1.12.5'

### Example 5
```powershell
PS C:\> Get-JCSystemApp -SoftwareName 'jumpcloud-agent' -Search
```

Returns any 'jumpcloud-agent' software installed in all the os systems

## PARAMETERS

### -Search
Global search ex.
(1.1.2)

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Search
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SoftwareName
The name of the application you want to search for ex.
(JumpCloud-Agent, Slack)

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SoftwareVersion
The version of the application you want to search for ex.
(1.1.2)

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemID
The System Id of the JumpCloud system you want to search for applications

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemOS
The type (windows, mac, linux) of the JumpCloud Command you wish to search ex.
(Windows, Mac, Linux))

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: Windows, MacOs, Linux

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
