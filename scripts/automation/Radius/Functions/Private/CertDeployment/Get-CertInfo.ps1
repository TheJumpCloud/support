function Get-CertInfo {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'When specified this function will return certificate information for the root CA located in /Cert', ParameterSetName = 'CA', Mandatory = $true)]
        [switch]
        $RootCA,
        [Parameter(HelpMessage = 'When specified this function will return all user certificate information for user certs located in /UserCerts', ParameterSetName = 'User', Mandatory = $true)]
        [switch]
        $UserCerts,
        [Parameter(HelpMessage = 'When specified this function will return a single users certificate information for a cert located in /UserCerts', ParameterSetName = 'User', Mandatory = $false)]
        [system.string]
        $username
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
            if ($username) {
                $foundCerts = Resolve-Path -Path "$JCScriptRoot/UserCerts/$username-*.crt" -ErrorAction SilentlyContinue

            } else {
                $foundCerts = Resolve-Path -Path "$JCScriptRoot/UserCerts/*.crt" -ErrorAction SilentlyContinue
            }
        }

        $certObj = New-Object System.Collections.ArrayList
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
                # TODO: pscustomobject instead of hash
                $certHash = @{}
                # Use openssl to gather serial, subject, issuer, and enddate information
                $certInfo = Invoke-Expression "$JCR_OPENSSL x509 -in `"$($foundCerts.Path)`" -enddate -serial -subject -issuer -noout"

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
                    $certHash = [PSCustomObject]@{}
                    # Use openssl to gather serial, subject, issuer and enddate information
                    $certInfo = Invoke-Expression "$JCR_OPENSSL x509 -in `"$($cert.Path)`" -enddate -serial -subject -issuer -fingerprint -sha1 -noout"
                    # Convert string data into a key/value pair
                    $certInfo | ForEach-Object {
                        $property = $_ | ConvertFrom-StringData
                        switch ($($property.keys)) {
                            'notAfter' {
                                $date = $property.notAfter
                                $date = $date.replace('GMT', '').Trim()
                                $date = $date -replace '\s+', ' '
                                $property.notAfter = [datetime]::ParseExact($date , "MMM d HH:mm:ss yyyy", $null)
                            }
                            'sha1 Fingerprint' {
                                $property.Values = ($($property.Values)).ToLower().Replace(":", "")
                                $property.keys = 'sha1'
                            }
                            Default {
                            }
                        }
                        $certHash | Add-Member -Name $property.keys -Type NoteProperty -Value "$($property.Values)"
                    }
                    # lastly add the username of the certificate to the hash:
                    $certFile = Get-Item $($cert.Path)
                    if (('username' -notin $MyInvocation.BoundParameters) -AND (-Not [System.String]::IsNullOrEmpty($certFile.name))) {
                        Write-Host "Attempting to parse username from string: $($certFile.name)"
                        $matchNames = $certFile.name | Select-String -Pattern "(.*)-$($Global:JCR_CERT_TYPE).*"
                        if ($matchNames.Matches.groups) {
                            $username = $matchNames.Matches.groups[1].value
                        }
                    }

                    $certHash | Add-Member -Name 'username' -Type NoteProperty -Value $username
                    $certHash | Add-Member -Name 'generated' -Type NoteProperty -Value ($certFile.LastWriteTime.ToString('MM/dd/yyyy HH:mm:ss'))
                    # Add hash to certObj array if the user is a member of the userGroup
                    if ($username -in $global:JCRRadiusMembers.username) {
                        $certObj.add( $certHash) | Out-Null
                    }
                }
            }
        }
    }
    end {
        return $certObj
    }
}