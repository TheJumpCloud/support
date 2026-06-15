Describe -Tag "JCAuth" -Name "Test-JCConnection Tests" {
    It "Returns false in apiKey mode when an API key is cached" {
        $savedMethod = $global:JCConfig.authPreference.Method
        $savedApiKey = $env:JCApiKey
        try {
            $global:JCConfig.authPreference.Method = 'apiKey'
            $env:JCApiKey = 'test-api-key'
            Test-JCConnection | Should -Be $false
        } finally {
            $global:JCConfig.authPreference.Method = $savedMethod
            $env:JCApiKey = $savedApiKey
        }
    }
    It "Returns true in apiKey mode when no API key is cached" {
        $savedMethod = $global:JCConfig.authPreference.Method
        $savedApiKey = $env:JCApiKey
        try {
            $global:JCConfig.authPreference.Method = 'apiKey'
            $env:JCApiKey = ''
            Test-JCConnection | Should -Be $true
        } finally {
            $global:JCConfig.authPreference.Method = $savedMethod
            $env:JCApiKey = $savedApiKey
        }
    }
    It "Returns false in clientSecret mode when the cached token is valid" {
        $savedMethod = $global:JCConfig.authPreference.Method
        $savedToken = $env:JCAccessToken
        $savedExpiry = $env:JCAccessTokenExpiresAt
        try {
            $global:JCConfig.authPreference.Method = 'clientSecret'
            $env:JCAccessToken = 'valid-token'
            $env:JCAccessTokenExpiresAt = (Get-Date).AddHours(1).ToString('o')
            Test-JCConnection | Should -Be $false
        } finally {
            $global:JCConfig.authPreference.Method = $savedMethod
            $env:JCAccessToken = $savedToken
            $env:JCAccessTokenExpiresAt = $savedExpiry
        }
    }
    It "Returns true in clientSecret mode when the cached token is expired" {
        $savedMethod = $global:JCConfig.authPreference.Method
        $savedToken = $env:JCAccessToken
        $savedExpiry = $env:JCAccessTokenExpiresAt
        try {
            $global:JCConfig.authPreference.Method = 'clientSecret'
            $env:JCAccessToken = 'expired-token'
            $env:JCAccessTokenExpiresAt = (Get-Date).AddSeconds(-10).ToString('o')
            Test-JCConnection | Should -Be $true
        } finally {
            $global:JCConfig.authPreference.Method = $savedMethod
            $env:JCAccessToken = $savedToken
            $env:JCAccessTokenExpiresAt = $savedExpiry
        }
    }
    It "Returns true in clientSecret mode when no token is cached" {
        $savedMethod = $global:JCConfig.authPreference.Method
        $savedToken = $env:JCAccessToken
        try {
            $global:JCConfig.authPreference.Method = 'clientSecret'
            $env:JCAccessToken = ''
            Test-JCConnection | Should -Be $true
        } finally {
            $global:JCConfig.authPreference.Method = $savedMethod
            $env:JCAccessToken = $savedToken
        }
    }
}
