function Output-CertsInfo {
    $certObj = @()
    $certHash = @{}

    # Get the path to the certs
    $foundCert = Resolve-Path -Path "$JCScriptRoot/Cert/*pem"
    # Loop through the certs and get the info
    if ($foundCert) {
        foreach ($cert in $foundCert) {
            #Write-Host "Found imported certs: $($cert)"
            # If cert contains ca-cert on the file name, get the cert info
            if ($cert -match "ca-cert") {
                $certInfo = Invoke-Expression "openssl x509 -in $($cert) -enddate -serial -subject -issuer -noout"
                $certInfo | ForEach-Object {
                    $property = $_ | ConvertFrom-StringData
                    # Convert notAfter property into datetime format
                    if ($property.notAfter) {
                        $date = $property.notAfter
                        $date = $date.replace('GMT', '').Trim()
                    }

                    $certHash += $property
                }
                $certObj += $certHash
            }
        }
    } else {
        Write-Host "No certs found, please press '1' to Generate or Import certificates"
    }

    return $certObj
}




