function Get-JCAccessToken {
    [CmdletBinding()]
    param ()
    process {
        $expiresAt = if (-not [System.String]::IsNullOrEmpty($env:JCAccessTokenExpiresAt)) {
            [datetime]::Parse($env:JCAccessTokenExpiresAt, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
        } else {
            [datetime]::MinValue
        }

        $hasToken = -not [System.String]::IsNullOrEmpty($env:JCAccessToken)
        # 30s skew avoids the race where a token is valid at check-time but expires mid-request
        $isExpired = (Get-Date).AddSeconds(30) -ge $expiresAt

        return [PSCustomObject]@{
            AccessToken     = $env:JCAccessToken
            ExpiresAt       = if ($hasToken) { $expiresAt } else { $null }
            TimeUntilExpiry = if ($hasToken) { $expiresAt - (Get-Date) } else { $null }
            IsExpired       = $isExpired
            IsValid         = ($hasToken -and -not $isExpired)
        }
    }
}
