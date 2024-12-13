Describe -Tag:('JCSystemApp') 'Get-JCSystemApp' {
    BeforeAll {
        $systems = Get-JCsystem
        $mac = $systems | Where-Object { $_.osFamily -match "darwin" } | Select-Object -First 1
        $windows = $systems | Where-Object { $_.osFamily -match "windows" } | Select-Object -First 1
        $linux = $systems | Where-Object { $_.osFamily -match "linux" } | Select-Object -First 1
    }
    It "Returns all the software" {
        $AllApps = Get-JCSystemApp
        $AllApps | Should -Not -BeNullOrEmpty
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
        Get-JCSystemApp -SystemID $mac._id -name "Chess" | Should -Not -BeNullOrEmpty
        Get-JCSystemApp -SystemID $linux._id -name "curl" | Should -Not -BeNullOrEmpty
        Get-JCSystemApp -SystemID $windows._id -name "Microsoft Edge" | Should -Not -BeNullOrEmpty
    }
    It "Tests that given a name and version, app is returned" {
        # Chess is always installed on MacOS and it CAN NOT be removed no matter what
        $macApp = Get-JCSystemApp -SystemID $mac._id -name "Chess"
        $linuxApp = Get-JCSystemApp -SystemID $linux._id -name "curl"
        $windowsApp = Get-JCSystemApp -SystemID $windows._id -name "Microsoft Edge"
        { Get-JCSystemApp -name "Chess" -version $macApp.bundleshortversion } | Should -Not -BeNullOrEmpty
        { Get-JCSystemApp -name "curl" -version $linuxApp.version } | Should -Not -BeNullOrEmpty
        { Get-JCSystemApp -name "Microsoft Edge" -version $windowsApp.version } | Should -Not -BeNullOrEmpty
    }
    It "Tests that given a macOS systemID, SoftwareName, SoftwareVersion, an app is returned" {
        # MacOS
        $macApp = Get-JCSystemApp -SystemID $mac._id -name "Chess"
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -SystemID $mac._id -name "Chess" -version "" } | Should -Throw
        # A null value Name shouldn't be accepted
        { Get-JCSystemApp -SystemID $mac._id -name "" } | Should -Throw
        # Using a version that doesn't exist should return nothing
        Get-JCSystemApp -SystemID $mac._id -name "Chess" -version "48.49.50.51" | Should -Be $null
    }
    It "Tests that given a windows systemID, SoftwareName, SoftwareVersion, an app is returned" {

        #Windows
        $windowsApp = Get-JCSystemApp -SystemID $windows._id -name "Microsoft Edge"
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -SystemID $windows._id -name "Microsoft Edge" -version "" } | Should -Throw
        # A null value Name shouldn't be accepted
        { Get-JCSystemApp -SystemID $windows._id -name "" } | Should -Throw
        # Using a version that doesn't exist should return nothing
        Get-JCSystemApp -SystemID $windows._id -name "Microsoft Edge" -version "48.49.50.51" | Should -Be $null
    }
    It "Tests that given a linux systemID, SoftwareName, SoftwareVersion, an app is returned" {
        #Linux
        #Windows
        $linuxApp = Get-JCSystemApp -SystemID $linux._id -name "curl"
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -SystemID $linux._id -name "curl" -version "" } | Should -Throw
        # A null value Name shouldn't be accepted
        { Get-JCSystemApp -SystemID $linux._id -name "" } | Should -Throw
        # Using a version that doesn't exist should return nothing
        Get-JCSystemApp -SystemID $linux._id -name "curl" -version "48.49.50.51" | Should -Be $null
    }
    # Create tests for Search
    It "Tests for search given SystemOs and SoftwareName for MacOS Systems" {
        # Chess is always installed on MacOS and it CAN NOT be removed no matter what
        { Get-JCSystemApp -Search | Should -Throw }
        { Get-JCSystemApp -Search -name "Chess" -SystemID $mac.Id } | should -Not -Throw
        { Get-JCSystemApp -Search -name "Chess" } | should -Not -Throw
        { Get-JCSystemApp -Search -name "Chess" -SystemOs "MacOs" } | should -Not -Throw
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -Search -name "Chess" -SystemOs "" | Should -Throw }
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -Search -name "" -SystemOs "MacOs" | Should -Throw }
        # Searching chess on MacOs should return a result
        { Get-JCSystemApp -Search -name "Chess" -SystemOs "MacOs" } | should -Not -Throw
    }
    It "Tests for search given SystemOs and SoftwareName for Linux Systems" {
        # Curl is always installed on linux
        { Get-JCSystemApp -Search | Should -Throw }
        { Get-JCSystemApp -Search -name "Curl" -SystemID $linux._Id } | should -Not -Throw
        { Get-JCSystemApp -Search -name "Curl" } | should -Not -Throw
        { Get-JCSystemApp -Search -name "Curl" -SystemOs "linux" } | should -Not -Throw
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -Search -name "Curl" -SystemOs "" | Should -Throw }
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -Search -name "" -SystemOs "linux" | Should -Throw }
        # Searching Curl on linux should return a result
        { Get-JCSystemApp -Search -name "Curl" -SystemOs "linux" } | should -Not -Throw
    }
    It "Tests for search given SystemOs and SoftwareName for Windows Systems" {
        # Microsoft Edge is always installed on windows
        { Get-JCSystemApp -Search | Should -Throw }
        { Get-JCSystemApp -Search -name "Microsoft Edge" -SystemID $windows._Id } | should -Not -Throw
        { Get-JCSystemApp -Search -name "Microsoft Edge" } | should -Not -Throw
        { Get-JCSystemApp -Search -name "Microsoft Edge" -SystemOs "windows" } | should -Not -Throw
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -Search -name "Microsoft Edge" -SystemOs "" | Should -Throw }
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -Search -name "" -SystemOs "windows" | Should -Throw }
        # Searching Microsoft Edge on windows should return a result
        { Get-JCSystemApp -Search -name "Microsoft Edge" -SystemOs "windows" } | should -Not -Throw
    }

    It "Tests the search functionatily of a software app" {
        #Tests for each OS
        # results with no data should be null or empty
        Get-JCSystemApp -name "chess" | Should -BeNullOrEmpty
        Get-JCSystemApp -name "microsoft edge" | Should -BeNullOrEmpty
        # when search is used to find an app the results should not be null or empty
        Get-JCSystemApp -name "chess" -Search | Should -Not -BeNullOrEmpty
        Get-JCSystemApp -name "microsoft edge" -Search | Should -Not -BeNullOrEmpty
        Get-JCSystemApp -name "curl" -Search | Should -Not -BeNullOrEmpty
    }

    It "Tests the search param with systemID" {

        $macApps = Get-JCSystemApp -Systemid $mac._id -name "a" -search
        $windowsApps = Get-JCSystemApp -Systemid $windows._id -name "a" -search
        $linuxApps = Get-JCSystemApp -Systemid $linux._id -name "a" -search
        $foundMacSystems = $macApps.systemid | Select-Object -Unique
        $foundWindowsSystems = $windowsApps.systemid | Select-Object -Unique
        $foundLinuxSystems = $linuxApps.systemid | Select-Object -Unique
        # if you specify a systemID and Search, results should not contain multiple systems
        $foundMacSystems.count | should -Be 1
        $foundWindowsSystems.count | should -Be 1
        $foundLinuxSystems.count | should -Be 1
    }
    It "Tests the search param with macos SystemOS" {
        # MacOS
        $apps = Get-JCSystemApp -SystemOS "macos" -name "a" -search
        $foundMacSystems = $apps.systemid | Select-Object -Unique
        # if you specify a systemOS and Search, results should not contain multiple systems
        foreach ($system in $foundSystems) {
            $foundMacSystems = Get-JCSystem -SystemID $system
            $foundMacSystems.osfamily | Should -be 'darwin'
        }
    }
    It "Tests the search param with windows SystemOS" {
        # Windows
        $apps = Get-JCSystemApp -SystemOS "windows" -name "a" -search
        $foundWindowsSystems = $apps.systemid | Select-Object -Unique
        # if you specify a systemOS and Search, results should not contain multiple systems
        foreach ($system in $foundWindowsSystems) {
            $foundWindowsSystems = Get-JCSystem -SystemID $system
            $foundWindowsSystems.osfamily | Should -be 'windows'
        }
    }
    It "Tests the search param with linux SystemOS" {
        # Linux
        $apps = Get-JCSystemApp -SystemOS "linux" -name "a" -search
        $foundLinuxSystems = $apps.systemid | Select-Object -Unique
        # if you specify a systemOS and Search, results should not contain multiple systems
        foreach ($system in $foundLinuxSystems) {
            $foundLinuxSystems = Get-JCSystem -SystemID $system
            $foundLinuxSystems.osfamily | Should -be 'linux'
        }
    }

    It "Tests compatability macOS with the SDKs" {
        #MacOS
        $sdkMac = Get-JcSdkSystemInsightApp -filter @("system_id:eq:$($mac._id)", "name:eq:Chess.app")
        $moduleMac = Get-JCSystemApp -SystemID $mac._id -name "Chess"
        $moduleMacSearch = Get-JCSystemApp -SystemID $mac._id -name "chess" -Search
        # SDK Results should look exactly like module results when exact name is specified
        $sdkMac.id | Should -Be $moduleMac.id
        $sdkMac.name | Should -Be $moduleMac.name
        # SDK Results should look exactly like module results when search is provided
        $sdkMac.id | Should -Be $moduleMacSearch.id
        $moduleMacSearch.name | Should -Contain  $sdkMac.name
    }
    It "Tests compatability windows with the SDKs" {
        #Windows
        $sdkWindows = Get-JcSdkSystemInsightProgram -filter @("system_id:eq:$($windows._id)", "name:eq:Microsoft Edge")
        $moduleWindows = Get-JCSystemApp -SystemID $windows._id -name "Microsoft Edge"
        $moduleWindowsSearch = Get-JCSystemApp -SystemID $windows._id -name "microsoft edge" -Search
        # SDK Results should look exactly like module results when exact name is specified
        $sdkWindows.id | Should -Be $moduleWindows.id
        $sdkWindows.name | Should -Be $moduleWindows.name
        # SDK Results should look exactly like module results when search is provided
        $sdkWindows.id | Should -Be $moduleWindowsSearch.id
        $moduleWindowsSearch.name | Should -Contain $sdkWindows.name
    }
    It "Tests compatability linux with the SDKs" {
        #Linux
        $sdkLinux = Get-JcSdkSystemInsightLinuxPackage -filter @("system_id:eq:$($linux._id)", "name:eq:curl")
        $moduleLinux = Get-JCSystemApp -SystemID $linux._id -name "curl"
        $moduleLinuxSearch = Get-JCSystemApp -SystemID $linux._id -name "curl" -Search
        # SDK Results should look exactly like module results when exact name is specified
        $sdkLinux.id | Should -Be $moduleLinux.id
        $sdkLinux.name | Should -Be $moduleLinux.name
        # SDK Results should look exactly like module results when search is provided
        $sdkLinux.id | Should -Be $moduleLinuxSearch.id
        $moduleLinuxSearch.name | Should -Contain $sdkLinux.name
    }

    It "Tests that incompatible parameters should not be used together" {
        # -version should not be specified with -Search
        { Get-JCSystemApp -name "chess" -Search -version "3.1.2" } | Should -Throw
        # -SystemOS should not be specified with -SystemID
        { Get-JCsystemApp -SystemID $mac._id -SystemOS "windows" } | Should -Throw
        { Get-JCsystemApp -SystemID $mac._id -SystemOS "windows" } | Should -Throw
        { Get-JCsystemApp -SystemID $mac._id -SystemOS "windows" -name "Chess" } | Should -Throw
        { Get-JCsystemApp -SystemID $mac._id -SystemOS "windows" -name "Chess" -version "1.2.3" } | Should -Throw
    }

    It "Tests the exporability of a list of software apps" {
        { Get-JCSystemApp -SystemOS linux | ConvertTo-Csv } | Should -Not -Throw
        # Should return mac apps for all systems in the org
        { Get-JCSystemApp -SystemOS macOS | ConvertTo-Csv } | Should -Not -Throw
        # Should return windows programs for all systems in the org
        { Get-JCSystemApp -SystemOS windows | ConvertTo-Csv } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $mac._id | ConvertTo-Csv } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $windows._id | ConvertTo-Csv } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $linux._id | ConvertTo-Csv } | Should -Not -Throw
    }
    It "Tests macos functionatily to append .app to softwareName" {
        Get-JCSystemApp -SystemID $mac._id -name "Chess.app" | Should -Not -BeNullOrEmpty
        Get-JCSystemApp -SystemID $mac._id -name "Chess.App" | Should -Not -BeNullOrEmpty
        Get-JCSystemApp -SystemID $mac._id -name "Chess" | Should -Not -BeNullOrEmpty
    }
    It "Tests to make sure an error is not thrown if an app is less than 4 characters long" {
        Get-JCSystemApp -SystemID $mac._id -name "vlc" | Should -Not -Throw
        Get-JCSystemApp -SystemID $windows._id -name "vlc" | Should -Not -Throw
        Get-JCSystemApp -SystemID $linux._id -name "vlc" | Should -Not -Throw
    }
}