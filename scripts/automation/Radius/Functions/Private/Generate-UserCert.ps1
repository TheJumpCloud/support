function Generate-UserCert {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("EmailSAN", "EmailDn", "UsernameCN")]
        [system.String]
        $CertType,
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
        . "$JCScriptRoot/config.ps1"
        Write-Host "$($rootCAKey) test"
        if (-Not (Test-Path -Path $rootCAKey)) {
            Throw "RootCAKey could not be found in project directory, have you run Generate-Cert.ps1?"
            exit 1
        }
        if (-Not (Test-Path -Path $rootCA)) {
            Throw "RootCA could not be found in project direcotry, have you run Generate-Cert.ps1?"
            exit 1
        }
    }
    process {
        # Set Extension Path
        $ExtensionPath = "$JCScriptRoot/Extensions/extensions-$($CertType).cnf"
        # User Certificate Signing Request:
        $userCSR = "$JCScriptRoot/UserCerts/$($user.username)-cert-req.csr"
        # Set key, crt, pfx variables:
        $userKey = "$JCScriptRoot/UserCerts/$($user.username)-$($CertType)-client-signed.key"
        $userCert = "$JCScriptRoot/UserCerts/$($user.username)-$($CertType)-client-signed-cert.crt"
        $userPfx = "$JCScriptRoot/UserCerts/$($user.username)-client-signed.pfx"

        switch ($CertType) {
            'EmailSAN' {
                # replace extension subjectAltName
                $extContent = Get-Content -Path $ExtensionPath -Raw
                $extContent -replace ("subjectAltName.*", "subjectAltName = email:$($user.email)") | Set-Content -Path $ExtensionPath -NoNewline -Force
                # Get CSR & Key
                Write-Host "[status] Get CSR & Key"
                Invoke-Expression "$opensslBinary req -newkey rsa:2048 -nodes -keyout $userKey -subj `"/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)`" -out $userCSR"

                # take signing request, make cert # specify extensions requets
                Write-Host "[status] take signing request, make cert # specify extensions requets"
                Invoke-Expression "$opensslBinary x509 -req -extfile $ExtensionPath -days $JCUSERCERTVALIDITY -in $userCSR -CA $rootCA -CAkey $rootCAKey -passin pass:$($env:certKeyPassword)) -CAcreateserial -out $userCert -extensions v3_req"

                # validate the cert we cant see it once it goes to pfx
                Write-Host "[status] validate the cert we cant see it once it goes to pfx"
                Invoke-Expression "$opensslBinary x509 -noout -text -in $userCert"
                # legacy needed if we take a cert like this then pass it out
                Write-Host "[status] legacy needed if we take a cert like this then pass it out"
                Invoke-Expression "$opensslBinary pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -passout pass:$($JCUSERCERTPASS) -legacy"
            }
            'EmailDn' {
                # Create Client cert with email in the subject distinguished name
                Invoke-Expression "$opensslBinary genrsa -out $userKey 2048"
                # Generate User CSR
                Invoke-Expression "$opensslBinary req -nodes -new -key $rootCAKey -passin pass:$($env:certKeyPassword)) -out $($userCSR) -subj /C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($subj.CommonName)"
                Invoke-Expression "$opensslBinary req -new -key $userKey -out $userCsr -config $ExtensionPath -subj `"/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=/emailAddress=$($user.email)`""

                # Gennerate User Cert
                Invoke-Expression "$opensslBinary x509 -req -in $userCsr -CA $rootCA -CAkey $rootCAKey -days $JCUSERCERTVALIDITY -passin pass:$($env:certKeyPassword) -CAcreateserial -out $userCert -extfile $ExtensionPath"

                # Combine key and cert to create pfx file
                Invoke-Expression "$opensslBinary pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -passout pass:$($JCUSERCERTPASS) -legacy"
                # Output
                Invoke-Expression "$opensslBinary x509 -noout -text -in $userCert"
                # invoke-expression "$opensslBinary pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCUSERCERTPASS)"
            }
            'UsernameCN' {
                # Create Client cert with email in the subject distinguished name
                Invoke-Expression "$opensslBinary genrsa -out $userKey 2048"
                # Generate User CSR
                Invoke-Expression "$opensslBinary req -nodes -new -key $rootCAKey -passin pass:$($env:certKeyPassword) -out $($userCSR) -subj /C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($subj.CommonName)"
                Invoke-Expression "$opensslBinary req -new -key $userKey -out $userCSR -config $ExtensionPath -subj `"/C=$($subj.countryCode)/ST=$($subj.stateCode)/L=$($subj.Locality)/O=$($JCORGID)/OU=$($subj.OrganizationUnit)/CN=$($user.username)`""

                # Gennerate User Cert
                Invoke-Expression "$opensslBinary x509 -req -in $userCSR -CA $rootCA -CAkey $rootCAKey -days $JCUSERCERTVALIDITY -CAcreateserial -passin pass:$($env:certKeyPassword) -out $userCert -extfile $ExtensionPath"

                # Combine key and cert to create pfx file
                Invoke-Expression "$opensslBinary pkcs12 -export -out $userPfx -inkey $userKey -in $userCert -inkey $userKey -passout pass:$($JCUSERCERTPASS) -legacy"
                # Output
                Invoke-Expression "$opensslBinary x509 -noout -text -in $userCert"
                # invoke-expression "$opensslBinary pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCUSERCERTPASS)"
            }
        }

    }
    end {
        # Clean Up User Certs Directory remove non .crt files
        # $userCertFiles = Get-ChildItem -Path "$JCScriptRoot/UserCerts"
        # $userCertFiles | Where-Object { $_.Name -notmatch ".pfx" } | ForEach-Object {
        #     Remove-Item -path $_.fullname
        # }

    }
}