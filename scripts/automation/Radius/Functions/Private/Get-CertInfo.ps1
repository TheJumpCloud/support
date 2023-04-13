function Get-CertInfo {
    param (
        [switch]$RootCA,
        [switch]$UserCerts
    )
    begin {
        # Import the Config.ps1 variables
        . "$JCScriptRoot/Config.ps1"

        if ($RootCA) {
            # Find the RootCA Path
            $foundCerts = Resolve-Path -Path "$JCScriptRoot/Cert/*cert*.pem" -ErrorAction SilentlyContinue
        }

        if ($UserCerts) {
            # Find all userCert paths
            $foundCerts = Resolve-Path -Path "$JCScriptRoot/UserCerts/*.crt" -ErrorAction SilentlyContinue
        }

        $certObj = @()
    }
    process {
        # If no cert is found, return null
        if (!$foundCerts) {
            $certHash = $null
        } else {
            if ($RootCA) {
                # Check if cert and key name is radius_ca_cert.pem and radius_ca_key.pem if not, rename it
                if ($foundCerts.Name -notmatch "radius_ca_cert.pem") {
                    Rename-Item -Path $foundCerts -NewName "radius_ca_cert.pem"
                    $foundCerts = Resolve-Path -Path "$JCScriptRoot/Cert/*cert*.pem" -ErrorAction SilentlyContinue
                }
                # Get the key path and rename it if needed
                $foundKey = Resolve-Path -Path "$JCScriptRoot/Cert/*key.pem" -ErrorAction SilentlyContinue
                if ($foundKey.Name -notmatch "radius_ca_key.pem") {
                    Rename-Item -Path $foundKey -NewName "radius_ca_key.pem"
                }

                # Create hashtable to contain cert info
                $certHash = @{}
                # Use openssl to gather serial, subject, issuer, and enddate information
                $certInfo = Invoke-Expression "$opensslBinary x509 -in $($foundCerts.Path) -enddate -serial -subject -issuer -noout"

                # Convert string data into a key/value pair
                $certInfo | ForEach-Object {
                    $property = $_ | ConvertFrom-StringData

                    # Convert notAfter property into datetime format
                    if ($property.notAfter) {
                        $date = $property.notAfter
                        $date = $date.replace('GMT', '').Trim()
                        $date = $date -replace '\s+', ' '
                        $property.notAfter = [datetime]::ParseExact($date , "MMM d HH:mm:ss yyyy", $null)
                    }

                    $certHash += $property
                }

                # Add hash to certObj array
                $certObj += $certHash
            } elseif ($UserCerts) {
                foreach ($cert in $foundCerts) {
                    # Create hashtable to contain cert info
                    $certHash = @{}
                    # Use openssl to gather serial, subject, issuer and enddate information
                    $certInfo = Invoke-Expression "$opensslBinary x509 -in $($cert.Path) -enddate -serial -subject -issuer -noout"

                    # Convert string data into a key/value pair
                    $certInfo | ForEach-Object {
                        $property = $_ | ConvertFrom-StringData

                        # Convert notAfter property into datetime format
                        if ($property.notAfter) {
                            $date = $property.notAfter
                            $date = $date.replace('GMT', '').Trim()
                            $date = $date -replace '\s+', ' '
                            $property.notAfter = [datetime]::ParseExact($date , "MMM d HH:mm:ss yyyy", $null)
                        }

                        $certHash += $property
                    }

                    # Add hash to certObj array
                    $certObj += $certHash
                }
            }
        }
    }
    end {
        return $certObj
    }
}