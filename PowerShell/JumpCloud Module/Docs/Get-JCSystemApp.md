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
Get-JCSystemApp [-SystemID <String>] [-SystemOS <String>] [-name <String>] [-version <String>]
 [<CommonParameters>]
```

### Search
```
Get-JCSystemApp [-SystemID <String>] [-SystemOS <String>] [-name <String>] [-version <String>] [-Search]
 [<CommonParameters>]
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
PS C:\> Get-JCSystemApp -SystemOs 'macOS' -Name 'Jumpcloud'
```

### Example 4

```powershell
PS C:\> Get-JCSystemApp -SystemOs 'macOS' -Name 'Jumpcloud' -Version 'v1.16.2'
```

Returns the 'macOS' systems that have a 'Jumpcloud' tray application with the version 'v1.16.2'

### Example 5

```powershell
PS C:\> Get-JCSystemApp -Name 'jumpcloud' -Search
```

Returns any 'jumpcloud' software installed in all the OS systems (Windows/Linux/macOS)

## PARAMETERS

### -name

The name of the application you want to search for ex. (Jumpcloud, Slack). Name will always query the "name" property from system insights. Note, for macOS systems, ".app" will be applied. This field is case sensitive.

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

### -Search

Search for a specific application by from all systems in the org ex.
(Get-JCSystemApp -Search -Name "Jumpcloud")
THIS PARAMETER DOES NOT TAKE INPUT

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
(Windows, macOs, Linux))

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: Windows, macOS, Linux

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -version

The version of the application you want to search for ex. 1.1.2. Note: on Windows/ Linux devices, this parameter will filter on the 'version' property, for macOS applications this parameter will filter on the 'bundleShortVersion' property.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
