Describe -Tag "JCSettingsFile" -Name "Set JCSettings Tests" {
    It "Settings File can be modified" {
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

    It 'Changes JCEnvironment' {
        # Get old config file:
        $oldConfig = Get-JCSettingsFile
        # Set JCEnvironment to EU
        Set-JCSettingsFile -JCEnvironmentLocation 'EU'
        # Get modified config file:
        $modifiedConfig = Get-JCSettingsFile
        # Check that the setting was modified
        $oldConfig.JCEnvironment.Location | Should -Not -Be $modifiedConfig.JCEnvironment.Location
        $modifiedConfig.JCEnvironment.Location | Should -Be 'EU'
        # Check that env variable is set
        $env:JCEnvironment | Should -Be 'EU'
        $global:JCEnvironment | Should -Be 'EU'

        # Revert changes
        Set-JCSettingsFile -JCEnvironmentLocation 'STANDARD'
        # Check that env variable is set
        $env:JCEnvironment | Should -Be 'STANDARD'
        $global:JCEnvironment | Should -Be 'STANDARD'
    }
}