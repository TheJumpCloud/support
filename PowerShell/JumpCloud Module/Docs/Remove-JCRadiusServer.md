---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Remove-JCRadiusServer
schema: 2.0.0
---

# Remove-JCRadiusServer

## SYNOPSIS
Removes a JumpCloud radius server.

## SYNTAX

```
Remove-JCRadiusServer [-Force] [-Id] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Use this function to remove a radius servers from JumpCloud tenet.

## EXAMPLES

### Example 1
```
PS C:\> Remove-JCRadiusServer -Id:('5d6802c46eb05c5971151558')
```

Remove a radius server by Id from a JumpCloud tenet.

### Example 2
```
PS C:\> Get-JCRadiusServer -Id:('5d6802c46eb05c5971151558') | Remove-JCRadiusServer
```

Remove a radius server by Id from a JumpCloud tenet.

## PARAMETERS

### -Force
Bypass user prompts and dynamic ValidateSet.

```yaml
Type: System.Management.Automation.SwitchParameter
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
Type: System.String[]
Parameter Sets: (All)
Aliases: _id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Management.Automation.SwitchParameter
### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
