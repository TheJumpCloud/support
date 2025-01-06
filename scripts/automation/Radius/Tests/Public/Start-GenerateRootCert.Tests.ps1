Describe "Generate Root Certificate Tests" -Tag "GenerateRootCert" {
    Context "A new certificate can be generated" {
        It 'Generates a new root certificate' {
            # If the /Cert/ folder is not empty, clear the directory
            $items = Get-ChildItem $JCScriptRoot/Cert
            if ($items) {
                foreach ($item in $items) {
                    write-host "removing $($item.FullName)"
                    Remove-Item -Path $item.FullName
                }
            }
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#"

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
    Context "An existing certificate can be replaced" {
        It 'Replaces a root certificate' {
            # get existing cert serial:
            $origSN = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -serial"
            # force generate new CA
            Start-GenerateRootCert -certKeyPassword "testCertificate123!@#"
            # get new SN
            $newSN = Invoke-Expression "$JCR_OPENSSL x509 -noout -in $JCScriptRoot/Cert/radius_ca_cert.pem -serial"
            # the serial numbers of the cert should not be the same, i.e. a new cert has replaced the existing one
            $origSN | Should -Not -Be $newSN
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
    Context "An existing certificate can be renewed" {
        # TODO: implement
        # openssl req -new -key radius_ca_key.key -out newcsr.csr
        # openssl x509 -req -days 365 -in newcsr.csr -signkey radius_ca_key.key -out radius_ca_cert.pem
        # rm newcsr.csr

    }
}