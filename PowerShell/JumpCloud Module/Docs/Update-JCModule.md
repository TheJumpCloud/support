---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Update-JCModule
schema: 2.0.0
---

# Update-JCModule

## SYNOPSIS
Running this function will trigger the update of the JumpCloud PowerShell module.

## SYNTAX

```
Update-JCModule [[-ReleaseNotesURL] <Object>] [<CommonParameters>]
```

## DESCRIPTION
The Update-JCModule function will check if there is an available update on the PowerShell gallery and if there is it will ask the user if they want to install it.

## EXAMPLES

### Example 1
```powershell
Update-JCModule
```

Running the function will trigger the update process.

## PARAMETERS

### -ReleaseNotesURL
Url to the release notes. Leave default value unless testing.

```yaml
Type: Object
Parameter Sets: (All)
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

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
