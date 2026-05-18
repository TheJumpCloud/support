Describe -Tag "JCAuth" -Name "Get-JCAccessToken Tests" {
    It "Returns the current access token when it is still valid" {
        # Seed a valid token via New-JCBearerToken first
        New-JCBearerToken -ClientId $env:JCClientId -ClientSecret $env:JCClientSecret | Out-Null
        $tokenBefore = $env:JCAccessToken
        $returned = Get-JCAccessToken
        $returned | Should -Not -BeNullOrEmpty
        $returned | Should -Be $tokenBefore
    }
    It "Refreshes the token when ExpiresAt is in the past" {
        # Force expiry
        $env:JCAccessTokenExpiresAt = (Get-Date).AddSeconds(-10).ToString('o')
        $oldToken = $env:JCAccessToken
        $newToken = Get-JCAccessToken
        $newToken | Should -Not -BeNullOrEmpty
        # A new token should have been minted (env updated, expiry pushed forward)
        ([datetime]::Parse($env:JCAccessTokenExpiresAt, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)) | Should -BeGreaterThan (Get-Date)
    }
    It "Throws when no token and no ClientId/ClientSecret are available" {
        $savedToken = $env:JCAccessToken
        $savedExpiry = $env:JCAccessTokenExpiresAt
        $savedClientId = $env:JCClientId
        $savedClientSecret = $env:JCClientSecret
        try {
            $env:JCAccessToken = ''
            $env:JCAccessTokenExpiresAt = ''
            $env:JCClientId = ''
            $env:JCClientSecret = ''
            { Get-JCAccessToken } | Should -Throw
        } finally {
            $env:JCAccessToken = $savedToken
            $env:JCAccessTokenExpiresAt = $savedExpiry
            $env:JCClientId = $savedClientId
            $env:JCClientSecret = $savedClientSecret
        }
    }
}
