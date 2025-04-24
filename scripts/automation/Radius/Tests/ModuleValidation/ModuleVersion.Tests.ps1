Describe "Module Version Tests" -Tag "ModuleValidation" {
    BeforeAll {
        $psd1Path = "$PSScriptRoot/../../JumpCloud.Radius.psd1"
        $configPath = "$PSScriptRoot/../../Config.json"
        # remove the config file if it exists
        if (Test-Path -Path $configPath) {
            Remove-Item -Path $configPath -Force
        }
    }

    It "The userAgent should be set in the module settings" {
        # Get the PSD1 file and Config.ps1
        $PSD1 = Test-ModuleManifest -Path $psd1Path
        Import-Module $psd1Path -Force
        # the user agent should be set to the module version
        $module.PrivateData.settings['userAgent'] | Should -Match "$($PSD1.version)"
        # the string should be in the format of JumpCloud_ModuleName.ModuleVersion
        $userAgentRegex = 'JumpCloud_PasswordlessRadiusConfig.PowerShellModule/[0-9]+.[0-9]+.[0-9]+'
        $module.PrivateData.settings['userAgent'] | Should -Match $userAgentRegex
    }

    Context "Module Config Tests" {
        It "when the config file does not exist, importing the module should only write warning messages" {
            # Import the module
            { Import-Module $psd1Path -Force } | Should -Not -Throw
            # Check that the config file does not exist
            Test-Path -Path $configPath | Should -Be $false
            # Check that the module config is set to the default values
            $Global:JCRConfig.userGroup.value | Should -Be $null
        }
        It "Setting the settings to some series of values should not throw an error" {
            $settings = @{
                certSubjectHeaderCommonName       = "JumpCloud.com"
                certType                          = "UsernameCn"
                certSubjectHeaderOrganization     = "JumpCloud"
                radiusDirectory                   = "~/RADIUS"
                certSecretPass                    = "secret1234!"
                certSubjectHeaderOrganizationUnit = "Customer_Tools"
                certSubjectHeaderCountryCode      = "US"
                certSubjectHeaderStateCode        = "CO"
                certSubjectHeaderLocality         = "Boulder"
                networkSSID                       = "TP-Link_SSID"
                userGroup                         = "5f3171a9232e1113939dd6a2"
            }
            Set-JCRConfigFile @settings
        }
    }
}