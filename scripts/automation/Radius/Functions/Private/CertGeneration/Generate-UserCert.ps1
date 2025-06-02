function Generate-UserCert {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'The type of certificate to generate, either: "EmailSAN", "EmailDN" or "UsernameCN"', Mandatory = $true)]
        [ValidateSet("EmailSAN", "EmailDn", "UsernameCN")]
        [system.String]
        $certType,
        [Parameter(Mandatory = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $rootCAKey,
        [Parameter(Mandatory = $true,
            HelpMessage = "Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $rootCA,
        [Parameter(Mandatory = $true,
            HelpMessage = "User Object Containing, id, username, email")]
        [System.Object]
        $user
    )
    begin {
        # . "$JCScriptRoot/Config.ps1"
        if (-Not (Test-Path -Path $rootCAKey)) {
            Throw "RootCAKey could not be found in project directory, have you run Generate-Cert.ps1?"
            exit 1
        }
        if (-Not (Test-Path -Path $rootCA)) {
            Throw "RootCA could not be found in project directory, have you run Generate-Cert.ps1?"
            exit 1
        }
    }
    process {
        # Set Extension Path
        $ExtensionPath = "$JCScriptRoot/Extensions/extensions-$($certType).cnf"
        # User Certificate Signing Request:
        $userCSR = "$($global:JCRConfig.radiusDirectory.value)/UserCerts/$($user.username)-cert-req.csr"
        # Set key, crt, pfx variables:
        $userKey = "$($global:JCRConfig.radiusDirectory.value)/UserCerts/$($user.username)-$($certType)-client-signed.key"
        $userCert = "$($global:JCRConfig.radiusDirectory.value)/UserCerts/$($user.username)-$($certType)-client-signed-cert.crt"
        $userPfx = "$($global:JCRConfig.radiusDirectory.value)/UserCerts/$($user.username)-client-signed.pfx"

        switch ($certType) {
            'EmailSAN' {
                # replace extension subjectAltName
                $extContent = Get-Content -Path $ExtensionPath -Raw
                $extContent -replace ("subjectAltName.*", "subjectAltName = email:$($user.email)") | Set-Content -Path $ExtensionPath -NoNewline -Force
                # Get CSR & Key
                Write-Host "[status] Get CSR & Key"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -newkey rsa:2048 -nodes -keyout `"$userKey`" -subj `"/C=$($($global:JCRConfig.certSubjectHeaderCountryCode.value))/ST=$($($global:JCRConfig.certSubjectHeaderStateCode.value))/L=$($($global:JCRConfig.certSubjectHeaderLocality.value))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeaderOrganizationUnit.value))`" -out `"$userCsr`""

                # take signing request, make cert # specify extensions requets
                Write-Host "[status] take signing request, make cert # specify extensions requets"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -req -extfile `"$ExtensionPath`" -days $JCR_USER_CERT_VALIDITY_DAYS -in `"$userCsr`" -CA `"$rootCA`" -CAkey `"$rootCAKey`" -passin pass:$($env:certKeyPassword) -CAcreateserial -out `"$userCert`" -extensions v3_req"

                # validate the cert we cant see it once it goes to pfx
                Write-Host "[status] validate the cert we cant see it once it goes to pfx"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -text -in `"$userCert`""
                # legacy needed if we take a cert like this then pass it out
                Write-Host "[status] legacy needed if we take a cert like this then pass it out"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) pkcs12 -export -out `"$userPfx`" -inkey `"$userKey`" -in `"$userCert`" -passout pass:$($JCR_USER_CERT_PASS) -legacy"
            }
            'EmailDn' {
                # Create Client cert with email in the subject distinguished name
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) genrsa -out `"$userKey`" 2048"
                # Generate User CSR
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -nodes -new -key `"$rootCAKey`" -passin pass:$($env:certKeyPassword) -out `"$userCsr`" -subj /C=$($($global:JCRConfig.certSubjectHeaderCountryCode.value))/ST=$($($global:JCRConfig.certSubjectHeaderStateCode.value))/L=$($($global:JCRConfig.certSubjectHeaderLocality.value))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeaderOrganizationUnit.value))/CN=$($($global:JCRConfig.certSubjectHeaderCommonName.value))"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -new -key `"$userKey`" -out `"$userCsr`" -config `"$ExtensionPath`" -subj `"/C=$($($global:JCRConfig.certSubjectHeaderCountryCode.value))/ST=$($($global:JCRConfig.certSubjectHeaderStateCode.value))/L=$($($global:JCRConfig.certSubjectHeaderLocality.value))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeaderOrganizationUnit.value))/CN=/emailAddress=$($user.email)`""

                # Gennerate User Cert
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -req -in `"$userCsr`" -CA `"$rootCA`" -CAkey `"$rootCAKey`" -days $JCR_USER_CERT_VALIDITY_DAYS -passin pass:$($env:certKeyPassword) -CAcreateserial -out `"$userCert`" -extfile `"$ExtensionPath`""

                # Combine key and cert to create pfx file
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) pkcs12 -export -out `"$userPfx`" -inkey `"$userKey`" -in `"$userCert`" -passout pass:$($JCR_USER_CERT_PASS) -legacy"
                # Output
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -text -in `"$userCert`""
                # Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) pkcs12 -clcerts -nokeys -in `"$userPfx`" -passin pass:$($JCR_USER_CERT_PASS)"
            }
            'UsernameCN' {
                # Create Client cert with email in the subject distinguished name
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) genrsa -out `"$userKey`" 2048"
                # Generate User CSR
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -nodes -new -key `"$rootCAKey`" -passin pass:$($env:certKeyPassword) -out `"$userCsr`" -subj /C=$($($global:JCRConfig.certSubjectHeaderCountryCode.value))/ST=$($($global:JCRConfig.certSubjectHeaderStateCode.value))/L=$($($global:JCRConfig.certSubjectHeaderLocality.value))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeaderOrganizationUnit.value))/CN=$($($global:JCRConfig.certSubjectHeaderCommonName.value))"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -new -key `"$userKey`" -out `"$userCsr`" -config `"$ExtensionPath`" -subj `"/C=$($($global:JCRConfig.certSubjectHeaderCountryCode.value))/ST=$($($global:JCRConfig.certSubjectHeaderStateCode.value))/L=$($($global:JCRConfig.certSubjectHeaderLocality.value))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeaderOrganizationUnit.value))/CN=$($user.username)`""

                # Gennerate User Cert
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -req -in `"$userCsr`" -CA `"$rootCA`" -CAkey `"$rootCAKey`" -days $JCR_USER_CERT_VALIDITY_DAYS -CAcreateserial -passin pass:$($env:certKeyPassword) -out `"$userCert`" -extfile `"$ExtensionPath`""

                # Combine key and cert to create pfx file
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) pkcs12 -export -out `"$userPfx`" -inkey `"$userKey`" -in `"$userCert`" -inkey `"$userKey`" -passout pass:$($JCR_USER_CERT_PASS) -legacy"
                # Output
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -text -in `"$userCert`""
                # Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) pkcs12 -clcerts -nokeys -in `"$userPfx`" -passin pass:$($JCR_USER_CERT_PASS)"
            }
        }

    }
    end {
        # Clean Up User Certs Directory remove non .crt files
        # `"$userCert`"Files = Get-ChildItem -Path "$($global:JCRConfig.radiusDirectory.value)/UserCerts"
        # `"$userCert`"Files | Where-Object { $_.Name -notmatch ".pfx" } | ForEach-Object {
        #     Remove-Item -path $_.fullname
        # }

    }
}
