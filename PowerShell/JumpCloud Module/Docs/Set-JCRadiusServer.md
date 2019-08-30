---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Set-JCRadiusServer
schema: 2.0.0
---

# Set-JCRadiusServer

## SYNOPSIS
Updates a JumpCloud radius server.

## SYNTAX

### ById (Default)
```
Set-JCRadiusServer [-Force] [-Id] <String[]> [[-newName] <String>] [[-networkSourceIp] <String>]
 [[-sharedSecret] <String>] [<CommonParameters>]
```

### ByName
```
Set-JCRadiusServer [-Force] [-Name] <String[]> [[-newName] <String>] [[-networkSourceIp] <String>]
 [[-sharedSecret] <String>] [<CommonParameters>]
```

### ByValue
```
Set-JCRadiusServer [-Force] [[-newName] <String>] [[-networkSourceIp] <String>] [[-sharedSecret] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Use this function to update a radius server in a JumpCloud tenet.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-JCRadiusServer -Id:('5d6802c46eb05c5971151558') -newName:('RadiusServer2') -networkSourceIp:('111.111.111.111') -sharedSecret:('dUtU9FDvPc8Wdvoc#jKmZr7aJSXv5pR')
```

Update a radius server by Id from a JumpCloud tenet.

### Example 2
```powershell
PS C:\> Set-JCRadiusServer -Name:('RadiusServer1') -newName:('RadiusServer2') -networkSourceIp:('111.111.111.111') -sharedSecret:('MzQDUuDhqhSgMoryi#fNpB2wEpvu8U1')
```

Update a radius server by Name from a JumpCloud tenet.

### Example 3
```powershell
PS C:\> Get-JCRadiusServer -Id:('5d6802c46eb05c5971151558') | Set-JCRadiusServer -networkSourceIp:('111.111.111.111')
```

Update the networkSourceIp of a radius server by Id from a JumpCloud tenet.

## PARAMETERS

### -Force
Bypass user prompts and dynamic ValidateSet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Id
The unique id of the object.

```yaml
Type: String[]
Parameter Sets: ById
Aliases: _id

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
The name of the object.

```yaml
Type: String[]
Parameter Sets: ByName
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -networkSourceIp
The ip of the new Radius Server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -newName
The new name of the Radius Server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -sharedSecret
The shared secret for the new Radius Server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Management.Automation.SwitchParameter

### System.String[]

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
