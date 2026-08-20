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
        { Get-JCSystemApp -SystemOS Linux } | Should -Not -Throw
        { Get-JCSystemApp -SystemOS MacOS } | Should -Not -Throw
        { Get-JCSystemApp -SystemOS Windows } | Should -Not -Throw
    }

    It "Tests that given a systemID, each type of app can be returned" {
        { Get-JCSystemApp -SystemID $mac._id } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $windows._id } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $linux._id } | Should -Not -Throw
    }

    It "Tests that given a systemID, SoftwareName, an app is returned" {
        Get-JCSystemApp -SystemID $linux._id -name "jcagent" | Should -Not -BeNullOrEmpty
    }

    It "Tests that given a name and version, app is returned" {
        $linuxApp = Get-JCSystemApp -SystemID $linux._id -name "jcagent" | Select-Object -First 1
        { Get-JCSystemApp -name "jcagent" -version $linuxApp.SoftwareVersion } | Should -Not -BeNullOrEmpty
    }

    It "Tests that given a linux systemID, SoftwareName, SoftwareVersion, an app is returned" {
        # A null value version shouldn't be accepted
        { Get-JCSystemApp -SystemID $linux._id -name "jcagent" -version "" } | Should -Throw
        # A null value Name shouldn't be accepted
        { Get-JCSystemApp -SystemID $linux._id -name "" } | Should -Throw
        # Using a version that doesn't exist should return nothing
        Get-JCSystemApp -SystemID $linux._id -name "jcagent" -version "48.49.50.51" | Should -BeNullOrEmpty
    }

    It "Tests the exportability of a list of software apps" {
        { Get-JCSystemApp -SystemOS Linux | ConvertTo-Csv } | Should -Not -Throw
        { Get-JCSystemApp -SystemOS MacOS | ConvertTo-Csv } | Should -Not -Throw
        { Get-JCSystemApp -SystemOS Windows | ConvertTo-Csv } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $mac._id | ConvertTo-Csv } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $windows._id | ConvertTo-Csv } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $linux._id | ConvertTo-Csv } | Should -Not -Throw
    }

    It "Tests to make sure an error is not thrown if an app is less than 4 characters long" {
        { Get-JCSystemApp -SystemID $mac._id -name "vlc" } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $windows._id -name "vlc" } | Should -Not -Throw
        { Get-JCSystemApp -SystemID $linux._id -name "vlc" } | Should -Not -Throw
    }
}
