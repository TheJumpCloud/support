Describe -Tag "JCSettingsFile" -Name "New JCSettings Tests" {
    it "Settings File is overwritten when using the -force parameter" {
        # Get previous file modified Time
        $previousModifiedDate = (Get-Item "$PSScriptRoot\..\..\..\Config.json").LastWriteTime
        New-JCSettingsFile -force
        # Create a new config file
        $newConfig = Get-JCSettingsFile
        # New config should not be null or empty
        $newConfig | Should -Not -BeNullOrEmpty
        $lastModifiedDate = (Get-Item "$PSScriptRoot\..\..\..\Config.json").LastWriteTime
        # Test that new config file is actually modified
        $lastModifiedDate | Should -BeGreaterThan $previousModifiedDate
    }
}