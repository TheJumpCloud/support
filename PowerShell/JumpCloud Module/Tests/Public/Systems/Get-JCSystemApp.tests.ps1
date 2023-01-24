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

    It "Tests the search functionatily of a software app" {
        # results with no data should be null or empty
        Get-JCSystemApp -SoftwareName "chess" | Should -BeNullOrEmpty
        # when search is used to find an app the results should not be null or empty
        Get-JCSystemApp -SoftwareName "chess" -Search | Should -Not -BeNullOrEmpty
    }

    It "Tests the search param with systemID" {

        $apps = Get-JCSystemApp -Systemid $mac._id -SoftwareName "a" -search
        $foundSystems = $apps.system_id | Select-Object -Unique
        # if you specify a systemID and Search, results should not contain multiple systems
        $foundSystems.count | should -Be 1
    }
    It "Tests the search param with SystemOS" {
        $apps = Get-JCSystemApp -SystemOS "macos" -SoftwareName "a" -search
        $foundSystems = $apps.system_id | Select-Object -Unique
        # if you specify a systemOS and Search, results should not contain multiple systems
        foreach ($system in $foundSystems) {
            $foundSystem = Get-JCSystem -SystemID $system
            $foundSystem.osfamily | Should -be 'darwin'
        }
    }

    It "Tests compatability with the SDKs" {
        $sdkChess = Get-JcSdkSystemInsightApp -filter @("system_id:eq:$($mac._id)", "bundle_name:eq:Chess")
        $moduleChess = Get-JCSystemApp -SystemID $mac._id -SoftwareName "Chess"
        $moduleChessSearch = Get-JCSystemApp -SystemID $mac._id -SoftwareName "chess" -Search
        # SDK Results should look exactly like module results when exact name is specified
        $sdkChess | Should -Be $moduleChess
        # SDK Results should look exactly like module results when search is provided
        $sdkChess | Should -Be $moduleChessSearch
    }

    It "Tests that incompatible parameters should not be used together" {
        # -SoftwareVersion should not be specified with -Search
        { Get-JCSystemApp -SoftwareName "chess" -Search -SoftwareVersion "3.1.2" } | Should -Throw
        # -SystemOS should not be specified with -SystemID
        { Get-JCsystemApp -SystemID $mac._id -SystemOS "windows" } | Should -Throw
        { Get-JCsystemApp -SystemID $mac._id -SystemOS "windows" } | Should -Throw
        { Get-JCsystemApp -SystemID $mac._id -SystemOS "windows" -SoftwareName "Chess" } | Should -Throw
        { Get-JCsystemApp -SystemID $mac._id -SystemOS "windows" -SoftwareName "Chess" -SoftwareVersion "1.2.3" } | Should -Throw
    }
}
