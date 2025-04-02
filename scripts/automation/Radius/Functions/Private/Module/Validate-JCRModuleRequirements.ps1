function Validate-JCRModuleRequirements {
    $openSSLValidated = Get-OpenSSLVersion -opensslBinary $JCR_OPENSSL
    if ($openSSLValidated -eq $false) {
        throw "OpenSSL validation failed. Please check the OpenSSL path and version."
    }
}
