---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version:
schema: 2.0.0
---
# Get-JCSystemUser

## SYNOPSIS

Returns all JumpCloud Users associated with a JumpCloud System.

## SYNTAX

```PowerShell
Get-JCSystemUser [-SystemID] <String>
```

## DESCRIPTION

The Get-JCSystemUser function returns all the JumpCloud Users associated with the system. Users can be associated with a JumpCloud system through a direct bind, a User Group, or both. The output of the Get-JCSystemUser identifies the associations between JumpCloud Users and the system.

## EXAMPLES

### Example 1

```PowerShell
PS C:\> Get-JCSystemUser -SystemID 59f2s305383coo7t369ef7r2
```

This example returns all users associated with the JumpCloud System with a SystemID of '59f2s305383coo7t369ef7r2'

### Example 2

```PowerShell
PS C:\> Get-JCSystem | Get-JCSystemUser
```

This example returns all the JumpCloud users associated with all JumpCloud systems within a JumpCloud tenant.

### Example 3

```PowerShell
PS C:\> Get-JCSystem | Where-Object os -like *Mac* | Get-JCSystemUser
```

This example returns all the JumpCloud users associated with all JumpCloud systems within an operating system like 'Mac'.

## PARAMETERS

### -SystemID

The _id of the System which you want to query.

To find a JumpCloud SystemID run the command:

```PowerShell
PS C:\> Get-JCSystem | Select hostname, _id
```

The SystemID will be the 24 character string populated for the _id field.

SystemID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using the Get-JCSystem function before calling Get-JCSystemUser. This is shown in EXAMPLES 2 and 3.

```yaml
Type: String
Parameter Sets: (All)
Aliases: _id, id

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
