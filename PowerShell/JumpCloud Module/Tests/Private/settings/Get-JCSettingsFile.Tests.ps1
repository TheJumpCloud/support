Describe -Tag "JCSettingsFile" -Name "Get JCSettings Tests" {
    it "Settings File should not be null" {
        $config = Get-JCSettingsFile
        $config | Should -Not -BeNullOrEmpty
    }
}