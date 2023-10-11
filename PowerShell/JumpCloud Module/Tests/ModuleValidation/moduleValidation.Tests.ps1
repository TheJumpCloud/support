Describe -Tag:('ModuleValidation') 'Module Manifest Tests' {
    It ('Passes Test-ModuleManifest') {
        $module = Test-ModuleManifest -Path:("$FilePath_psd1")
        # validate module
        $module.RootModule | Should -Be "JumpCloud.psm1"
        $module.Author | Should -Be "JumpCloud Solutions Architect Team"
        $module.CompanyName | Should -Be "JumpCloud"
        $module.Copyright | Should -Be "(c) JumpCloud. All rights reserved."
        $module.Description | Should -Be "PowerShell functions to manage a JumpCloud Directory-as-a-Service"

        # validate required Modules
        $RequiredModules = @('JumpCloud.SDK.DirectoryInsights', 'JumpCloud.SDK.V1', 'JumpCloud.SDK.V2')
        $RequiredModules | ForEach-Object {
            $module.RequiredModules.Name | should -Contain $_
        }

        $ExportedFuncs = $module.ExportedFunctions.keys | Group-Object
        foreach ($func in $ExportedFuncs) {
            $func.count | should -BeExactly 1
        }
        # Validate module version
        $latestModule = Find-Module -Name JumpCloud
        $module.Version | should -BeGreaterThan $latestModule.version
        # GHA Env Variables
        if (-Not $env:OVERRIDE_VERSION) {
            switch ($env:RELEASE_TYPE) {
                'major' {
                    $module.Version.Major | Should -Be (([version]$latestModule.Version).Major + 1)
                }
                'minor' {
                    $module.Version.Minor | Should -Be (([version]$latestModule.Version).Minor + 1)
                }
                'patch' {
                    $module.Version.Build | Should -Be (([version]$latestModule.Version).Build + 1)
                }
            }
        }
    }
    It 'The date on the current version of the Module Manifest file should be todays date' {
        # get content from current path
        $moduleContent = Get-Content -Path ("$FilePath_psd1")
        # update module manifest
        Update-ModuleManifest -Path:($FilePath_psd1)
        $stringMatch = Select-String -InputObject $moduleContent -Pattern "# Generated on: ([\d]+\/[\d]+\/[\d]+)"
        $PSD1_date = $stringMatch.matches.groups[1].value
        ([datetime]$PSD1_date) | Should -Be ([datetime]( Get-Date -Format "M/d/yyyy" ))
    }
    It 'The data on the current version of the Module Changelog should be todays date' {
        if ($env:RELEASE_TYPE) {
            $latestModule = Find-Module -Name JumpCloud

            $ModulePath = ((Get-Item -Path ("$FilePath_psd1")).Directory).Parent
            $moduleChangelogContent = Get-Content ("$ModulePath/ModuleChangelog.md") -TotalCount 3
            # latest from changelog
            $stringMatch = Select-String -InputObject $moduleChangelogContent -Pattern "## ([0-9]+.[0-9]+.[0-9]+)"
            $latestChangelogVersion = $stringMatch.matches.groups[1].value
            $stringMatch = Select-String -InputObject $moduleChangelogContent -Pattern "Release Date: (.*)"
            $latestReleaseDate = $stringMatch.matches.groups[1].value.trim(" ")
            switch ($env:RELEASE_TYPE) {
                'major' {
                    ([Version]$latestChangelogVersion).Major | Should -Be (([version]$latestModule.Version).Major + 1)
                }
                'minor' {
                    ([Version]$latestChangelogVersion).Minor | Should -Be (([version]$latestModule.Version).Minor + 1)
                }
                'patch' {
                    ([Version]$latestChangelogVersion).Build | Should -Be (([version]$latestModule.Version).Build + 1)
                }
            }
            $todayDate = Get-Date -UFormat "%B %d, %Y"
            $latestReleaseDate | Should -Be $todayDate
        }
    }
}