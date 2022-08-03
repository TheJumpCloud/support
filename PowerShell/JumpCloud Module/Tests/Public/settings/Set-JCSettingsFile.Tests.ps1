Describe -Tag "JCSettingsFile" -Name "Set JCSettings Tests" {
    BeforeAll {
        . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/settings/Get-JCSettingsFile.ps1"
        . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/settings/New-JCSettingsFile.ps1"
        . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/settings/Update-JCSettingsFile.ps1"
    }
    it "Settings File can be modified" {
        # Get previous file modified Time
        $previousModifiedDate = (Get-Item "$PSScriptRoot\..\..\..\Config.json").LastWriteTime
        # Get old config file:
        $oldConfig = Get-JCSettingsFile
        # Set config settings:
        if ($oldConfig.parallel.override) {
            Set-JCSettingsFile -parallelOverride $false
        } else {
            Set-JCSettingsFile -parallelOverride $true
        }
        # Get modified config file:
        $modifiedConfig = Get-JCSettingsFile
        # Check that the setting was modified
        $oldConfig.parallel.override | Should -Not -Be $modifiedConfig.parallel.override
        # Get last modified date, this should be different from the file at the start of the test
        $lastModifiedDate = (Get-Item "$PSScriptRoot\..\..\..\Config.json").LastWriteTime
        # Test that new config file is actually modified
        $lastModifiedDate | Should -BeGreaterThan $previousModifiedDate
    }
}