Describe -Tag:('JCSystemApp') 'Get-JCSystemApp' {

    BeforeAll {
        $systems = Get-JCsystem
        $mac = $systems | Where-Object { $_.osFamily -match "darwin" } | Select-Object -First 1
        $windows = $systems | Where-Object { $_.osFamily -match "windows" } | Select-Object -First 1
        $linux = $systems | Where-Object { $_.osFamily -match "linux" } | Select-Object -First 1
    }

    It "Tests that Get-JCSystemApp returns packages/apps/programs for all systems in the org" {
        # Should return linuxPackages for all systems in the org
        { Get-JCSystemApp -SystemOS linux } | Should -Not -Throw
        # Should return mac apps for all systems in the org
        { Get-JCSystemApp -SystemOS macOS } | Should -Not -Throw
        # Should return windows programs for all systems in the org
        { Get-JCSystemApp -SystemOS windows } | Should -Not -Throw
    }
    It "Tests that given a systemID, each type of app can be returned" {
        { Get-JCSystemApp -SystemID $mac._id } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $windows._id } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $linux._id } | Should -Not -Throw
    }

    It "Tests that given a systemID, SoftwareName, an app is returned" {
        # Chess is always installed on MacOS and it CAN NOT be removed no matter what
        Get-JCSystemApp -SystemID $mac._id -SoftwareName "Chess"
        # TODO: Windows/ Linux Examples
    }
    It "Tests that given a systemID, SoftwareName, SoftwareVersion, an app is returned" {
        # Chess is always installed on MacOS and it CAN NOT be removed no matter what
        $ChessApp = Get-JCSystemApp -SystemID $mac._id -SoftwareName "Chess"
        Get-JCSystemApp -SystemID $mac._id -SoftwareName "Chess" -SoftwareVersion $ChessApp.Bundle_short_version
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -SystemID $mac._id -SoftwareName "Chess" -SoftwareVersion "" } | Should -Throw
        # A null value Name shouldn't be accepted
        { Get-JCSystemApp -SystemID $mac._id -SoftwareName "" } | Should -Throw
        # Using a version that doesn't exist should return nothing
        Get-JCSystemApp -SystemID $mac._id -SoftwareName "Chess" -SoftwareVersion "48.49.50.51" | Should -Be $null
        # TODO: Windows/ Linux Examples
    }
}
