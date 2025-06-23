function Confirm-JCRConfig {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to pass into the function when first loading the module, the function will not write an error if this parameter is true'
        )]
        [switch]$loadModule
    )
    begin {
        if (-not $global:JCRConfig) {
            $global:JCRConfig = Get-JCRConfig -asObject
        }
        $requiredAttributesNotSet = @{}
    }

    process {
        # validate config settings
        foreach ($setting in $global:JCRConfig.PSObject.Properties) {
            $settingName = $setting.Name
            $settingValue = $setting.Value
            # check to see if the key is required and if the value is null
            switch ($settingName) {
                'openSSLBinary' {
                    if ($settingName -eq 'openSSLBinary' -and $settingValue.value -ne $null) {
                        $openSSLValid = Get-OpenSSLVersion -opensslBinary $settingValue.value
                        if (-not $openSSLValid) {
                            if (-not $loadModule) {
                                throw "The `'$settingName`' value is not a valid OpenSSL binary path.`nThe value: `'$($settingValue.value)`' is not valid."
                            } else {
                                Write-Warning "The `'$settingName`' value is not a valid OpenSSL binary path.`nThe value: `'$($settingValue.value)`' is not valid."
                            }
                        }
                    }
                }
                'certSubjectHeader' {
                    # check if the cert subject header is set
                    if ($settingValue.value -eq $null) {
                        $requiredAttributesNotSet += @{ $settingName = $settingValue.placeholder }
                    } else {
                        # check if the hashtable has all required keys
                        $requiredKeys = @('CountryCode', 'StateCode', 'Locality', 'Organization', 'OrganizationUnit', 'CommonName')
                        foreach ($key in $requiredKeys) {
                            if ($global:JCRConfig.certSubjectHeader.Value.$($key) -eq $null) {
                                $requiredAttributesNotSet += @{ $settingName = $settingValue.placeholder }
                                break
                            }
                            # validate that the value has no spaces, throw
                            if ($global:JCRConfig.certSubjectHeader.Value.$($key) -match '\s') {
                                if (-not $loadModule) {
                                    throw "The `'$settingName`' value contains spaces.`nThe value: `'$($global:JCRConfig.certSubjectHeader.Value.$($key))`' for `'$key`' cannot contain spaces."
                                } else {
                                    Write-Warning "The `'$settingName`' value contains spaces.`nThe value: `'$($global:JCRConfig.certSubjectHeader.Value.$($key))`' for `'$key`' cannot contain spaces."

                                }
                            }
                        }
                    }
                }
                Default {
                    if ($settingValue.required -eq $true -and $settingValue.value -eq $null) {
                        $requiredAttributesNotSet += @{ $settingName = $settingValue.placeholder }
                    }
                }
            }
        }
    }


    end {
        if ($requiredAttributesNotSet.count -gt 0) {
            $requiredAttributesNotSet = $requiredAttributesNotSet | Sort-Object
            $requiredAttributesNotSetString = $requiredAttributesNotSet.Keys -join ","
            Write-Warning @"
There are required settings for this module that have not yet been set with the Set-JCRConfig function.
The module requires you set: $requiredAttributesNotSetString

To set these run the following command (changing the default settings for your own organization):

`$settings = @{
$($requiredAttributesNotSet.GetEnumerator() | ForEach-Object {
"`t$($_.Key) = $($_.Value)" + [System.Environment]::NewLine
})}

Set-JCRConfig @settings

"@
            if (-not $loadModule) {
                throw "Please set these variables with the Set-JCRConfig cmdlet"
            } else {
                Write-Warning "Please set these variables with the Set-JCRConfig cmdlet"
            }
        }
    }
}