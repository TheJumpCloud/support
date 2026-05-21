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
