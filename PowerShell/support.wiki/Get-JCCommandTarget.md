# Get-JCCommandTarget

## SYNOPSIS
Returns the JumpCloud systems or system groups associated with a JumpCloud command.

## SYNTAX

### Systems (Default)
```
Get-JCCommandTarget [-CommandID] <String> [<CommonParameters>]
```

### Groups
```
Get-JCCommandTarget [-CommandID] <String> [-Groups] [<CommonParameters>]
```

## DESCRIPTION
Using the CommandID parameter the Get-JCCommandTarget command will return all the systems associated with a JumpCloud command. If the '-Groups' parameter is used the Get-JCCommandTarget command will return all the system groups associated with a JumpCloud command.

## EXAMPLES

### Example 1
```powershell
Get-JCCommandTarget -CommandID '5a99777710p3690onylo3e1g'
```

Retrieves the JumpCloud system targets that are associated the JumpCloud command with the Command ID '5a99777710p3690onylo3e1g'

### Example 2
```powershell
Get-JCCommandTarget -CommandID '5a99777710p3690onylo3e1g' -Groups
```

Retrieves the JumpCloud system group targets that are associated the JumpCloud command with the Command ID '5a99777710p3690onylo3e1g'

## PARAMETERS

### -CommandID
The id value of the JumpCloud command.
Use the command 'Get-JCCommand | Select-Object _id, name' to find the "_id" value for all the JumpCloud commands in your tenant.

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

### -Groups
A switch parameter to display any System Groups associated with a command.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Groups
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
