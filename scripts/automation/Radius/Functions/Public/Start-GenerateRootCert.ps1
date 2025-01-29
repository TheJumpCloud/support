Function Start-GenerateRootCert {
    [CmdletBinding(DefaultParameterSetName = 'gui')]
    param (
        # Cert Key Password
        [Parameter(HelpMessage = 'The root certificate key password', ParameterSetName = 'cli')]
        [string]
        $certKeyPassword,
        # Parameter to "New" or "Replace" the root certificate validateSet ('1', '2', '3', 'E')
        [Parameter(HelpMessage = 'Select an option to generate or replace the root certificate', ParameterSetName = 'cli')]
        [ValidateSet('New', 'Replace', 'Renew')]
        [string] $GenerateType = 'New',
        # Force invoke commands after generation
        [Parameter(HelpMessage = 'When specified, this parameter will replace certificates if they already exist on the current filesystem', ParameterSetName = 'cli')]
        [switch]
        $forceReplaceCert


    )

    $CertPath = Resolve-Path "$JCScriptRoot/Cert"
    $outKey = "$CertPath/radius_ca_key.pem"
    $outCA = "$CertPath/radius_ca_cert.pem"
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
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

    # If parameterSetname is CLI
    if ($PSCmdlet.ParameterSetName -eq 'cli') {
        switch ($GenerateType) {
            'New' {
                $selection = 1
            }
            'Replace' {
                $selection = 2
            }
            'Renew' {
                $selection = 3
            }
        }
    } else {
        Show-RootCAGenerationMenu
        $selection = Read-Host "Please make a selection"
    }



    switch ($selection) {
        # Generate new root certificate
        '1' {
            if (Test-Path -Path "$JCScriptRoot/Cert/radius_ca_cert.pem") {
                Write-Host "Root Cert already exists"
                # If the forceReplaceCert switch is set, force the generation of a new root certificate
                if (!$forceReplaceCert) {
                    if ($PSCmdlet.ParameterSetName -eq 'cli') {
                        $overwrite = Get-ResponsePrompt -message "Do you want to overwrite the existing CA Cert? This will generate a new root CA with a new serial number and user certs generated with the previous CA will no longer authenticate." -cli $true
                    } else {
                        $overwrite = Get-ResponsePrompt -message "Do you want to overwrite the existing CA Cert? This will generate a new root CA with a new serial number and user certs generated with the previous CA will no longer authenticate."
                    }

                } else {
                    $overwrite = $true
                }
                switch ($overwrite) {
                    $true {
                        Write-Host "Overwriting Root Cert..." -ForegroundColor Yellow

                        switch ($PSCmdlet.ParameterSetName) {
                            'gui' {
                                $env:certKeyPassword = ""
                                # Loop until the passwords match
                                do {
                                    # Prompt for password
                                    Write-Host "NOTE: Please save your root certificate password in a password manager" -foregroundcolor Yellow
                                    $secureCertKeyPass = Read-Host -Prompt "Enter a password for the certificate key" -AsSecureString

                                    # Reprompt for password
                                    $secureCertKeyPass2ReEntry = Read-Host -Prompt "Re-enter the password for the certificate key" -AsSecureString

                                    # Convert SecureString to plain text to validate
                                    $plainCertKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                                    $plainCertKeyPassReEntry = ConvertFrom-SecureString $secureCertKeyPass2ReEntry -AsPlainText

                                    # Validate that the passwords match
                                    if ($plainCertKeyPass -ne $plainCertKeyPassReEntry) {
                                        Write-Host "Passwords do not match. Please try again." -foregroundcolor Red
                                    } else {
                                        Write-Host "Password set successfully" -foregroundcolor Green
                                        $certKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                                    }
                                } while ($plainCertKeyPass -ne $plainCertKeyPassReEntry)
                            }
                            'cli' {
                                $certKeyPass = $certKeyPassword
                            }
                        }

                        # Copy the current root cert to the backups folder
                        try {
                            Copy-Item -Path "$CertPath/radius_ca_cert.pem" -Destination "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                        } catch {
                            Write-Error "Error backing up the current root cert. $($_.Exception.Message)"
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
                    $false {
                        return
                    }
                    'exit' {
                        return
                    }
                }

            } else {
                # Generate new root certificate
                Write-Host "Generating new CA Cert..."

                switch ($PSCmdlet.ParameterSetName) {
                    'gui' {
                        $env:certKeyPassword = ""
                        # Loop until the passwords match
                        do {
                            # Prompt for password
                            Write-Host "NOTE: Please save your root certificate password in a password manager" -foregroundcolor Yellow
                            $secureCertKeyPass = Read-Host -Prompt "Enter a password for the certificate key" -AsSecureString

                            # Reprompt for password
                            $secureCertKeyPass2ReEntry = Read-Host -Prompt "Re-enter the password for the certificate key" -AsSecureString

                            # Convert SecureString to plain text to validate
                            $plainCertKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                            $plainCertKeyPassReEntry = ConvertFrom-SecureString $secureCertKeyPass2ReEntry -AsPlainText

                            # Validate that the passwords match
                            if ($plainCertKeyPass -ne $plainCertKeyPassReEntry) {
                                Write-Host "Passwords do not match. Please try again." -foregroundcolor Red
                            } else {
                                Write-Host "Password set successfully" -foregroundcolor Green
                                $certKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                            }
                        } while ($plainCertKeyPass -ne $plainCertKeyPassReEntry)
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
                return
            }
        }
        # Replace current root certificate
        '2' {
            # Check if there is a current CA cert
            if (Test-Path -Path "$JCScriptRoot/Cert/radius_ca_cert.pem") {

                if (!$forceReplaceCert) {
                    $overwrite = Get-ResponsePrompt -message "Do you want to overwrite/replace the existing CA Cert? This will generate a new root CA with a new serial number and user certs generated with the previous CA will no longer authenticate."

                    if ($PSCmdlet.ParameterSetName -eq 'cli') {
                        $overwrite = Get-ResponsePrompt -message "Do you want to overwrite/replace the existing CA Cert? This will generate a new root CA with a new serial number and user certs generated with the previous CA will no longer authenticate." -cli $true
                    } else {
                        $overwrite = Get-ResponsePrompt -message "Do you want to overwrite/replace the existing CA Cert? This will generate a new root CA with a new serial number and user certs generated with the previous CA will no longer authenticate."
                    }
                } else {
                    $overwrite = $true
                }


                switch ($overwrite) {
                    $true {
                        Write-Host "Replacing Root Cert..." -ForegroundColor Yellow
                        switch ($PSCmdlet.ParameterSetName) {
                            'gui' {
                                $env:certKeyPassword = ""
                                # Loop until the passwords match
                                do {
                                    # Prompt for password
                                    Write-Host "NOTE: Please save your root certificate password in a password manager" -foregroundcolor Yellow
                                    $secureCertKeyPass = Read-Host -Prompt "Enter a password for the certificate key" -AsSecureString

                                    # Reprompt for password
                                    $secureCertKeyPass2ReEntry = Read-Host -Prompt "Re-enter the password for the certificate key" -AsSecureString

                                    # Convert SecureString to plain text to validate
                                    $plainCertKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                                    $plainCertKeyPassReEntry = ConvertFrom-SecureString $secureCertKeyPass2ReEntry -AsPlainText

                                    # Validate that the passwords match
                                    if ($plainCertKeyPass -ne $plainCertKeyPassReEntry) {
                                        Write-Host "Passwords do not match. Please try again." -foregroundcolor Red
                                    } else {
                                        Write-Host "Password set successfully" -foregroundcolor Green
                                        $certKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                                    }
                                } while ($plainCertKeyPass -ne $plainCertKeyPassReEntry)
                            }
                            'cli' {
                                $certKeyPass = $certKeyPassword
                            }
                        }
                        # Copy the current root cert to the backups folder
                        try {
                            Copy-Item -Path "$CertPath/radius_ca_cert.pem" -Destination "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                            Copy-Item -Path "$CertPath/radius_ca_key.pem" -Destination "$CertPath/Backups/radius_ca_key_$timestamp.pem"

                            # Zip the root cert and key files
                            $zipPath = "$CertPath/Backups/replace_radius_ca_cert_backup_$timestamp.zip"
                            Compress-Archive -Path "$CertPath/Backups/radius_ca_cert_$timestamp.pem", "$CertPath/Backups/radius_ca_key_$timestamp.pem" -DestinationPath $zipPath

                            # Remove the original files
                            Remove-Item -Path "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                            Remove-Item -Path "$CertPath/Backups/radius_ca_key_$timestamp.pem"
                        } catch {
                            Write-Error "Error backing up the current root cert and key. $($_.Exception.Message)"
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
                        return
                    }
                    $false {
                        return
                    }
                    'exit' {
                        return
                    }
                }


            } else {
                Write-Host "No Root Cert detected. Please generate a new CA Cert. Returning to main menu..." -ForegroundColor Yellow
                return
            }

        }
        '3' {
            # Check if there is a current CA cert
            if (Test-Path -Path "$JCScriptRoot/Cert/radius_ca_cert.pem") {

                # Copy the current root cert to the backups folder and zip it
                try {
                    Copy-Item -Path "$CertPath/radius_ca_cert.pem" -Destination "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                    Copy-Item -Path "$CertPath/radius_ca_key.pem" -Destination "$CertPath/Backups/radius_ca_key_$timestamp.pem"

                    # Zip the root cert and key files
                    $zipPath = "$CertPath/Backups/replace_radius_ca_cert_backup_$timestamp.zip"
                    Compress-Archive -Path "$CertPath/Backups/radius_ca_cert_$timestamp.pem", "$CertPath/Backups/radius_ca_key_$timestamp.pem" -DestinationPath $zipPath

                    # Remove the original files
                    Remove-Item -Path "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                    Remove-Item -Path "$CertPath/Backups/radius_ca_key_$timestamp.pem"
                } catch {
                    Write-Error "Error backing up the current root cert and key. $($_.Exception.Message)"
                }

                $oldCACert = "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                $csrOutPath = "$CertPath/radius_ca_cert.csr"

                $select = openssl x509 -in $oldCACert -serial -noout | Select-String -Pattern "serial=(.*)"
                $serial = $select.Matches.Groups[1].value
                Write-Host $serial

                openssl x509 -x509toreq -in $oldCACert -signkey $outKey -out $csrOutPath
                # Create path for cert2.conf
                $certConfPath = "$CertPath/radius_ca_cert2.conf"
                $string = @"
[ v3_ca ]
basicConstraints= CA:TRUE
subjectKeyIdentifier= hash
authorityKeyIdentifier= keyid:always,issuer:always
"@ | Out-File "$certConfPath"

                try {
                    # Use invoke expression to run the openssl command
                    Invoke-Expression "$JCR_OPENSSL req -x509 -newkey rsa:2048 -days $JCR_ROOT_CERT_VALIDITY_DAYS -keyout `"$outKey`" -out `"$outCA`" -passout pass:$($env:certKeyPassword) -subj /C=$($JCR_SUBJECT_HEADERS.countryCode)/ST=$($JCR_SUBJECT_HEADERS.stateCode)/L=$($JCR_SUBJECT_HEADERS.Locality)/O=$($JCR_SUBJECT_HEADERS.Organization)/OU=$($JCR_SUBJECT_HEADERS.OrganizationUnit)/CN=$($JCR_SUBJECT_HEADERS.CommonName)"

                    Invoke-Expression "$JCR_OPENSSL x509 -req -days $JCR_ROOT_CERT_VALIDITY_DAYS -in $csrOutPath -set_serial `"0x$serial`" -signkey `"$outKey`" -out `"$outCA`" -extfile $certConfPath -extensions v3_ca"
                    # openssl x509 -req -days $JCR_ROOT_CERT_VALIDITY_DAYS -in $csrOutPath -set_serial "0x$serial" -signkey $outKey -out $outCA -extfile $certConfPath -extensions v3_ca
                    # Cleanup
                    Remove-Item -Path $certConfPath
                    Remove-Item -Path $csrOutPath
                } catch {
                    # Error replacing the certificate
                    Write-Error "Error replacing the certificate. $($_.Exception.Message)"
                }
                Invoke-Expression "$JCR_OPENSSL x509 -in `"$outCA`" -enddate -noout "
            } else {
                Write-Host "No Root Cert detected. Please generate a new CA Cert. Returning to main menu..." -ForegroundColor Yellow
                return
            }
        }
        # Return to main menu
        'E' {
            return
        }
    }
}


