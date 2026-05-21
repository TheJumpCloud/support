Describe -Tag "JCAuth" -Name "New-JCBearerToken Tests" {
    It "Returns a PSCustomObject with AccessToken, TokenType, ExpiresIn, ExpiresAt" {
        $result = New-JCBearerToken -ClientId $env:JCClientId -ClientSecret $env:JCClientSecret
        $result | Should -Not -BeNullOrEmpty
        $result.AccessToken | Should -Not -BeNullOrEmpty
        $result.TokenType | Should -Not -BeNullOrEmpty
        $result.ExpiresIn | Should -BeGreaterThan 0
        $result.ExpiresAt | Should -BeOfType [datetime]
    }
    It "Persists ClientId, ClientSecret, AccessToken, and ExpiresAt to env vars" {
        New-JCBearerToken -ClientId $env:JCClientId -ClientSecret $env:JCClientSecret | Out-Null
        $env:JCAccessToken | Should -Not -BeNullOrEmpty
        $env:JCAccessTokenExpiresAt | Should -Not -BeNullOrEmpty
        $env:JCClientId | Should -Not -BeNullOrEmpty
        $env:JCClientSecret | Should -Not -BeNullOrEmpty
    }
    It "Sets the expiry roughly 1 hour in the future" {
        $before = (Get-Date).AddSeconds(3000)
        $after = (Get-Date).AddSeconds(4000)
        $result = New-JCBearerToken -ClientId $env:JCClientId -ClientSecret $env:JCClientSecret
        $result.ExpiresAt | Should -BeGreaterThan $before
        $result.ExpiresAt | Should -BeLessThan $after
    }
    It "Throws when the credentials are invalid" {
        { New-JCBearerToken -ClientId 'invalid_id' -ClientSecret 'invalid_secret' } | Should -Throw
    }
}
