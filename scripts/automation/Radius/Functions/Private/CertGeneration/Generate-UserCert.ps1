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
        $extensionsDir = Join-Path $JCRScriptRoot "Extensions"
        $expectedFile = "extensions-$certType.cnf"
        $ExtensionPath = Get-ChildItem -Path $extensionsDir -Filter "extensions-*.cnf" | Where-Object { $_.Name -ieq $expectedFile } | Select-Object -First 1

        if (-not $ExtensionPath) {
            Throw "Extension file '$expectedFile' not found in '$extensionsDir'."
        }
        $ExtensionPath = $ExtensionPath.FullName

        # User Certificate Signing Request:
        $userCertsDir = Join-Path $global:JCRConfig.radiusDirectory.value "UserCerts"
        $userCSR = Get-CaseInsensitiveFile -Directory $userCertsDir -FileName "$($user.username)-cert-req.csr"
        $userKey = Get-CaseInsensitiveFile -Directory $userCertsDir -FileName "$($user.username)-$($certType)-client-signed.key"
        $userCert = Get-CaseInsensitiveFile -Directory $userCertsDir -FileName "$($user.username)-$($certType)-client-signed-cert.crt"
        $userPfx = Get-CaseInsensitiveFile -Directory $userCertsDir -FileName "$($user.username)-client-signed.pfx"


        switch ($certType) {
            'EmailSAN' {
                # replace extension subjectAltName
                $extContent = Get-Content -Path $ExtensionPath -Raw
                $extContent -replace ("subjectAltName.*", "subjectAltName = email:$($user.email)") | Set-Content -Path $ExtensionPath -NoNewline -Force
                # Get CSR & Key
                Write-Host "[status] Get CSR & Key"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -newkey rsa:2048 -nodes -keyout `"$userKey`" -subj `"/C=$($($global:JCRConfig.certSubjectHeader.Value.CountryCode))/ST=$($($global:JCRConfig.certSubjectHeader.Value.StateCode))/L=$($($global:JCRConfig.certSubjectHeader.Value.Locality))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit))`" -out `"$userCsr`""

                # take signing request, make cert # specify extensions requets
                Write-Host "[status] take signing request, make cert # specify extensions requets"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -req -extfile `"$ExtensionPath`" -days $($global:JCRConfig.userCertValidityDays.value) -in `"$userCsr`" -CA `"$rootCA`" -CAkey `"$rootCAKey`" -passin pass:$($env:certKeyPassword) -CAcreateserial -out `"$userCert`" -extensions v3_req"

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
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -nodes -new -key `"$rootCAKey`" -passin pass:$($env:certKeyPassword) -out `"$userCsr`" -subj /C=$($($global:JCRConfig.certSubjectHeader.Value.CountryCode))/ST=$($($global:JCRConfig.certSubjectHeader.Value.StateCode))/L=$($($global:JCRConfig.certSubjectHeader.Value.Locality))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit))/CN=$($($global:JCRConfig.certSubjectHeader.Value.CommonName))"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -new -key `"$userKey`" -out `"$userCsr`" -config `"$ExtensionPath`" -subj `"/C=$($($global:JCRConfig.certSubjectHeader.Value.CountryCode))/ST=$($($global:JCRConfig.certSubjectHeader.Value.StateCode))/L=$($($global:JCRConfig.certSubjectHeader.Value.Locality))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit))/CN=/emailAddress=$($user.email)`""

                # Gennerate User Cert
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -req -in `"$userCsr`" -CA `"$rootCA`" -CAkey `"$rootCAKey`" -days $($global:JCRConfig.userCertValidityDays.value) -passin pass:$($env:certKeyPassword) -CAcreateserial -out `"$userCert`" -extfile `"$ExtensionPath`""

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
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -nodes -new -key `"$rootCAKey`" -passin pass:$($env:certKeyPassword) -out `"$userCsr`" -subj /C=$($($global:JCRConfig.certSubjectHeader.Value.CountryCode))/ST=$($($global:JCRConfig.certSubjectHeader.Value.StateCode))/L=$($($global:JCRConfig.certSubjectHeader.Value.Locality))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit))/CN=$($($global:JCRConfig.certSubjectHeader.Value.CommonName))"
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -new -key `"$userKey`" -out `"$userCsr`" -config `"$ExtensionPath`" -subj `"/C=$($($global:JCRConfig.certSubjectHeader.Value.CountryCode))/ST=$($($global:JCRConfig.certSubjectHeader.Value.StateCode))/L=$($($global:JCRConfig.certSubjectHeader.Value.Locality))/O=$($JCORGID)/OU=$($($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit))/CN=$($user.username)`""

                # Gennerate User Cert
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -req -in `"$userCsr`" -CA `"$rootCA`" -CAkey `"$rootCAKey`" -days $($global:JCRConfig.userCertValidityDays.value) -CAcreateserial -passin pass:$($env:certKeyPassword) -out `"$userCert`" -extfile `"$ExtensionPath`""

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
