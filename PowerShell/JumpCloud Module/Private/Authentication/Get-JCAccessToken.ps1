function Get-JCAccessToken {
    [CmdletBinding()]
    param ()
    process {
        $expiresAt = if (-not [System.String]::IsNullOrEmpty($env:JCAccessTokenExpiresAt)) {
            [datetime]::Parse($env:JCAccessTokenExpiresAt, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
        } else {
            [datetime]::MinValue
        }

        # 30s skew avoids the race where a token is valid at check-time but expires mid-request
        $isExpired = (Get-Date).AddSeconds(30) -ge $expiresAt

        if ([System.String]::IsNullOrEmpty($env:JCAccessToken) -or $isExpired) {
            if ([System.String]::IsNullOrEmpty($env:JCClientId) -or [System.String]::IsNullOrEmpty($env:JCClientSecret)) {
                throw 'Access token is missing or expired and ClientId/ClientSecret are not available. Run Connect-JCOnline to re-authenticate.'
            }
            Write-Verbose 'Access token missing or expired; requesting a new bearer token.'
            New-JCBearerToken -ClientId $env:JCClientId -ClientSecret $env:JCClientSecret | Out-Null
        }
        return $env:JCAccessToken
    }
}
