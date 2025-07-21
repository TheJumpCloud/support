function Get-ExpiringCertInfo {
    param (
        [Parameter(Mandatory)]
        [System.Object]
        $certInfo,
        [Parameter(Mandatory)]
        [System.Int32]
        $cutoffDate
    )
    begin {
        $expiringCerts = New-Object System.Collections.ArrayList
        $currentTime = (Get-Date -Format "o")
    }
    process {
        foreach ($cert in $certInfo) {
            $startDate = [datetime]$currentTime
            if ($cert.notAfter -is [string]) {
                $endDate = [datetime]::Parse($cert.notAfter, [System.Globalization.CultureInfo]::InvariantCulture)
            } else {
                $endDate = [datetime]$cert.notAfter
            }
            $certTimespan = New-Timespan -Start $startDate -End $endDate
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