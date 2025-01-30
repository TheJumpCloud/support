Describe "Generate Root Certificate Tests" -Tag "GenerateRootCert" {
    Context "A new certificate can be generated" {
        It 'Generates a new root certificate' {
            # If the /Cert/ folder is not empty, clear the directory
            $items = Get-ChildItem "$JCScriptRoot/Cert"
            if ($items) {
                foreach ($item in $items) {
                    # If the item is the 'backup' folder, process its contents separately
                    if ($item.Name -eq 'Backups') {
                        $backupItems = Get-ChildItem $item.FullName
                        foreach ($backupItem in $backupItems) {
                            Write-Host "Removing $($backupItem.FullName)"
                            Remove-Item -Path $backupItem.FullName -Force
                        }
                    }
                    # Otherwise, remove the item directly (outside of the 'backup' folder)
                    elseif ($item.PSIsContainer -eq $false) {
                        Write-Host "Removing $($item.FullName)"
                        Remove-Item -Path $item.FullName -Force
                    }
                }
            }
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "new" -force

            # both the key and the cert should be generated
            $itemsAfter = Get-ChildItem $JCScriptRoot/Cert
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -subject"
            $CA_subject = $CA_subject.split("subject=").split(",")
            ($CA_subject | Where-Object { $_ -match "C=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.countryCode
            ($CA_subject | Where-Object { $_ -match "ST=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.stateCode
            ($CA_subject | Where-Object { $_ -match "L=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.Locality
            ($CA_subject | Where-Object { $_ -match "O=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.Organization
            ($CA_subject | Where-Object { $_ -match "OU=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.OrganizationUnit
            ($CA_subject | Where-Object { $_ -match "CN=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.CommonName
        }
    }

    # Overwrite the existing certificate

    Context "Overwrite an existing root certificate when creating a new one" {
        It 'Generates a new root certificate when there is an existing one' {
            # If the /Cert/ folder is not empty, clear the directory
            $items = Get-ChildItem "$JCScriptRoot/Cert"
            if ($items) {
                foreach ($item in $items) {
                    # If the item is the 'backup' folder, process its contents separately
                    if ($item.Name -eq 'Backups') {
                        $backupItems = Get-ChildItem $item.FullName
                        foreach ($backupItem in $backupItems) {
                            Write-Host "Removing $($backupItem.FullName)"
                            Remove-Item -Path $backupItem.FullName -Force
                        }
                    }
                    # Otherwise, remove the item directly (outside of the 'backup' folder)
                    elseif ($item.PSIsContainer -eq $false) {
                        Write-Host "Removing $($item.FullName)"
                        Remove-Item -Path $item.FullName -Force
                    }
                }
            }

            # Create a new root certificate
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "New" -force
            # get existing cert serial:
            $origSN = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -serial"
            # Force overwrite the existing certificate
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "New" -force
            # get new SN
            $newSN = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -serial"
            # the serial numbers of the cert should not be the same, i.e. a new cert has replaced the existing one
            $origSN | Should -Not -Be $newSN
            # both the key and the cert should be generated
            $itemsAfter = Get-ChildItem $JCScriptRoot/Cert
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            # Validate that the backup zip file was created
            $backupFiles = Get-ChildItem $JCScriptRoot/Cert/Backups
            # Should contain a zip file
            $backupFiles.Extension | Should -Contain ".zip"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -subject"
            $CA_subject = $CA_subject.split("subject=").split(",")
            ($CA_subject | Where-Object { $_ -match "C=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.countryCode
            ($CA_subject | Where-Object { $_ -match "ST=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.stateCode
            ($CA_subject | Where-Object { $_ -match "L=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.Locality
            ($CA_subject | Where-Object { $_ -match "O=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.Organization
            ($CA_subject | Where-Object { $_ -match "OU=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.OrganizationUnit
            ($CA_subject | Where-Object { $_ -match "CN=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.CommonName
        }
    }

    Context "An existing certificate can be replaced" {
        It 'Replaces a root certificate' {
            # If the /Cert/ folder is not empty, clear the directory
            $items = Get-ChildItem "$JCScriptRoot/Cert"
            if ($items) {
                foreach ($item in $items) {
                    # If the item is the 'backup' folder, process its contents separately
                    if ($item.Name -eq 'Backups') {
                        $backupItems = Get-ChildItem $item.FullName
                        foreach ($backupItem in $backupItems) {
                            Write-Host "Removing $($backupItem.FullName)"
                            Remove-Item -Path $backupItem.FullName -Force
                        }
                    }
                    # Otherwise, remove the item directly (outside of the 'backup' folder)
                    elseif ($item.PSIsContainer -eq $false) {
                        Write-Host "Removing $($item.FullName)"
                        Remove-Item -Path $item.FullName -Force
                    }
                }
            }
            # Create a new root certificate
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "new" -force
            # get existing cert serial:
            $origSN = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -serial"
            # Replace root certificate
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "replace" -force
            # get new SN
            $newSN = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -serial"
            # the serial numbers of the cert should not be the same, i.e. a new cert has replaced the existing one
            $origSN | Should -Not -Be $newSN
            # both the key and the cert should be generated
            $itemsAfter = Get-ChildItem $JCScriptRoot/Cert
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            # Validate that the backup zip file was created
            $backupFiles = Get-ChildItem $JCScriptRoot/Cert/Backups
            # Should contain a zip file
            $backupFiles.Extension | Should -Contain ".zip"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -subject"
            $CA_subject = $CA_subject.split("subject=").split(",")
            ($CA_subject | Where-Object { $_ -match "C=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.countryCode
            ($CA_subject | Where-Object { $_ -match "ST=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.stateCode
            ($CA_subject | Where-Object { $_ -match "L=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.Locality
            ($CA_subject | Where-Object { $_ -match "O=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.Organization
            ($CA_subject | Where-Object { $_ -match "OU=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.OrganizationUnit
            ($CA_subject | Where-Object { $_ -match "CN=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.CommonName
        }

    }
    Context "An existing certificate can be renewed" {
        It 'Renews a root certificate' {
            # If the /Cert/ folder is not empty, clear the directory
            $items = Get-ChildItem "$JCScriptRoot/Cert"
            if ($items) {
                foreach ($item in $items) {
                    # If the item is the 'backup' folder, process its contents separately
                    if ($item.Name -eq 'Backups') {
                        $backupItems = Get-ChildItem $item.FullName
                        foreach ($backupItem in $backupItems) {
                            Write-Host "Removing $($backupItem.FullName)"
                            Remove-Item -Path $backupItem.FullName -Force
                        }
                    }
                    # Otherwise, remove the item directly (outside of the 'backup' folder)
                    elseif ($item.PSIsContainer -eq $false) {
                        Write-Host "Removing $($item.FullName)"
                        Remove-Item -Path $item.FullName -Force
                    }
                }
            }
            # Generate new CA
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "new" -force
            # get existing cert serial:
            $origSN = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -serial"
            # Renew CA
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "renew" -force
            # get new SN
            $newSN = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -serial"
            # the serial numbers of the cert should not be the same, i.e. a new cert has replaced the existing one
            $origSN | Should -Be $newSN
            # both the key and the cert should be generated
            $itemsAfter = Get-ChildItem $JCScriptRoot/Cert
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            # Validate that the backup zip file was created
            $backupFiles = Get-ChildItem $JCScriptRoot/Cert/Backups
            # Should contain a zip file
            $backupFiles.Extension | Should -Contain ".zip"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -subject"
            $CA_subject = $CA_subject.split("subject=").split(",")
            ($CA_subject | Where-Object { $_ -match "C=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.countryCode
            ($CA_subject | Where-Object { $_ -match "ST=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.stateCode
            ($CA_subject | Where-Object { $_ -match "L=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.Locality
            ($CA_subject | Where-Object { $_ -match "O=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.Organization
            ($CA_subject | Where-Object { $_ -match "OU=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.OrganizationUnit
            ($CA_subject | Where-Object { $_ -match "CN=" }) | Should -Match $Global:JCR_SUBJECT_HEADERS.CommonName
        }

    }
}