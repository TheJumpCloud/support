---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---

# Remove-JCAssociation

## SYNOPSIS
Remove an association between two object within the JumpCloud console.

## SYNTAX

### Default (Default)
```
Remove-JCAssociation [-InputObjectType] <String> [-TargetObjectType] <String> [<CommonParameters>]
```

### ById
```
Remove-JCAssociation [-InputObjectType] <String> [-TargetObjectType] <String> [-InputObjectId] <String>
 [-TargetObjectId] <String> [<CommonParameters>]
```

### ByName
```
Remove-JCAssociation [-InputObjectType] <String> [-TargetObjectType] <String> [-InputObjectName] <String>
 [-TargetObjectName] <String> [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-JCAssociation -InputObjectType:('radiusservers') -InputObjectId:('5c5c371704c4b477964ab4fa') -TargetObjectType:('user_group') -TargetObjectId:('59f20255c9118021fa01b80f')
```

Remove the association between the radius server "5c5c371704c4b477964ab4fa" and the user group "59f20255c9118021fa01b80f".

### Example 2
```powershell
PS C:\> New-JCAssociation -InputObjectType:('radiusservers') -InputObjectName:('RadiusServer1') -TargetObjectType:('user_group') -TargetObjectName:('All Users')
```

Remove the association between the radius server "RadiusServer1" and the user group "All Users".

## PARAMETERS

### -InputObjectId
The id of the input object.

```yaml
Type: String
Parameter Sets: ById
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputObjectName
The name of the input object.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputObjectType
The type of the input object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetObjectId
The id of the target object.

```yaml
Type: String
Parameter Sets: ById
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetObjectName
The name of the target object.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetObjectType
The type of the target object.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
