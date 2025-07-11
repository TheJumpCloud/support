Describe "Generate Root Certificate Tests" -Tag "GenerateRootCert" {
    BeforeEach {
        # If the /Cert/ folder is not empty, clear the directory
        $items = Get-ChildItem -Path "$($global:JCRConfig.radiusDirectory.value)/Cert"
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
            $itemsAfter = Get-ChildItem -Path "$($global:JCRConfig.radiusDirectory.value)/Cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -subject"

            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "C")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.CountryCode
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "ST") | Should -Match $global:JCRConfig.certSubjectHeader.Value.StateCode
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "L")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.Locality
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "O")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.Organization
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "OU") | Should -Match $global:JCRConfig.certSubjectHeader.Value.OrganizationUnit
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "CN") | Should -Match $global:JCRConfig.certSubjectHeader.Value.CommonName
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
            $itemsAfter = Get-ChildItem -Path "$($global:JCRConfig.radiusDirectory.value)/Cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            # Validate that the backup zip file was created
            $backupFiles = Get-ChildItem -Path "$($global:JCRConfig.radiusDirectory.value)/Cert/Backups"
            # Should contain a zip file
            $backupFiles.Extension | Should -Contain ".zip"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -subject"

            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "C")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.CountryCode
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "ST") | Should -Match $global:JCRConfig.certSubjectHeader.Value.StateCode
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "L")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.Locality
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "O")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.Organization
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "OU") | Should -Match $global:JCRConfig.certSubjectHeader.Value.OrganizationUnit
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "CN") | Should -Match $global:JCRConfig.certSubjectHeader.Value.CommonName
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
            $itemsAfter = Get-ChildItem -Path "$($global:JCRConfig.radiusDirectory.value)/Cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            # Validate that the backup zip file was created
            $backupFiles = Get-ChildItem -Path "$($global:JCRConfig.radiusDirectory.value)/Cert/Backups"
            # Should contain a zip file
            $backupFiles.Extension | Should -Contain ".zip"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -subject"

            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "C")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.CountryCode
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "ST") | Should -Match $global:JCRConfig.certSubjectHeader.Value.StateCode
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "L")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.Locality
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "O")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.Organization
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "OU") | Should -Match $global:JCRConfig.certSubjectHeader.Value.OrganizationUnit
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "CN") | Should -Match $global:JCRConfig.certSubjectHeader.Value.CommonName
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
            $itemsAfter = Get-ChildItem -Path "$($global:JCRConfig.radiusDirectory.value)/Cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_cert"
            $itemsAfter.BaseName | Should -Contain "radius_ca_key"

            # Validate that the backup zip file was created
            $backupFiles = Get-ChildItem -Path "$($global:JCRConfig.radiusDirectory.value)/Cert/Backups"
            # Should contain a zip file
            $backupFiles.Extension | Should -Contain ".zip"

            #validate the subject matches what's defined in config:
            $CA_subject = Invoke-Expression "$($global:JCRConfig.openSSLBinary.value) x509 -noout -in $($global:JCRConfig.radiusDirectory.value)/Cert/radius_ca_cert.pem -subject"

            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "C")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.CountryCode
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "ST") | Should -Match $global:JCRConfig.certSubjectHeader.Value.StateCode
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "L")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.Locality
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "O")  | Should -Match $global:JCRConfig.certSubjectHeader.Value.Organization
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "OU") | Should -Match $global:JCRConfig.certSubjectHeader.Value.OrganizationUnit
            (Get-SubjectHeaderValue -SubjectString $CA_subject -Header "CN") | Should -Match $global:JCRConfig.certSubjectHeader.Value.CommonName
        }

    }
}