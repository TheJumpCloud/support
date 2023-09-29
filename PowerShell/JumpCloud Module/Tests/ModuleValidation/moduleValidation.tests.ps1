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
            write-host "$_"
            $module.RequiredModules.Name | should -Contain $_
        }

        # Validate module version
        $latestModule = Find-Module -Name JumpCloud
        $module.Version | should -BeGreaterThan $latestModule.version
    }
}