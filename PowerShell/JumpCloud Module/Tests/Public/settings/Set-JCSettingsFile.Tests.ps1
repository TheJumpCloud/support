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
        if ($oldConfig.JCEnvironment.location -eq 'STANDARD') {
            Set-JCSettingsFile -JCEnvironmentLocation 'EU'
        } else {
            Set-JCSettingsFile -JCEnvironmentLocation 'STANDARD'
        }
        # Get modified config file:
        $modifiedConfig = Get-JCSettingsFile
        # Check that the setting was modified
        $oldConfig.parallel.override | Should -Not -Be $modifiedConfig.parallel.override
        $oldConfig.JCEnvironment.location | Should -Not -Be $modifiedConfig.JCEnvironment.location
        $env:JCEnvironment | Should -Be $modifiedConfig.JCEnvironment.location
        # Get last modified date, this should be different from the file at the start of the test
        $lastModifiedDate = (Get-Item "$PSScriptRoot\..\..\..\Config.json").LastWriteTime
        # Test that new config file is actually modified
        $lastModifiedDate | Should -BeGreaterThan $previousModifiedDate
    }
}