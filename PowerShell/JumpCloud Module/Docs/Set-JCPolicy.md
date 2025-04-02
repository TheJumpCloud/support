---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# Set-JCPolicy

## SYNOPSIS

Set-JCPolicy updates existing JumpCloud Policies in an organization by PolicyID or PolicyName. JumpCloud policies can be updated in three different ways. The New/Set-JCPolicy functions each have a dynamic set of parameters specific to each policy template, this dynamic set of parameters is generated after specifying a valid TemplateID or PolicyName. New/Set-JCPolicy functions can also be set through a valid `value` parameter which is specific to each template policy. Lastly, New/Set-JCPolicy functions can be set through a guided interface.

PolicyIDs or PolicyNames are required to identify which JumpCloud Policy to be built. TemplateIDs can be found by looking at the JumpCloud Console URL on existing policies or running `Get-JCpolicy -Name "Some Policy Name` to get the policy by ID. PolicyNames can be specified if you know the name of a policy you wish to update or by running `Get-JCpolicy -Name "Some Policy Name` to get the policy by Name

Set-JCPolicy can display the available parameters per policy if a `PolicyName` or `PolicyID` is specified. Tab actions display the available dynamic parameters available per function. For example, `Set-JCPolicy -PolicyName "macOS - Login Window Policy" -*tab*` where the tab key is pressed in place of `*tab*`, would display available parameters specific to the `macOS - Login Window Policy` policy. Dynamic parameters for policies are displayed after the `Name` and `Values` parameters, and are generally camelCase strings like `LoginwindowText`.

## SYNTAX

### ByID (Default)
```
Set-JCPolicy -PolicyID <String> [-NewName <String>] [-Values <Object[]>] [-Notes <String>]
 [<CommonParameters>]
```

### ByName
```
Set-JCPolicy -PolicyName <String> [-NewName <String>] [-Values <Object[]>] [-Notes <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Set-JCPolicy allows for the update of existing JumpCloud Policies via the JumpCloud PowerShell Module.

## EXAMPLES

### Example 1

```powershell
PS C:\>  Set-JCPolicy -PolicyName "macOS - Login Window Policy" -LoginwindowText "Welcome to JumpCloud"
```

This would update the policy named `macOS - Login Window Policy` with the login window text set to `Welcome to JumpCloud`.

### Example 2

```powershell
PS C:\>  Set-JCPolicy -PolicyID 643980a06ab0390001b5977c -LoginwindowText "Welcome to JumpCloud" -NewName "macOS Login Window Policy Welcome"
```

This would update the macOS Login Window Text policy (the id of that policy is `643980a06ab0390001b5977c`) with the login window text set to `Welcome to JumpCloud` the policy would be renamed to `macOS Login Window Policy Welcome`.

### Example 3

```powershell
PS C:\>  Set-JCPolicy -PolicyName "macOS - Login Window Policy"

fieldIndex field                              value                helpMessage
---------- -----                              -----                -----------
         0 Set Text Displayed At Login Window Welcome to JumpCloud Optional text to display on the login window.

Please enter the string value for the LoginwindowText setting: Welcome To JumpCloud!!!
```

This would update the policy named `macOS - Login Window Policy` interactively. In the example above, the interactive output is displayed. Pressing Enter after typing `Welcome To JumpCloud!!!` would update the policy with the login text changed from `Welcome To JumpCloud` to `Welcome To JumpCloud!!!`.

### Example 4

```powershell
PS C:\>  $policyValue = @{'configFieldID'='5ade0cfd1f24754c6c5dc9f3';'value'='Welcome To JumpCloud'}
PS C:\>  Set-JCPolicy -PolicyName "macOS - Login Window Policy" -Values $policyValue
```

This would update the policy named `macOS - Login Window Policy` with the login window text set to `Welcome to JumpCloud`. The policy values are set using the `values` parameter. Objects passed into the `values` parameter set must contain the `value` for the policy config field and a `configFieldID`. To get a policy value object, search for any existing policy using `Get-JCPolicy` the `values` object returned from that cmdlet will contain the config fields required to build new policies or edit existing ones.

### Example 5

```powershell
PS C:\>  Set-JCPolicy -PolicyName "Windows - Imported Custom Registry Settings" -RegistryFile "/path/to/registryFile.reg"
```

This command would append the registry policy's existing values with the imported set of .Reg keys specified by the "RegistryFile" parameter. .Reg files will be converted and uploaded to the JumpCloud policy as long as they contain "DWORD", "EXPAND_SZ", "MULTI_SZ", "SZ" or "QWORD" type data.

### Example 6

```powershell
PS C:\>  Set-JCPolicy -PolicyName "Windows - Imported Custom Registry Settings" -RegistryFile "/path/to/registryFile.reg" -RegistryOverwrite
```

This command would overwrite the registry policy's existing values with the imported set of .Reg keys specified by the "RegistryFile" parameter. .Reg files will be converted and uploaded to the JumpCloud policy as long as they contain "DWORD", "EXPAND_SZ", "MULTI_SZ", "SZ" or "QWORD" type data.

### Example 7

```powershell
PS C:\>  Set-JCPolicy -PolicyName "Windows - Custom OMA MDM Policy" -uriList '(@( @{format = "string"; uri = "./Vendor/MSFT/Policy/Config/DeviceLock/EnforceLockScreenAndLogonImage; value = "pathToImage" }, @{format = "int"; uri = "./Device/Vendor/MSFT/Policy/Config/DeviceLock/AccountLockoutPolicy"; value = "2" } ))'
```

This command modifies the existing JumpCloud policy named "Windows - Custom OMA MDM Policy". It updates the policy's OMA-URI settings using the -uriList parameter. The EnforceLockScreenAndLogonImage setting, a string, remains set to "pathToImage". The AccountLockoutPolicy setting, an integer, is updated from its previous value to "2", effectively changing the account lockout policy configuration.

## PARAMETERS

### -NewName

The new name to set on the existing JumpCloud Policy

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

### -Notes
The notes to set on the existing JumpCloud Policy.

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

### -PolicyID

The ID of the existing JumpCloud Policy to modify

```yaml
Type: System.String
Parameter Sets: ByID
Aliases: id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PolicyName

The name of the existing JumpCloud Poliicy template to modify

```yaml
Type: System.String
Parameter Sets: ByName
Aliases: name

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Values

The values object either built manually or passed in through Get-JCPolicy

```yaml
Type: System.Object[]
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
### System.Object[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
