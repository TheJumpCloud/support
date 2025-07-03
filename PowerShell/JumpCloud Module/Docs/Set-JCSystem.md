---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Set-JCSystem
schema: 2.0.0
---

# Set-JCSystem

## SYNOPSIS
Updates an existing JumpCloud System

## SYNTAX

```
Set-JCSystem [-SystemID] <String> [-displayName <String>] [-description <String>]
 [-allowSshPasswordAuthentication <Boolean>] [-allowSshRootLogin <Boolean>]
 [-allowMultiFactorAuthentication <Boolean>] [-allowPublicKeyAuthentication <Boolean>]
 [-systemInsights <Boolean>] [-primarySystemUser <Object>]
 [<CommonParameters>]
```

## DESCRIPTION
The Set-JCSystem function updates an existing JumpCloud System. Common use cases are updated SSH parameters and the system displayName. Actions can be completed in bulk for multiple systems by using the pipeline and Parameter Binding to query system properties with the Get-JCSystem function and then applying updates with Set-JCSystem function.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-JCSystem -SystemID 5n0795a712704la4eve154r -displayName 'WorkStation001'
```

This example updates the displayName of the System with SystemID '5n0795a712704la4eve154r' to 'WorkStation001'. Note the JumpCloud displayName is simply a text field and does not have any system impact.

### Example 2
```powershell
PS C:\> Get-JCSystem | Where-Object os -Like *Mac* | Set-JCSystem -allowMultiFactorAuthentication $true
```

This example updates all Systems with an operating system like 'Mac' and allows for MFA login.

## PARAMETERS

### -allowMultiFactorAuthentication
A boolean $true/$false value to allow for MFA during system login.
Note this setting only applies systems running Linux or Mac.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -allowPublicKeyAuthentication
A boolean $true/$false value to allow for public key authentication.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -allowSshPasswordAuthentication
A boolean $true/$false value to allow for ssh password authentication.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -allowSshRootLogin
A boolean $true/$false value to allow for ssh root login.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -description
The system description. String param to set system description

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -displayName
The system displayName.
The displayName is set to the hostname of the system during agent installation.
When the system hostname updates the displayName does not update.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -primarySystemUser
A string value indicating a JumpCloud users email, username or userID. This will add the user to the device associations

```yaml
Type: System.Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SystemID
The _id of the System which you want to remove from JumpCloud.
The SystemID will be the 24 character string populated for the _id field.
SystemID has an Alias of _id.
This means you can leverage the PowerShell pipeline to populate this field automatically by calling a JumpCloud function that returns the SystemID.
This is shown in EXAMPLE 2

```yaml
Type: System.String
Parameter Sets: (All)
Aliases: _id, id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -systemInsights
Setting this value to $true will enable systemInsights and collect data for this system.
Setting this value to $false will disable systemInsights and data collection for the system.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

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
### System.Boolean
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
