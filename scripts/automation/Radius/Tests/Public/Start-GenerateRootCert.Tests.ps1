Describe "Generate Root Certificate Tests" -Tag "GenerateRootCert" {
    BeforeEach {
        # If the /Cert/ folder is not empty, clear the directory
        $items = Get-ChildItem "$($global:JCRConfig.radiusDirectory.value)/Cert"
        if ($items) {
            foreach ($item in $items) {
                # If the item is the 'backup' folder, process its contents separately
                Remove-Item -Path $item.FullName -Recurse -Force -Confirm:$false
            }
        }
    }
    Context "A new certificate can be generated" {
        It 'Generates a new root certificate' {
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "new" -force

            # both the key and the cert should be generated
            $itemsAfter = Get-ChildItem $($global:JCRConfig.radiusDirectory.value)/Cert
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -subject"
            $CA_subject = $CA_subject.split("subject=").split(",")
            ($CA_subject | Where-Object { $_ -match "C=" }) | Should -Match $global:JCRConfig.certSubjectHeaderCountryCode.value
            ($CA_subject | Where-Object { $_ -match "ST=" }) | Should -Match $global:JCRConfig.certSubjectHeaderStateCode.value
            ($CA_subject | Where-Object { $_ -match "L=" }) | Should -Match $global:JCRConfig.certSubjectHeaderLocality.value
            ($CA_subject | Where-Object { $_ -match "O=" }) | Should -Match $global:JCRConfig.certSubjectHeaderOrganization.value
            ($CA_subject | Where-Object { $_ -match "OU=" }) | Should -Match $global:JCRConfig.certSubjectHeaderOrganizationUnit.value
            ($CA_subject | Where-Object { $_ -match "CN=" }) | Should -Match $global:JCRConfig.certSubjectHeaderCommonName.value
        }
    }

    # Overwrite the existing certificate

    Context "Overwrite an existing root certificate when creating a new one" {
        It 'Generates a new root certificate when there is an existing one' {
            # Create a new root certificate
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "New" -force
            # get existing cert serial:
            $origSN = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -serial"
            # Force overwrite the existing certificate
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "New" -force
            # get new SN
            $newSN = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -serial"
            # the serial numbers of the cert should not be the same, i.e. a new cert has replaced the existing one
            $origSN | Should -Not -Be $newSN
            # both the key and the cert should be generated
            $itemsAfter = Get-ChildItem $($global:JCRConfig.radiusDirectory.value)/Cert
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            # Validate that the backup zip file was created
            $backupFiles = Get-ChildItem $($global:JCRConfig.radiusDirectory.value)/Cert/Backups
            # Should contain a zip file
            $backupFiles.Extension | Should -Contain ".zip"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -subject"
            $CA_subject = $CA_subject.split("subject=").split(",")
            ($CA_subject | Where-Object { $_ -match "C=" }) | Should -Match $global:JCRConfig.certSubjectHeaderCountryCode.value
            ($CA_subject | Where-Object { $_ -match "ST=" }) | Should -Match $global:JCRConfig.certSubjectHeaderStateCode.value
            ($CA_subject | Where-Object { $_ -match "L=" }) | Should -Match $global:JCRConfig.certSubjectHeaderLocality.value
            ($CA_subject | Where-Object { $_ -match "O=" }) | Should -Match $global:JCRConfig.certSubjectHeaderOrganization.value
            ($CA_subject | Where-Object { $_ -match "OU=" }) | Should -Match $global:JCRConfig.certSubjectHeaderOrganizationUnit.value
            ($CA_subject | Where-Object { $_ -match "CN=" }) | Should -Match $global:JCRConfig.certSubjectHeaderCommonName.value
        }
    }

    Context "An existing certificate can be replaced" {
        It 'Replaces a root certificate' {
            # Create a new root certificate
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "new" -force
            # get existing cert serial:
            $origSN = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -serial"
            # Replace root certificate
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "replace" -force
            # get new SN
            $newSN = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -serial"
            # the serial numbers of the cert should not be the same, i.e. a new cert has replaced the existing one
            $origSN | Should -Not -Be $newSN
            # both the key and the cert should be generated
            $itemsAfter = Get-ChildItem $($global:JCRConfig.radiusDirectory.value)/Cert
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            # Validate that the backup zip file was created
            $backupFiles = Get-ChildItem $($global:JCRConfig.radiusDirectory.value)/Cert/Backups
            # Should contain a zip file
            $backupFiles.Extension | Should -Contain ".zip"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -subject"
            $CA_subject = $CA_subject.split("subject=").split(",")
            ($CA_subject | Where-Object { $_ -match "C=" }) | Should -Match $global:JCRConfig.certSubjectHeaderCountryCode.value
            ($CA_subject | Where-Object { $_ -match "ST=" }) | Should -Match $global:JCRConfig.certSubjectHeaderStateCode.value
            ($CA_subject | Where-Object { $_ -match "L=" }) | Should -Match $global:JCRConfig.certSubjectHeaderLocality.value
            ($CA_subject | Where-Object { $_ -match "O=" }) | Should -Match $global:JCRConfig.certSubjectHeaderOrganization.value
            ($CA_subject | Where-Object { $_ -match "OU=" }) | Should -Match $global:JCRConfig.certSubjectHeaderOrganizationUnit.value
            ($CA_subject | Where-Object { $_ -match "CN=" }) | Should -Match $global:JCRConfig.certSubjectHeaderCommonName.value
        }

    }
    Context "An existing certificate can be renewed" {
        It 'Renews a root certificate' {
            # Generate new CA
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "new" -force
            # get existing cert serial:
            $origSN = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -serial"
            # Renew CA
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#" -generateType "renew" -force
            # get new SN
            $newSN = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -serial"
            # the serial numbers of the cert should not be the same, i.e. a new cert has replaced the existing one
            $origSN | Should -Be $newSN
            # both the key and the cert should be generated
            $itemsAfter = Get-ChildItem $($global:JCRConfig.radiusDirectory.value)/Cert
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            # Validate that the backup zip file was created
            $backupFiles = Get-ChildItem $($global:JCRConfig.radiusDirectory.value)/Cert/Backups
            # Should contain a zip file
            $backupFiles.Extension | Should -Contain ".zip"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -subject"
            $CA_subject = $CA_subject.split("subject=").split(",")
            ($CA_subject | Where-Object { $_ -match "C=" }) | Should -Match $global:JCRConfig.certSubjectHeaderCountryCode.value
            ($CA_subject | Where-Object { $_ -match "ST=" }) | Should -Match $global:JCRConfig.certSubjectHeaderStateCode.value
            ($CA_subject | Where-Object { $_ -match "L=" }) | Should -Match $global:JCRConfig.certSubjectHeaderLocality.value
            ($CA_subject | Where-Object { $_ -match "O=" }) | Should -Match $global:JCRConfig.certSubjectHeaderOrganization.value
            ($CA_subject | Where-Object { $_ -match "OU=" }) | Should -Match $global:JCRConfig.certSubjectHeaderOrganizationUnit.value
            ($CA_subject | Where-Object { $_ -match "CN=" }) | Should -Match $global:JCRConfig.certSubjectHeaderCommonName.value
        }

    }
}