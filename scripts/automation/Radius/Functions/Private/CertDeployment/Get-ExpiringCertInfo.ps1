function Get-ExpiringCertInfo {
    param (
        $certInfo,
        $cutoffDate
    )
    process {
        $expiringCerts = $certInfo | Where-Object -Property notAfter -LT $cutoffDate
    }
    end {
        return $expiringCerts
    }
}