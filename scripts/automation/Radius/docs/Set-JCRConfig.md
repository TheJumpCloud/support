---
external help file: JumpCloud.Radius-help.xml
Module Name: JumpCloud.Radius
online version: /
schema: 2.0.0
---

# Set-JCRConfig

## SYNOPSIS

This function sets the configuration for the JumpCloud Radius module, allowing you to specify various parameters such as certificate subject headers, network SSID, last update timestamp, certificate secret password, OpenSSL binary path, user certificate validity days, radius directory, CA certificate validity days, user group, certificate expiration warning days, and certificate type.

## SYNTAX

```
Set-JCRConfig [-certType <String>] [-networkSSID <String>]
 [-caCertValidityDays <Int32>] [-lastUpdate <String>] [-certSecretPass <String>]
 [-userCertValidityDays <Int32>] [-userGroup <String>] [-certExpirationWarningDays <Int32>]
 [-radiusDirectory <String>] [-openSSLBinary <String>] [-certSubjectHeader <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

This function sets the configuration for the JumpCloud Radius module. It allows you to specify various parameters such as certificate subject headers, network SSID, last update timestamp, certificate secret password, OpenSSL binary path, user certificate validity days, radius directory, CA certificate validity days, user group, certificate expiration warning days, and certificate type.

## EXAMPLES

### Example 1

```powershell
$settings = @{
    radiusDirectory                   = "/Users/username/RADIUS"
    certType                          = "UsernameCn"
    certSubjectHeader @{
        CountryCode      = "Your_Country_Code"
        StateCode        = "Your_State_Code"
        Locality         = "Your_City"
        Organization     = "Your_Organization_Name"
        OrganizationUnit = "Your_Organization_Unit"
        CommonName       = "Your_Common_Name"
    }
    certSecretPass                    = "secret1234!"
    networkSSID                       = "Your_SSID"
    userGroup                         = "5f3171a9232e1113939dd6a2"
    openSSLBinary                     = '/opt/homebrew/bin/openssl'
}

Set-JCRConfig @settings
```

This command sets the required configuration for the JumpCloud Radius module using the specified settings.

## PARAMETERS

### -caCertValidityDays

sets the caCertValidityDays config for the module

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -certExpirationWarningDays

sets the certExpirationWarningDays config for the module

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -certSecretPass

sets the certSecretPass config for the module

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

### -certSubjectHeader

sets the certSubjectHeader config for the module

```yaml
Type: System.Collections.Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -certType

sets the certType config for the module

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

### -lastUpdate

sets the lastUpdate config for the module

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

### -networkSSID

sets the networkSSID config for the module

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

### -openSSLBinary

sets the openSSLBinary config for the module

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

### -radiusDirectory

sets the radiusDirectory config for the module

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

### -userCertValidityDays

sets the userCertValidityDays config for the module

```yaml
Type: System.Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -userGroup

sets the userGroup config for the module

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
