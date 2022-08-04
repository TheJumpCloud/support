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
    it "settings file should contain properties with values, copy and write settings" {
        $newConfig = Get-JCSettingsFile -Raw
        foreach ($parameter in $newConfig.psobject.Properties){
            foreach ($subParameter in $parameter.Value.psobject.Properties) {
                # Write-host "$($parameter.Name).$($subParameter.name)"
                # Each subProperty should contain a value, copy and write property
                $newConfig.$($parameter.Name).$($subParameter.name).value | Should -Not -BeNullOrEmpty
                $newConfig.$($parameter.Name).$($subParameter.name).copy | Should -Not -BeNullOrEmpty
                $newConfig.$($parameter.Name).$($subParameter.name).write | Should -Not -BeNullOrEmpty
            }
        }
    }
}