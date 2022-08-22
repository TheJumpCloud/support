Describe -Tag "JCSettingsFile" -Name "Get JCSettings Tests" {
    it "Settings File should not be null" {
        $config = Get-JCSettingsFile
        $config | Should -Not -BeNullOrEmpty
    }
    it "Settings File should return with raw param be null" {
        $config = Get-JCSettingsFile -raw
        $config | Should -Not -BeNullOrEmpty
        $config.parallel.Calculated.value | Should -Not -BeNullOrEmpty
        $config.parallel.Calculated.copy | Should -Not -BeNullOrEmpty
        $config.parallel.Calculated.write | Should -Not -BeNullOrEmpty
    }
}