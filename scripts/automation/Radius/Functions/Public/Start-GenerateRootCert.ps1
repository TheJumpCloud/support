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
        [string] $generateType = 'New',
        # Force invoke commands after generation
        [Parameter(HelpMessage = 'When specified, this parameter will replace certificates if they already exist on the current filesystem', ParameterSetName = 'cli')]
        [switch]
        $force


    )

    if ($Global:JCRSettings.sessionImport -eq $false) {
        Get-JCRGlobalVars
        $Global:JCRSettings.sessionImport = $true
    }


    # this script will generate a Self Signed CA (root cert) to be imported on the
    # Radius CBA-BYO Authentication UI

    ################################################################################
    # Do Not Edit Below:
    ################################################################################
    # Set-Location $JCRScriptRoot

    # REM Generate Root Server Private Key and server certificate (self signed as CA)
    Write-Host "Generating Self Signed Root CA Certificate"
    if (Test-Path -Path "$($global:JCRConfig.radiusDirectory.value)/Cert") {
        Write-Host "Cert Path Exists"
    } else {
        Write-Host "Creating Cert Path"
        New-Item -ItemType Directory -Path "$($global:JCRConfig.radiusDirectory.value)/Cert"
    }

    # If cert backup folder does not exist, create it
    if (Test-Path -Path "$($global:JCRConfig.radiusDirectory.value)/Cert/Backups") {
        Write-Host "Backup Path Exists"
    } else {
        Write-Host "Creating Backup Path"
        New-Item -ItemType Directory -Path "$($global:JCRConfig.radiusDirectory.value)/Cert/Backups"
    }

    $CertPath = Resolve-Path "$($global:JCRConfig.radiusDirectory.value)/Cert"
    $outKey = "$CertPath/radius_ca_key.pem"
    $outCA = "$CertPath/radius_ca_cert.pem"
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"

    # If parameterSetName is CLI
    if ($PSCmdlet.ParameterSetName -eq 'cli') {
        switch ($GenerateType) {
            'New' {
                $selection = 1
            }
            'Replace' {
                # Same functionality as 'New'
                $selection = 1
            }
            'Renew' {
                $selection = 2
            }
        }
    } else {
        Show-RootCAGenerationMenu
        $selection = Read-Host "Please make a selection"
    }



    switch ($selection) {
        # Generate new root certificate
        '1' {
            if (Test-Path -Path "$($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem") {
                Write-Host "Root Cert already exists"
                # If the force switch is set, force the generation of a new root certificate
                if (!$force) {
                    if ($PSCmdlet.ParameterSetName -eq 'cli') {
                        $overwritePrompt = Get-ResponsePrompt -message "Do you want to overwrite the existing CA Cert? This will generate a new root CA with a new serial number and user certs generated with the previous CA will no longer authenticate." -cli $true
                    } else {
                        $overwritePrompt = Get-ResponsePrompt -message "Do you want to overwrite the existing CA Cert? This will generate a new root CA with a new serial number and user certs generated with the previous CA will no longer authenticate."
                    }
                } else {
                    $overwritePrompt = $true
                }

                switch ($overwritePrompt) {
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

                        # Copy the current root cert to the backups folder and zip it
                        try {
                            Copy-Item -Path "$CertPath/radius_ca_cert.pem" -Destination "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                            Copy-Item -Path "$CertPath/radius_ca_key.pem" -Destination "$CertPath/Backups/radius_ca_key_$timestamp.pem"

                            # Zip the root cert and key files
                            $zipPath = "$CertPath/Backups/newOverwrite_radius_ca_cert_backup_$timestamp.zip"
                            Compress-Archive -Path "$CertPath/Backups/radius_ca_cert_$timestamp.pem", "$CertPath/Backups/radius_ca_key_$timestamp.pem" -DestinationPath $zipPath

                            Remove-Item -Path "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                            Remove-Item -Path "$CertPath/Backups/radius_ca_key_$timestamp.pem"

                        } catch {
                            Write-Error "Error backing up the current root cert and key. $($_.Exception.Message)"
                            exit
                        }
                        # Save the pass phrase in the env:
                        $env:certKeyPassword = $certKeyPass
                        Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -x509 -newkey rsa:2048 -days $($global:JCRConfig.caCertValidityDays.value) -keyout `"$outKey`" -out `"$outCA`" -passout pass:$($env:certKeyPassword) -subj /C=$($($global:JCRConfig.certSubjectHeader.Value.CountryCode))/ST=$($($global:JCRConfig.certSubjectHeader.Value.StateCode))/L=$($($global:JCRConfig.certSubjectHeader.Value.Locality))/O=$($($global:JCRConfig.certSubjectHeader.Value.Organization))/OU=$($($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit))/CN=$($($global:JCRConfig.certSubjectHeader.Value.CommonName))"
                        # REM PEM pass phrase: myorgpass
                        Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -in `"$outCA`" -noout -text"
                        # openssl x509 -in ca-cert.pem -noout -text
                        # Update Extensions Distinguished Names:
                        if (-not (Test-JCRExtensionFile)) {
                            Write-Host "Extensions file is not valid, updating it now..."
                            Set-JCRExtensionFile
                        } else {
                            Write-Host "Extensions file is valid, no need to update"
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
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -x509 -newkey rsa:2048 -days $($global:JCRConfig.caCertValidityDays.value) -keyout `"$outKey`" -out `"$outCA`" -passout pass:$($env:certKeyPassword) -subj /C=$($($global:JCRConfig.certSubjectHeader.Value.CountryCode))/ST=$($($global:JCRConfig.certSubjectHeader.Value.StateCode))/L=$($($global:JCRConfig.certSubjectHeader.Value.Locality))/O=$($($global:JCRConfig.certSubjectHeader.Value.Organization))/OU=$($($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit))/CN=$($($global:JCRConfig.certSubjectHeader.Value.CommonName))"
                # REM PEM pass phrase: myorgpass
                Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -in `"$outCA`" -noout -text"
                # openssl x509 -in ca-cert.pem -noout -text
                # Update Extensions Distinguished Names:
                if (-not (Test-JCRExtensionFile)) {
                    Write-Host "Extensions file is not valid, updating it now..."
                    Set-JCRExtensionFile
                } else {
                    Write-Host "Extensions file is valid, no need to update"
                }

                return
            }
        }
        # Renew current root certificate
        '2' {
            $env:certKeyPassword = $certKeyPass
            # Check if there is a current CA cert
            if (Test-Path -Path "$($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem") {

                if (!$force) {
                    if ($PSCmdlet.ParameterSetName -eq 'cli') {
                        $replacePrompt = Get-ResponsePrompt -message "Do you want to renew the existing CA Cert? renewing the root CA will contain the same serial number and CA subject headers. User certs generated with the previous CA will continue to authenticate." -cli $true
                    } else {
                        $replacePrompt = Get-ResponsePrompt -message "Do you want to renew the existing CA Cert? renewing the root CA will contain the same serial number and CA subject headers. User certs generated with the previous CA will continue to authenticate."
                    }
                } else {
                    $replacePrompt = $true
                }

                switch ($replacePrompt) {
                    $true {
                        Write-Host "Renewing Root Cert..." -ForegroundColor Yellow
                        switch ($PSCmdlet.ParameterSetName) {
                            'gui' {
                                $env:certKeyPassword = ""
                                # Loop until the passwords match
                                $secureCertKeyPass = Read-Host -Prompt "Enter the current password for the certificate key" -AsSecureString
                                $certKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                                do {
                                    $result = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) rsa -in `"$outKey`" -passin pass:$($certKeyPass) -check"
                                    if ($result -match "RSA key ok") {
                                        Write-Host "Password validated! Proceeding..."
                                        $env:certKeyPassword = $certKeyPass
                                        $passwordValid = $true
                                    } else {
                                        Write-Host "Incorrect private key password!" -ForegroundColor Red
                                        $passwordValid = $false  # Continue loop if password is incorrect
                                        $secureCertKeyPass = Read-Host "Please enter a valid password for the current private key" -AsSecureString
                                        $certKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
                                    }
                                } while (-not $passwordValid)  # Continue looping until the password is correct
                            }
                            'cli' {
                                $certKeyPass = $certKeyPassword
                                # Validate that the password works with the old CA cert
                                # Attempt to read the private key with the password
                                do {
                                    $result = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) rsa -in `"$outKey`" -passin pass:$($certKeyPass) -check"

                                    if ($result -match "RSA key ok") {
                                        Write-Host "Password validated! Proceeding..."
                                        $env:certKeyPassword = $certKeyPass
                                        $passwordValid = $true  # Exit condition for the loop
                                    } else {
                                        Write-Host "Incorrect password" -ForegroundColor Red
                                        $passwordValid = $false  # Continue loop if password is incorrect
                                        $certKeyPass = Read-Host "Please enter a valid password for the current private key" -AsSecureString
                                        $certKeyPass = ConvertFrom-SecureString $certKeyPass -AsPlainText
                                    }
                                } while (-not $passwordValid)  # Continue looping until the password is correct
                            }
                        }

                        # Copy the current root cert to the backups folder and zip it
                        try {
                            Copy-Item -Path "$CertPath/radius_ca_cert.pem" -Destination "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                            Copy-Item -Path "$CertPath/radius_ca_key.pem" -Destination "$CertPath/Backups/radius_ca_key_$timestamp.pem"

                            # Zip the root cert and key files
                            $zipPath = "$CertPath/Backups/renew_radius_ca_cert_backup_$timestamp.zip"
                            Compress-Archive -Path "$CertPath/Backups/radius_ca_cert_$timestamp.pem", "$CertPath/Backups/radius_ca_key_$timestamp.pem" -DestinationPath $zipPath

                            Remove-Item -Path "$CertPath/Backups/radius_ca_cert_$timestamp.pem"
                            Remove-Item -Path "$CertPath/Backups/radius_ca_key_$timestamp.pem"

                        } catch {
                            Write-Error "Error backing up the current root cert and key. $($_.Exception.Message)"
                            exit
                        }
                        $certConfPath = "$CertPath/radius_ca_cert2.conf"
                        $csrOutPath = "$CertPath/radius_ca_cert.csr"
                        $select = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -in `"$($outCA)`" -serial -noout"
                        $serial = $select -replace "serial=", ""

                        # Validate that the password works with the old CA cert
                        # Attempt to read the private key with the password

                        try {
                            Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -x509toreq  -in $($outCA) -signkey $($outKey)  -out $csrOutPath -passin pass:$($env:certKeyPassword)"

                        } catch {
                            # Exit
                            Write-Error "Error creating CSR file $($_.Exception.Message)"
                            exit
                        }

                        $string = @"
[ v3_ca ]
basicConstraints= CA:TRUE
subjectKeyIdentifier= hash
authorityKeyIdentifier= keyid:always,issuer:always
"@ | Out-File "$certConfPath"

                        try {
                            Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) req -x509 -newkey rsa:2048 -days $($global:JCRConfig.caCertValidityDays.value) -keyout `"$outKey`" -out `"$outCA`" -passout pass:$($env:certKeyPassword) -subj /C=$($($global:JCRConfig.certSubjectHeader.Value.CountryCode))/ST=$($($global:JCRConfig.certSubjectHeader.Value.StateCode))/L=$($($global:JCRConfig.certSubjectHeader.Value.Locality))/O=$($($global:JCRConfig.certSubjectHeader.Value.Organization))/OU=$($($global:JCRConfig.certSubjectHeader.Value.OrganizationUnit))/CN=$($($global:JCRConfig.certSubjectHeader.Value.CommonName))"

                            Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -req -days $($global:JCRConfig.caCertValidityDays.value) -in $csrOutPath -set_serial `"0x$serial`" -signkey `"$outKey`" -out `"$outCA`" -extfile $certConfPath -extensions v3_ca -passin pass:$($env:certKeyPassword)"

                            # Message of success
                            Write-Host "Root Certificate Renewed Successfully!" -ForegroundColor Yellow
                            # Cleanup
                            Remove-Item -Path $certConfPath
                            Remove-Item -Path $csrOutPath
                        } catch {
                            # Error replacing the certificate
                            Write-Error "Error replacing the certificate. $($_.Exception.Message)"
                        }
                        Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -in `"$outCA`" -enddate -serial -noout "
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
        # Return to main menu
        'E' {
            return
        }
    }
}


