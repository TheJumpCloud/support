Function Start-GenerateRootCert {
    [CmdletBinding(DefaultParameterSetName = 'gui')]
    param (
        # Cert Key Password
        [Parameter(HelpMessage = 'The root certificate key password', ParameterSetName = 'cli')]
        [string]
        $certKeyPassword
    )
    # this script will generate a Self Signed CA (root cert) to be imported on the
    # Radius CBA-BYO Authentication UI

    # Edit the variables in Config.ps1 before running this script
    . "$JCScriptRoot/Config.ps1"

    if ( ([System.String]::IsNullOrEmpty($JCORGID)) -Or ($JCORGID.Length -ne 24) ) {
        throw "OrganizationID not specified, please update Config.ps1"
    }

    ################################################################################
    # Do Not Edit Below:
    ################################################################################
    Set-Location $JCScriptRoot

    # REM Generate Root Server Private Key and server certificate (self signed as CA)
    Write-Host "Generating Self Signed Root CA Certificate"
    if (Test-Path -Path "$JCScriptRoot/Cert") {
        Write-Host "Cert Path Exists"
    } else {
        Write-Host "Creating Cert Path"
        New-Item -ItemType Directory -Path "$JCScriptRoot/Cert"
    }
    # Check if cert exists, prompt user to overwrite with a while loop
    if (Test-Path -Path "$JCScriptRoot/Cert/radius_ca_cert.pem") {
        Write-Host "CA Cert already exists"
        switch ($PSCmdlet.ParameterSetName) {
            'gui' {
                $overwrite = Get-ResponsePrompt -message "Do you want to overwrite the existing CA Cert?"
                switch ($overwrite) {
                    $true {
                        continue
                    }
                    $false {
                        return
                    }
                    'exit' {
                        return
                    }
                }
            }
            'cli' {

            }
        }
    }
    $CertPath = Resolve-Path "$JCScriptRoot/Cert"
    $outKey = "$CertPath/radius_ca_key.pem"
    $outCA = "$CertPath/radius_ca_cert.pem"
    # Ask the user to enter a pass phrase for the CA key:
    # Clear the pass phrase from the env:
    switch ($PSCmdlet.ParameterSetName) {
        'gui' {
            $env:certKeyPassword = ""
            # Loop until the passwords match
            do {
                # Prompt for password
                $secureCertKeyPass = Read-Host -Prompt "Enter a password for the certificate key" -AsSecureString

                # Reprompt for password
                $secureCertKeyPass2 = Read-Host -Prompt "Re-enter the password for the certificate key" -AsSecureString

                # Convert SecureString to plain text to validate
                $plainCertKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                Write-Host "plainCertKeyPass: $plainCertKeyPass"
                $plainCertKeyPass2 = ConvertFrom-SecureString $secureCertKeyPass2 -AsPlainText
                Write-Host "plainCertKeyPass2: $plainCertKeyPass2"

                # Validate that the passwords match
                if ($plainCertKeyPass -ne $plainCertKeyPass2) {
                    Write-Host "Passwords do not match. Please try again." -foregroundcolor Red
                } else {
                    Write-Host "Password set successfully" -foregroundcolor Green
                    $certKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                    Write-Host "certKeyPass: $certKeyPass"
                }
            } while ($plainCertKeyPass -ne $plainCertKeyPass2)
        }
        'cli' {
            $certKeyPass = $certKeyPassword
        }
    }
    # Save the pass phrase in the env:
    $env:certKeyPassword = $certKeyPass
    Invoke-Expression "$JCR_OPENSSL req -x509 -newkey rsa:2048 -days $JCR_ROOT_CERT_VALIDITY_DAYS -keyout `"$outKey`" -out `"$outCA`" -passout pass:$($env:certKeyPassword) -subj /C=$($JCR_SUBJECT_HEADERS.countryCode)/ST=$($JCR_SUBJECT_HEADERS.stateCode)/L=$($JCR_SUBJECT_HEADERS.Locality)/O=$($JCR_SUBJECT_HEADERS.Organization)/OU=$($JCR_SUBJECT_HEADERS.OrganizationUnit)/CN=$($JCR_SUBJECT_HEADERS.CommonName)"
    # REM PEM pass phrase: myorgpass
    Invoke-Expression "$JCR_OPENSSL x509 -in `"$outCA`" -noout -text"
    # openssl x509 -in ca-cert.pem -noout -text
    # Update Extensions Distinguished Names:
    $exts = Get-ChildItem -Path "$JCScriptRoot/Extensions"
    foreach ($ext in $exts) {
        Write-Host "Updating Subject Headers for $($ext.Name)"
        $extContent = Get-Content -Path $ext.FullName -Raw
        $reqDistinguishedName = @"
[req_distinguished_name]
C = $($JCR_SUBJECT_HEADERS.countryCode)
ST = $($JCR_SUBJECT_HEADERS.stateCode)
L = $($JCR_SUBJECT_HEADERS.Locality)
O = $($JCR_SUBJECT_HEADERS.Organization)
OU = $($JCR_SUBJECT_HEADERS.OrganizationUnit)
CN = $($JCR_SUBJECT_HEADERS.CommonName)

"@
        $extContent -Replace ("\[req_distinguished_name\][\s\S]*(?=\[v3_req\])", $reqDistinguishedName) | Set-Content -Path $ext.FullName -NoNewline -Force
    }
}
