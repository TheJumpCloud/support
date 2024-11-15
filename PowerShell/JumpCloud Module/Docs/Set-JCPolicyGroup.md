---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Set-JCPolicyGroup

## SYNOPSIS

This endpoint allows you to do a full update of the Policy Group.

## SYNTAX

### ByName
```
Set-JCPolicyGroup -Name <String> [-NewName <String>] [-Description <String>]
 [<CommonParameters>]
```

### ByID
```
Set-JCPolicyGroup -PolicyGroupID <String> [-NewName <String>] [-Description <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Set-JCPolicyGroup sets a policy group's description and "newName"

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-JCPolicyGroup -Name "Policy Group Name" -NewName "New Policy Group"
```

Sets the policy group with name: "Policy Group Name" to: "New Policy Group"

### Example 2

```powershell
PS C:\> Set-JCPolicyGroup -PolicyGroupID "671aa7190133c4000119e158" -NewName "New Policy Group"
```

Sets the policy group with id: "671aa7190133c4000119e158" to: "New Policy Group"

### Example 2

```powershell
PS C:\> Set-JCPolicyGroup -PolicyGroupID "671aa7190133c4000119e158" -Description "A group of Windows policies"
```

Sets the policy group with id: "671aa7190133c4000119e158" and it's description to: "A group of Windows policies"

## PARAMETERS

### -Description

The Description of the JumpCloud policy group you wish to set.

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

### -Name

The Name of the JumpCloud policy group you wish to set.

```yaml
Type: System.String
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NewName

The new name to set on the existing JumpCloud policy group. If left unspecified, the cmdlet will not rename the existing policy group.

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

### -PolicyGroupID

The Id of the JumpCloud policy group you wish to set.

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: _id, id

Required: True
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
