Describe -Tag "JCSettingsFile" -Name "Get JCSettings Tests" {
    BeforeAll {
        . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/settings/Get-JCSettingsFile.ps1"
        . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/settings/New-JCSettingsFile.ps1"
        . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/settings/Update-JCSettingsFile.ps1"
        . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/NestedFunctions/Get-JCParallelValidation.ps1"
    }
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