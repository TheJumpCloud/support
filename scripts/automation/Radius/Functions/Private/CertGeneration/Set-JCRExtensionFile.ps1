function Set-JCRExtensionFile {
    [CmdletBinding()]
    param ()

    $extensionsDir = Join-Path $JCRScriptRoot "Extensions"
    $exts = Get-ChildItem -Path (Resolve-Path -Path $extensionsDir) -Filter "extensions-*.cnf"
    $emailDNHereString = @"
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]
C = $($global:JCRConfig.certSubjectHeader.Value.CountryCode)
ST = $($global:JCRConfig.certSubjectHeader.Value.StateCode)
L = $($global:JCRConfig.certSubjectHeader.Value.Locality)
O = $($global:JCRConfig.certSubjectHeader.Value.Organization)
OU = $($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit)
CN = $($global:JCRConfig.certSubjectHeader.Value.CommonName)

[v3_req]
keyUsage = digitalSignature
extendedKeyUsage = clientAuth
authorityInfoAccess = OCSP;URI:http://localhost:9000
"@
    $emailSANHereString = @"
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]
C = $($global:JCRConfig.certSubjectHeader.Value.CountryCode)
ST = $($global:JCRConfig.certSubjectHeader.Value.StateCode)
L = $($global:JCRConfig.certSubjectHeader.Value.Locality)
O = $($global:JCRConfig.certSubjectHeader.Value.Organization)
OU = $($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit)
CN = $($global:JCRConfig.certSubjectHeader.Value.CommonName)

[v3_req]
authorityKeyIdentifier = keyid:always,issuer:always
keyUsage = digitalSignature
extendedKeyUsage = clientAuth
#For Client cert with email in the subject alternative name
subjectAltName = email:username@domain.com
"@

    $usernameCNHereString = @"
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]
C = $($global:JCRConfig.certSubjectHeader.Value.CountryCode)
ST = $($global:JCRConfig.certSubjectHeader.Value.StateCode)
L = $($global:JCRConfig.certSubjectHeader.Value.Locality)
O = $($global:JCRConfig.certSubjectHeader.Value.Organization)
OU = $($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit)
CN = $($global:JCRConfig.certSubjectHeader.Value.CommonName)

[v3_req]
keyUsage = digitalSignature
extendedKeyUsage = clientAuth
authorityInfoAccess = OCSP;URI:http://localhost:9000
"@

    foreach ($ext in $exts) {
        Write-Host "Updating Subject Headers for $($ext.Name)"
        # replace the content of the extension file with the appropriate string based on the certType
        switch ($ext.Name) {
            'extensions-emailDN.cnf' {
                Set-Content -Path $ext.FullName -Value $emailDNHereString -NoNewline -Force
            }
            'extensions-emailSAN.cnf' {
                Set-Content -Path $ext.FullName -Value $emailDNHereString -NoNewline -Force
            }
            'extensions-usernameCN.cnf' {
                Set-Content -Path $ext.FullName -Value $usernameCNHereString -NoNewline -Force
            }
        }
    }
}