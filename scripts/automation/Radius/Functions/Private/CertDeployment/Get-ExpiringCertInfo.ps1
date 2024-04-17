function Get-ExpiringCertInfo {
    param (
        # array of certificates
        [Parameter(Mandatory)]
        [System.Object]
        $certInfo,
        [Parameter(Mandatory)]
        [System.Int32]
        $cutoffDate
    )
    begin {
        $expiringCerts = New-Object System.Collections.ArrayList
        $currentTime = Get-Date
    }
    process {
        foreach ($cert in $certInfo) {
            $certTimespan = New-Timespan -Start $currentTime -End $cert.notAfter
            # $cert
            if ($certTimespan.days -lt 15) {
                Write-Debug "$($cert.userName)'s certificate will expire in $($certTimespan.Days) days"
                $expiringCerts.add($cert) | Out-Null
            } else {
                Write-Debug "$($cert.userName)'s certificate will expire in $($certTimespan.Days) days"
            }
        }
    }

    end {
        return $expiringCerts
    }
}