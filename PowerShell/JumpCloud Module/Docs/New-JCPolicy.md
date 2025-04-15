---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/
schema: 2.0.0
---

# New-JCPolicy

## SYNOPSIS

New-JCPolicy creates new JumpCloud Policies in an organization by TemplateID or TemplateNames. JumpCloud policies can be created in three different ways. The New/Set-JCPolicy functions each have a dynamic set of parameters specific to each policy template, this dynamic set of parameters is generated after specifying a valid TemplateID or TemplateName. New/Set-JCPolicy functions can also be set through a valid `value` parameter which is specific to each template policy. Lastly, New/Set-JCPolicy functions can be set through a guided interface.

TemplateIDs or TemplateNames are required to identify which JumpCloud Policy to be built. TemplateIDs can be found by looking at the JumpCloud Console URL while creating new policies. TemplateNames can be dynamically pulled in while using the `New-JCPolicy` function by typing: `New-JCPolicy -TemplateName *tab*` where the tab key is pressed in place of `*tab*`, if prompted, press 'y' to list all policies. Policies by operating system can be 'searched' by typing `darwin` (macOS), `windows`, `linux`, `ios`. For example, `New-JCPolicy -TemplateName darwin*tab*` where the tab key is pressed in place of `*tab*`, the list of available macOS policies would then be displayed and can be autocompleted through further tab presses.

At a minimum to display the dynamic set of parameters per template, the `TemplateID` or `TemplateName` must be specified. Tab actions display the available dynamic parameters available per function. For example, `New-JCPolicy -TemplateName darwin_Login_Window_Text -*tab*` where the tab key is pressed in place of `*tab*`, would display available parameters specific to the `darwin_Login_Window_Text` policy. Dynamic parameters for templates are displayed after the `Name` and `Values` parameters, and are generally camelCase strings like `LoginwindowText`.

## SYNTAX

### ByID (Default)
```
New-JCPolicy -TemplateID <String> [-Name <String>] [-Values <Object[]>] [-Notes <String>]
 [<CommonParameters>]
```

### ByName
```
New-JCPolicy -TemplateName <String> [-Name <String>] [-Values <Object[]>] [-Notes <String>]
 [<CommonParameters>]
```

## DESCRIPTION

New-JCPolicy allows for the creation of new JumpCloud Policies via the JumpCloud PowerShell Module.

## EXAMPLES

### Example 1

```powershell
PS C:\>  New-JCPolicy -TemplateName darwin_Login_Window_Text -LoginwindowText "Welcome to JumpCloud" -Name "macOS - Login Window Policy"
```

This would create a new macOS Login Window Text policy with the login window text set to `Welcome to JumpCloud` the policy would be named `macOS - Login Window Policy`

### Example 2

```powershell
PS C:\>  New-JCPolicy -TemplateID 5ade0cfd1f24754c6c5dc9f2 -LoginwindowText "Welcome to JumpCloud"
```

This would create a new macOS Login Window Text policy (the id of that template is `5ade0cfd1f24754c6c5dc9f2`) with the login window text set to `Welcome to JumpCloud` the policy would be created with the default policy name.

### Example 3

```powershell
PS C:\>  New-JCPolicy -TemplateName darwin_Login_Window_Text

fieldIndex field                              value helpMessage
---------- -----                              ----- -----------
         0 Set Text Displayed At Login Window       Optional text to display on the login window.

Please enter the string value for the LoginwindowText setting: Welcome To JumpCloud
```

This would create a new macOS Login Window Text policy and being the guided process to interactively edit the policy. In the example above, the interactive output is displayed. Pressing Enter after typing `Welcome To JumpCloud` would create the policy with the default policy name.

### Example 4

```powershell
PS C:\>  $policyValue = @{'configFieldID'='5ade0cfd1f24754c6c5dc9f3';'value'='Welcome To JumpCloud'}
PS C:\>  New-JCPolicy -TemplateName darwin_Login_Window_Text -Values $policyValue -Name "macOS - Login Window Policy"
```

This would create a new macOS Login Window Text policy with the login window text set to `Welcome to JumpCloud` with the `macOS - Login Window Policy` name. The policy values are set using the `values` parameter. Objects passed into the `values` parameter set must contain the `value` for the policy config field and a `configFieldID`. To get a policy value object, search for any existing policy using `Get-JCPolicy` the `values` object returned from that cmdlet will contain the config fields required to build new policies or edit existing ones.

### Example 5

```PowerShell
PS C:\>  New-JCPolicy -TemplateName windows_Advanced:_Custom_Registry_Keys -Name "Windows - Imported Custom Registry Settings" -RegistryFile "/path/to/registryFile.reg"
```

This command would create a new Windows Custom Registry Policy named "Windows - Imported Custom Registry Settings" and populate the values from a registry file. .Reg registry files can be passed into New-JCPolicy as long as the TemplateName is specified with the corresponding "windows_Advanced:\_Custom_Registry_Keys" template. .Reg files will be converted and uploaded to the JumpCloud policy as long as they contain "DWORD", "EXPAND_SZ", "MULTI_SZ", "SZ" or "QWORD" type data.

## PARAMETERS

### -Name

The name of the policy to create

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
The notes of the policy to create.

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

### -TemplateID

The ID of the policy template to create as a new JumpCloud Policy

```yaml
Type: System.String
Parameter Sets: ByID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TemplateName

The Name of the policy template to create as a new JumpCloud Policy

```yaml
Type: System.String
Parameter Sets: ByName
Aliases:

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
