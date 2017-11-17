---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Get-JCUser

## SYNOPSIS

Returns all JumpCloud Users within a JumpCloud tenant or a single JumpCloud User using the -ByID Parameter.

## SYNTAX

### ReturnAll (Default)

```PowerShell
Get-JCUser
```

### Username

```PowerShell
Get-JCUser [-Username] <String>
```

### UserID

```PowerShell
Get-JCUser -UserID <String> [-ByID]
```

## DESCRIPTION

The Get-JCUser function returns all information describing a JumpCloud user. By default it will return all Users.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Get-JCUser
```

Returns all JumpCloud Users and the information describing these users.

### Example 2

```PowerShell
PS C:\> Get-JCUser cclemons
```

Returns the information describing the JumpCloud User with Username cclemons

### Example 3

```PowerShell
PS C:\> Get-JCUser | Where-Object account_locked -EQ $true
```

Returns all JumpCloud users that are currently in an locked out state

### Example 4

```PowerShell
PS C:\> Get-JCUser | Where-Object created -gt (Get-Date).AddDays(-7)
```

Returns all JumpCloud users that were created in the last seven days.

### Example 5

```PowerShell
PS C:\> Get-JCUser | Select-Object username, @{name='Attribute Name'; expression={$_.attributes.name}} | Where-Object 'Attribute Name' -Like *Department*
```

Returns all JumpCloud users that have an Custom Attribute with the name 'Department' using the pipeline, Parameter Binding, and a calculated property.

## PARAMETERS

### -ByID

Use the -ByID parameter when the UserID is being passed over the pipeline to the Set-JCUser function. The -ByID SwitchParameter will set the ParameterSet to 'ByID' which will increase the function speed and performance.

```yaml
Type: SwitchParameter
Parameter Sets: UserID
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserID

The _id of the User which you want to modify.

To find a JumpCloud UserID run the command:

```PowerShell
PS C:\> Get-JCUser | Select username, _id
```

The UserID will be the 24 character string populated for the _id field.

UserID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically.

```yaml
Type: String
Parameter Sets: UserID
Aliases: _id, id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username

The Username of the JumpCloud user you wish to return.

```yaml
Type: String
Parameter Sets: Username
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
