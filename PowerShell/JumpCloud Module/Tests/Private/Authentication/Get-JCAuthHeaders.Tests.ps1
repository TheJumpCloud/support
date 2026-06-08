Describe -Tag "JCAuth" -Name "Get-JCAuthHeaders Tests" {
    It "Always includes Content-Type, Accept, and x-org-id" {
        $headers = Get-JCAuthHeaders
        $headers | Should -Not -BeNullOrEmpty
        $headers['Content-Type'] | Should -Be 'application/json'
        $headers['Accept'] | Should -Be 'application/json'
        $headers.ContainsKey('x-org-id') | Should -Be $true
    }
    It "Returns x-api-key header in apiKey mode" {
        $savedMethod = $global:JCConfig.authPreference.Method
        try {
            $global:JCConfig.authPreference.Method = 'apiKey'
            $headers = Get-JCAuthHeaders
            $headers.ContainsKey('x-api-key') | Should -Be $true
            $headers.ContainsKey('Authorization') | Should -Be $false
        } finally {
            $global:JCConfig.authPreference.Method = $savedMethod
        }
    }
    It "Returns Authorization Bearer header in clientSecret mode" {
        $savedMethod = $global:JCConfig.authPreference.Method
        try {
            $global:JCConfig.authPreference.Method = 'clientSecret'
            $headers = Get-JCAuthHeaders
            $headers.ContainsKey('Authorization') | Should -Be $true
            $headers['Authorization'] | Should -Match '^Bearer '
            $headers.ContainsKey('x-api-key') | Should -Be $false
        } finally {
            $global:JCConfig.authPreference.Method = $savedMethod
        }
    }
    It "Mints a new bearer token when the cached token is expired (clientSecret mode)" {
        $savedMethod = $global:JCConfig.authPreference.Method
        $savedExpiry = $env:JCAccessTokenExpiresAt
        try {
            $global:JCConfig.authPreference.Method = 'clientSecret'
            # Force the cached token to look expired
            $env:JCAccessTokenExpiresAt = (Get-Date).AddSeconds(-10).ToString('o')
            $headers = Get-JCAuthHeaders
            $headers['Authorization'] | Should -Match '^Bearer '
            # A fresh token should have been minted, pushing expiry into the future
            ([datetime]::Parse($env:JCAccessTokenExpiresAt, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)) | Should -BeGreaterThan (Get-Date)
        } finally {
            $global:JCConfig.authPreference.Method = $savedMethod
            $env:JCAccessTokenExpiresAt = $savedExpiry
        }
    }
    It "Throws when token is expired and ClientId/ClientSecret are unavailable (clientSecret mode)" {
        $savedMethod = $global:JCConfig.authPreference.Method
        $savedToken = $env:JCAccessToken
        $savedExpiry = $env:JCAccessTokenExpiresAt
        $savedClientId = $env:JCClientId
        $savedClientSecret = $env:JCClientSecret
        try {
            $global:JCConfig.authPreference.Method = 'clientSecret'
            $env:JCAccessToken = ''
            $env:JCAccessTokenExpiresAt = ''
            $env:JCClientId = ''
            $env:JCClientSecret = ''
            { Get-JCAuthHeaders } | Should -Throw
        } finally {
            $global:JCConfig.authPreference.Method = $savedMethod
            $env:JCAccessToken = $savedToken
            $env:JCAccessTokenExpiresAt = $savedExpiry
            $env:JCClientId = $savedClientId
            $env:JCClientSecret = $savedClientSecret
        }
    }
    It "Defaults to apiKey mode when authPreference is missing" {
        $savedConfig = $global:JCConfig
        try {
            $global:JCConfig = @{}
            $headers = Get-JCAuthHeaders
            $headers.ContainsKey('x-api-key') | Should -Be $true
            $headers.ContainsKey('Authorization') | Should -Be $false
        } finally {
            $global:JCConfig = $savedConfig
        }
    }
}
