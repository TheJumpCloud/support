function Get-JCRCertReport {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$UserGroupIDs,
        [Parameter(Mandatory)]
        [string]$ExportFilePath
    )

    # Initialize an empty array to store the results
    $reportData = @()

    foreach ($groupID in $UserGroupIDs) {
        $radiusMembersPath = Join-Path -Path $PSScriptRoot -ChildPath "data/radiusMembers.json"
        $certHashPath = Join-Path -Path $PSScriptRoot -ChildPath "data/certHash.json"

        if (!(Test-Path $radiusMembersPath)) {
            Write-Error "radiusMembers.json not found at $radiusMembersPath"
            continue # Skip to the next group if file not found
        }
        if (!(Test-Path $certHashPath)) {
            Write-Error "certHash.json not found at $certHashPath"
            continue # Skip to the next group if file not found
        }


        $radiusMembers = Get-Content $radiusMembersPath | ConvertFrom-Json
        $certHashes = Get-Content $certHashPath | ConvertFrom-Json

        foreach ($user in $radiusMembers) {
            foreach ($device in $user.devices) {
                $reportEntry = [ordered]@{}
                $reportEntry.username = $user.username
                $reportEntry.userid = $user.userid
                $reportEntry.systemHostname = $device.systemHostname
                $reportEntry.systemID = $device.systemID
                $reportEntry.systemOS = $device.systemOS


                # Check if certificate is installed on the device
                $certInstalled = $false
                $certificateSerialNumber = $null
                $certificateExpirationDate = $null

                if ($certHashes."$($device.systemID)") {
                    # Check if the systemID exists in certHashes
                    foreach ($cert in $certHashes."$($device.systemID)") {
                        # Loop through possible certs on the device
                        $certificateSerialNumber = $cert.serialNumber # Capture the serial number
                        $certificateExpirationDate = $cert.notAfter # Capture expiration date
                        $certInstalled = $true # If we got here there is at least one cert
                        break # Exit inner loop, we can assume the user has a cert
                    }
                }

                $reportEntry.CertificateSerialNumber = $certificateSerialNumber
                $reportEntry."Certificate Expiration Date" = $certificateExpirationDate
                $reportEntry."Certificate Installed on the device" = $certInstalled

                $reportData += [pscustomobject]$reportEntry
            }
        }
    }

    # Export to CSV
    $reportData | Export-Csv -Path $ExportFilePath -NoTypeInformation
    Write-Host "Certificate report generated at: $ExportFilePath"
}