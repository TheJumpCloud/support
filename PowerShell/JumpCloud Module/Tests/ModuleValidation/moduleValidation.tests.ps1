#. "$PSScriptRoot/PowerShell/JumpCloud Module/Tests/TestEnvironmentVariables.ps1"

. "/Users/sreed/Git/support/PowerShell/JumpCloud Module/Tests/TestEnvironmentVariables.ps1"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}