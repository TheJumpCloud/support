---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Connect-JCOnline
schema: 2.0.0
---

# Connect-JCOnline

## SYNOPSIS

The Connect-JCOnline function sets the global variable $JCAPIKEY

## SYNTAX

```
Connect-JCOnline [-force] [-Select] [-Credential <String>] [[-JumpCloudApiKey] <String>]
 [[-JumpCloudOrgId] <String>] [[-JCEnvironment] <String>] [<CommonParameters>]
```

## DESCRIPTION

By calling the Connect-JCOnline function you are setting the variable $JCAPIKEY within the global scope. By setting this variable in the global scope the variable $JCAPIKEY can be reused by other functions in the JumpCloud module. If you wish to change the API key to connect to another JumpCloud org simply call the Connect-JCOnline function and enter the alternative API key.
Introduced in JumpCloud module version 1.2 the Connect-JCOnline function will also check to ensure you are running the latest version of the JumpCloud PowerShell module and offer to update the module if there is an update available.
To prevent the module update check the '-force' parameter can be used.
Use the '-JCEnvironment' parameter to specify your environment location (STANDARD or EU), STANDARD is the current default.
You can also change the location in your PowerShell Module settings by using the 'Set-JCSettingsFile' function

## EXAMPLES

### Example 1

```powershell
Connect-JCOnline lu8792c9d4y2398is1tb6h0b83ebf0e92s97t382
```

### Example 2

```powershell
Connect-JCOnline lu8792c9d4y2398is1tb6h0b83ebf0e92s97t382 -force
```

Using the "-Force" parameter the module update check is skipped. The '-Force' parameter should be used when using the JumpCloud module in scripts or other automation environments.

### Example 3

```powershell
Connect-JCOnline -JumpCloudAPIKey lu8792c9d4y2398is1tb6h0b83ebf0e92s97t382 -JumpCloudOrgID 5b5o13o06tsand0c29a0t3s6 -force
```

Providing the JumpCloudAPIKey key and the intended JumpCloudOrg ID to connect to multi tenant admins can skip the JumpCloudOrgID connection screen and directly connect to an Org.

Using the "-Force" parameter the module update check is skipped. The '-Force' parameter should be used when using the JumpCloud module in scripts or other automation environments.

### Example 4

```powershell
Connect-JCOnline -JumpCloudAPIKey eu8792c9d4y2398is1tb6h0b83ebf0e92s97t382 -JCEnvironment 'EU'
```

Use the "-JCEnvironment" parameter to change the environment location ("STANDARD" or "EU")

### Example 5

```powershell
Connect-JCOnline -Select
```

Use the "-Select" parameter to pick an API key that was previously stored in the local vault. When no keys are stored you are prompted to enter and optionally save a new key.

### Example 6

```powershell
Connect-JCOnline -Credential 'MyOrgKey'
```

Use the "-Credential" parameter to connect with a stored key by name, without being prompted to select one.

## PARAMETERS

### -Credential

The name of an API key stored in the local vault.
The value is the name the key was saved under, not the API key itself.

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

### -force

Using the "-Force" parameter the module update check is skipped.
The '-Force' parameter should be used when using the JumpCloud module in scripts or other automation environments.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JCEnvironment

Specific to JumpCloud development team to connect to staging dev environment. [More Information Here.](https://jumpcloud.com/support/jumpcloud-data-centers-login-urls-and-service-endpoints)

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: STANDARD, STAGING, EU, IN

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -JumpCloudApiKey

Please enter your JumpCloud API key.
This can be found in the JumpCloud admin console within "API Settings" accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.
This parameter is mandatory when no key is available from the vault or from the $env:JCApiKey environment variable.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -JumpCloudOrgId

Organization Id can be found in the Settings page within the admin console.
Only needed for multi tenant admins.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Select

Select an API key from the keys stored in the local vault.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
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
