function Validate-JCRModuleRequirements {
    $openSSLValidated = Get-OpenSSLVersion -opensslBinary $global:JCRConfig.openSSLBinary.value
    if ($openSSLValidated -eq $false) {
        throw "OpenSSL validation failed. Please check the OpenSSL path and version."
    }
}
