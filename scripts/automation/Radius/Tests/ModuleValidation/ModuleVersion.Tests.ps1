Describe "Module Version Tests" -Tag "ModuleValidation" {

    It "The versions across the module should match" {
        # Get the PSD1 file and config.ps1
        $PSD1 = Test-ModuleManifest -Path "$PSScriptRoot/../../JumpCloud-Radius.psd1"
        $config = Get-Content -Path "$PSScriptRoot/../../Config.ps1" -Raw
        # get the psd1 version
        $psd1Version = $PSD1.version
        # set regex to get psd1 version out of config.ps1
        $versionLineRegex = '\$UserAgent_ModuleVersion.*'
        $versionLine = ($config | Select-String -Pattern $versionLineRegex).Matches[0].Value
        $semanticVersionRegex = "(0|[1-9]\d*).(0|[1-9]\d*).(0|[1-9]\d*)"
        $configVersion = ($versionLine | Select-String -Pattern "(0|[1-9]\d*).(0|[1-9]\d*).(0|[1-9]\d*)").matches[0].value
        # test that both versions are the same
        $configVersion | should -be $psd1Version
    }
}