function Get-ExpiringCertInfo {
    param (
        $certInfo,
        $JCR_WarningDays
    )
    process {
        $expiringCerts = $certInfo | Where-Object -Property notAfter -LT $JCR_WarningDays
    }
    end {
        return $expiringCerts
    }
}