Describe -Tag "JCAuth" -Name "Get-JCAccessToken Tests" {
    It "Reports a valid token without minting a new one" {
        # Seed a valid token via New-JCBearerToken first
        New-JCBearerToken -ClientId $env:JCClientId -ClientSecret $env:JCClientSecret | Out-Null
        $tokenBefore = $env:JCAccessToken
        $info = Get-JCAccessToken
        $info.AccessToken | Should -Be $tokenBefore
        $info.IsValid | Should -Be $true
        $info.IsExpired | Should -Be $false
        # Pure "Get": calling it must not change the cached token
        $env:JCAccessToken | Should -Be $tokenBefore
    }
    It "Reports IsExpired/IsValid correctly when ExpiresAt is in the past" {
        $savedExpiry = $env:JCAccessTokenExpiresAt
        try {
            $env:JCAccessTokenExpiresAt = (Get-Date).AddSeconds(-10).ToString('o')
            $info = Get-JCAccessToken
            $info.IsExpired | Should -Be $true
            $info.IsValid | Should -Be $false
        } finally {
            $env:JCAccessTokenExpiresAt = $savedExpiry
        }
    }
    It "Does not throw and reports IsValid false when no token is present" {
        $savedToken = $env:JCAccessToken
        $savedExpiry = $env:JCAccessTokenExpiresAt
        try {
            $env:JCAccessToken = ''
            $env:JCAccessTokenExpiresAt = ''
            $info = $null
            { $info = Get-JCAccessToken } | Should -Not -Throw
            $info.IsValid | Should -Be $false
            [System.String]::IsNullOrEmpty($info.AccessToken) | Should -Be $true
        } finally {
            $env:JCAccessToken = $savedToken
            $env:JCAccessTokenExpiresAt = $savedExpiry
        }
    }
}
